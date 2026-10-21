-- =====================================================================
-- Pulse · Notifications (Activity screen + push)
-- Migration: supabase/migrations/20261014120000_notifications.sql
-- Depends on: pulse_schema, follow_requests (follows.status),
--             20261012120000_home_feed (posts, post_likes, comments,
--             post_media). Do not re-apply earlier migrations.
--
-- Adds:
--   notifications         one row per item on the Activity screen
--                         (likes on a post are grouped into one row)
--   notification_prefs    push switches from Settings → Notifications
--   device_tokens         FCM tokens per device
--   triggers              follow, follow request, request accepted,
--                         like, comment, reply, mention (post + comment)
--   RPCs                  activity_feed, activity_unread_count,
--                         mark_activity_read, set_notification_prefs,
--                         register_device, unregister_device
--
-- Clients can only READ their own notifications. Every write comes from
-- security-definer triggers / RPCs below.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Helper: can a given user see an author's content?
--    (can_view_author() uses auth.uid(); triggers need the recipient.)
-- ---------------------------------------------------------------------
create or replace function public.can_user_view_author(p_viewer uuid, p_author uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_viewer = p_author
      or exists (select 1 from public.profiles p
                 where p.id = p_author and not p.is_private and p.signup_step = 0)
      or exists (select 1 from public.follows f
                 where f.follower_id = p_viewer and f.following_id = p_author
                   and f.status = 'accepted');
$$;
revoke all on function public.can_user_view_author(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 1. notifications
-- ---------------------------------------------------------------------
create table public.notifications (
  id            uuid primary key default gen_random_uuid(),
  recipient_id  uuid not null references public.profiles (id) on delete cascade,
  type          text not null,
  actor_id      uuid not null references public.profiles (id) on delete cascade, -- latest actor
  actor_count   integer not null default 1,                                     -- "and 23 others" = actor_count - 1
  post_id       uuid references public.posts (id) on delete cascade,
  comment_id    uuid references public.comments (id) on delete cascade,
  preview       text,                     -- comment / mention snippet (max 140)
  group_key     text not null,            -- one row per (recipient, group_key)
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),  -- sort key; bumped on new activity
  read_at       timestamptz,
  pushed_at     timestamptz,              -- last push sent for this row (throttle)

  constraint notifications_type check (type in (
    'follow', 'follow_request', 'follow_accepted',
    'like', 'comment', 'reply', 'mention'
  )),
  constraint notifications_actor_count check (actor_count >= 1),
  constraint notifications_preview_len check (preview is null or char_length(preview) <= 140),
  constraint notifications_not_self check (recipient_id <> actor_id),
  constraint notifications_group unique (recipient_id, group_key)
);

create index notifications_feed_idx   on public.notifications (recipient_id, updated_at desc, id desc);
create index notifications_unread_idx on public.notifications (recipient_id) where read_at is null;
create index notifications_actor_idx  on public.notifications (actor_id);
create index notifications_post_idx   on public.notifications (post_id) where post_id is not null;
create index notifications_comment_idx on public.notifications (comment_id) where comment_id is not null;

alter table public.notifications enable row level security;

create policy notifications_select_own on public.notifications
  for select to authenticated using (recipient_id = auth.uid());

revoke all on public.notifications from anon, authenticated;
grant select on public.notifications to authenticated;

-- Upsert used by every trigger. A repeat in the same group bumps the row
-- to the top and marks it unread again.
create or replace function public.notify(
  p_recipient uuid, p_type text, p_actor uuid, p_group text,
  p_post uuid default null, p_comment uuid default null,
  p_preview text default null, p_actor_count integer default 1
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_recipient is null or p_actor is null or p_recipient = p_actor then
    return;
  end if;
  insert into public.notifications as n
    (recipient_id, type, actor_id, actor_count, post_id, comment_id, preview, group_key)
  values
    (p_recipient, p_type, p_actor, greatest(p_actor_count, 1), p_post, p_comment,
     left(p_preview, 140), p_group)
  on conflict (recipient_id, group_key) do update
    set actor_id    = excluded.actor_id,
        actor_count = excluded.actor_count,
        type        = excluded.type,
        comment_id  = excluded.comment_id,
        preview     = excluded.preview,
        updated_at  = now(),
        read_at     = null;
end;
$$;
revoke all on function public.notify(uuid, text, uuid, text, uuid, uuid, text, integer) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Triggers
-- ---------------------------------------------------------------------

-- 2.1 Follows: new follow / request, request accepted, unfollow cleanup
create or replace function public.notify_on_follow()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    if new.status = 'accepted' then
      perform public.notify(new.following_id, 'follow', new.follower_id, 'follow:' || new.follower_id);
    else
      perform public.notify(new.following_id, 'follow_request', new.follower_id, 'follow:' || new.follower_id);
    end if;

  elsif tg_op = 'UPDATE' then
    if old.status <> 'accepted' and new.status = 'accepted' then
      -- the request row on the target's side becomes "started following you"
      perform public.notify(new.following_id, 'follow', new.follower_id, 'follow:' || new.follower_id);
      -- and the requester learns it was accepted
      perform public.notify(new.follower_id, 'follow_accepted', new.following_id, 'accepted:' || new.following_id);
    end if;

  elsif tg_op = 'DELETE' then
    -- unfollow, declined or cancelled request: remove the target's row
    delete from public.notifications
     where recipient_id = old.following_id and group_key = 'follow:' || old.follower_id;
    return old;
  end if;
  return new;
end;
$$;

create trigger follows_notify
  after insert or update of status or delete on public.follows
  for each row execute function public.notify_on_follow();

-- 2.2 Likes: one grouped row per post, recomputed from post_likes
create or replace function public.notify_on_like()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_post   uuid := coalesce(new.post_id, old.post_id);
  v_author uuid;
  v_latest uuid;
  v_count  integer;
begin
  select author_id into v_author from public.posts where id = v_post;
  if v_author is null then return null; end if;

  select count(*) into v_count
    from public.post_likes where post_id = v_post and user_id <> v_author;

  if v_count = 0 then
    delete from public.notifications
     where recipient_id = v_author and group_key = 'like:' || v_post;
    return null;
  end if;

  select user_id into v_latest
    from public.post_likes
   where post_id = v_post and user_id <> v_author
   order by created_at desc limit 1;

  if tg_op = 'INSERT' and new.user_id <> v_author then
    perform public.notify(v_author, 'like', v_latest, 'like:' || v_post, v_post, null, null, v_count);
  else
    -- unlike: fix the count / latest actor without bumping or re-marking unread
    update public.notifications
       set actor_id = v_latest, actor_count = v_count
     where recipient_id = v_author and group_key = 'like:' || v_post;
  end if;
  return null;
end;
$$;

create trigger post_likes_notify
  after insert or delete on public.post_likes
  for each row execute function public.notify_on_like();

-- 2.3 Mentions: @username in a text, max 10, only people who can see it
create or replace function public.notify_mentions(
  p_text text, p_actor uuid, p_post uuid, p_comment uuid, p_post_author uuid
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r record;
begin
  if p_text is null or position('@' in p_text) = 0 then return; end if;
  for r in
    select distinct pr.id
      from (select lower(m[1]) as uname
              from regexp_matches(p_text, '@([A-Za-z0-9._]{3,30})', 'g') as m
             limit 10) u
      join public.profiles pr on lower(pr.username) = u.uname
     where pr.id <> p_actor
       -- in a comment the post author already gets the comment row
       and (p_comment is null or pr.id <> p_post_author)
       and public.can_user_view_author(pr.id, p_post_author)
  loop
    perform public.notify(
      r.id, 'mention', p_actor,
      'mention:' || coalesce(p_comment, p_post),
      p_post, p_comment, p_text);
  end loop;
end;
$$;
revoke all on function public.notify_mentions(text, uuid, uuid, uuid, uuid) from public, anon, authenticated;

-- 2.4 Comments and replies (+ mentions inside them)
create or replace function public.notify_on_comment()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_author        uuid;
  v_parent_author uuid;
begin
  select author_id into v_author from public.posts where id = new.post_id;

  if new.parent_id is null then
    perform public.notify(v_author, 'comment', new.author_id,
                          'comment:' || new.id, new.post_id, new.id, new.body);
  else
    select author_id into v_parent_author from public.comments where id = new.parent_id;
    perform public.notify(v_parent_author, 'reply', new.author_id,
                          'comment:' || new.id, new.post_id, new.id, new.body);
    -- post author also hears about replies in their thread
    if v_author is distinct from v_parent_author then
      perform public.notify(v_author, 'comment', new.author_id,
                            'comment:' || new.id, new.post_id, new.id, new.body);
    end if;
  end if;

  perform public.notify_mentions(new.body, new.author_id, new.post_id, new.id, v_author);
  return null;
end;
$$;

create trigger comments_notify
  after insert on public.comments
  for each row execute function public.notify_on_comment();

-- 2.5 Mentions in a post caption
create or replace function public.notify_on_post()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.notify_mentions(new.caption, new.author_id, new.id, null, new.author_id);
  return null;
end;
$$;

create trigger posts_notify_mentions
  after insert on public.posts
  for each row execute function public.notify_on_post();

-- ---------------------------------------------------------------------
-- 3. Read API (Activity screen)
-- ---------------------------------------------------------------------

-- Page of activity, newest first. Keyset paging on (updated_at, id).
-- Follow requests are shown by the Follow requests row, not as items.
create or replace function public.activity_feed(
  p_limit        integer default 30,
  p_before_time  timestamptz default null,
  p_before_id    uuid default null
) returns table (
  id               uuid,
  type             text,
  actor_id         uuid,
  actor_username   text,
  actor_full_name  text,
  actor_avatar_url text,
  actor_count      integer,
  post_id          uuid,
  post_kind        text,
  post_thumb_path  text,
  comment_id       uuid,
  preview          text,
  i_follow_actor   boolean,
  is_unread        boolean,
  updated_at       timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select n.id, n.type,
         n.actor_id, a.username, a.full_name, a.avatar_url,
         n.actor_count,
         n.post_id, p.kind,
         coalesce(m.thumb_path, m.path),
         n.comment_id, n.preview,
         exists (select 1 from public.follows f
                  where f.follower_id = auth.uid() and f.following_id = n.actor_id
                    and f.status = 'accepted'),
         n.read_at is null,
         n.updated_at
    from public.notifications n
    join public.profiles a on a.id = n.actor_id
    left join public.posts p on p.id = n.post_id
    left join public.post_media m on m.post_id = n.post_id and m.position = 0
   where n.recipient_id = auth.uid()
     and n.type <> 'follow_request'
     and (p_before_time is null
          or (n.updated_at, n.id) < (p_before_time, p_before_id))
   order by n.updated_at desc, n.id desc
   limit least(greatest(coalesce(p_limit, 30), 1), 50);
$$;

-- Bell dot on Home: unread activity + pending follow requests
create or replace function public.activity_unread_count()
returns table (activity integer, follow_requests integer)
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select count(*)::int from public.notifications
      where recipient_id = auth.uid() and read_at is null and type <> 'follow_request'),
    (select count(*)::int from public.follows
      where following_id = auth.uid() and status <> 'accepted');
$$;

-- Call when the Activity screen opens (clears the dot).
create or replace function public.mark_activity_read(p_ids uuid[] default null)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare v integer;
begin
  update public.notifications
     set read_at = now()
   where recipient_id = auth.uid()
     and read_at is null
     and (p_ids is null or id = any(p_ids));
  get diagnostics v = row_count;
  return v;
end;
$$;

revoke all on function public.activity_feed(integer, timestamptz, uuid) from public, anon;
revoke all on function public.activity_unread_count() from public, anon;
revoke all on function public.mark_activity_read(uuid[]) from public, anon;
grant execute on function public.activity_feed(integer, timestamptz, uuid) to authenticated;
grant execute on function public.activity_unread_count() to authenticated;
grant execute on function public.mark_activity_read(uuid[]) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Push preferences (Settings → Notifications, board 4.6)
--    In-app Activity always records; these only gate push.
-- ---------------------------------------------------------------------
create table public.notification_prefs (
  user_id        uuid primary key references public.profiles (id) on delete cascade,
  push_enabled   boolean not null default true,
  likes          boolean not null default true,
  comments       boolean not null default true,   -- comments + replies
  mentions       boolean not null default true,
  followers      boolean not null default true,   -- follow, request, accepted
  messages       boolean not null default true,   -- for Chat later
  group_chats    boolean not null default false,
  shorts         boolean not null default true,
  email_digest   boolean not null default false,
  product        boolean not null default false,
  updated_at     timestamptz not null default now()
);

alter table public.notification_prefs enable row level security;
create policy notification_prefs_select_own on public.notification_prefs
  for select to authenticated using (user_id = auth.uid());
revoke all on public.notification_prefs from anon, authenticated;
grant select on public.notification_prefs to authenticated;

-- Partial update: pass only the switches that changed, e.g. {"likes": false}
create or replace function public.set_notification_prefs(p jsonb)
returns public.notification_prefs
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.notification_prefs;
  k text;
begin
  for k in select jsonb_object_keys(p) loop
    if k not in ('push_enabled','likes','comments','mentions','followers','messages',
                 'group_chats','shorts','email_digest','product')
       or jsonb_typeof(p -> k) <> 'boolean' then
      raise exception 'invalid preference: %', k using errcode = 'invalid_parameter_value';
    end if;
  end loop;

  insert into public.notification_prefs (user_id) values (auth.uid())
  on conflict (user_id) do nothing;

  update public.notification_prefs t set
    push_enabled = coalesce((p->>'push_enabled')::boolean, t.push_enabled),
    likes        = coalesce((p->>'likes')::boolean, t.likes),
    comments     = coalesce((p->>'comments')::boolean, t.comments),
    mentions     = coalesce((p->>'mentions')::boolean, t.mentions),
    followers    = coalesce((p->>'followers')::boolean, t.followers),
    messages     = coalesce((p->>'messages')::boolean, t.messages),
    group_chats  = coalesce((p->>'group_chats')::boolean, t.group_chats),
    shorts       = coalesce((p->>'shorts')::boolean, t.shorts),
    email_digest = coalesce((p->>'email_digest')::boolean, t.email_digest),
    product      = coalesce((p->>'product')::boolean, t.product),
    updated_at   = now()
  where t.user_id = auth.uid()
  returning * into v;
  return v;
end;
$$;
revoke all on function public.set_notification_prefs(jsonb) from public, anon;
grant execute on function public.set_notification_prefs(jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 5. Device tokens (FCM)
-- ---------------------------------------------------------------------
create table public.device_tokens (
  token        text primary key,
  user_id      uuid not null references public.profiles (id) on delete cascade,
  platform     text not null,
  locale       text,
  updated_at   timestamptz not null default now(),
  constraint device_tokens_platform check (platform in ('android', 'ios', 'web')),
  constraint device_tokens_len check (char_length(token) between 20 and 4096)
);
create index device_tokens_user_idx on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;
-- no client policies: tokens are written by RPC and read by the Edge Function
revoke all on public.device_tokens from anon, authenticated;

-- Call after sign-in and on FirebaseMessaging.onTokenRefresh.
-- A token moves to the new user if the device switched accounts.
create or replace function public.register_device(p_token text, p_platform text, p_locale text default null)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.device_tokens (token, user_id, platform, locale)
  values (p_token, auth.uid(), p_platform, p_locale)
  on conflict (token) do update
    set user_id = excluded.user_id, platform = excluded.platform,
        locale = excluded.locale, updated_at = now();
$$;

-- Call on sign-out (before the session is cleared).
create or replace function public.unregister_device(p_token text)
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.device_tokens where token = p_token and user_id = auth.uid();
$$;

revoke all on function public.register_device(text, text, text) from public, anon;
revoke all on function public.unregister_device(text) from public, anon;
grant execute on function public.register_device(text, text, text) to authenticated;
grant execute on function public.unregister_device(text) to authenticated;

-- ---------------------------------------------------------------------
-- 6. Realtime: let the app hear new rows for the bell dot
--    (Realtime respects the select policy above.)
-- ---------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.notifications;
  end if;
end $$;

-- ---------------------------------------------------------------------
-- 7. Push dispatch
--    Create a Database Webhook in the dashboard (Database → Webhooks):
--      table public.notifications · events INSERT, UPDATE
--      → Supabase Edge Function "push-notify" (POST, auth header added by
--        the dashboard). The function checks prefs, throttles via
--        pushed_at and sends FCM. Keys stay in function secrets, never here.
-- ---------------------------------------------------------------------
