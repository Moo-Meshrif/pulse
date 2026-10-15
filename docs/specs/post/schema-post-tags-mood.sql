-- SPEC copy of supabase/migrations/20261021120000_post_tags_mood.sql (keep in sync; the migration is the source that gets applied).
-- NOT yet validated or applied. Validate in a rolled-back transaction; apply only after the user approves.
-- =====================================================================
-- Pulse · Post tags, feeling / activity, comments-off card data
-- Depends on: 20261012120000_home_feed, 20261013140000_post_options,
--             20261014120000_notifications, 20261018120000_post_visibility,
--             20261020120000_edit_post. Do not re-apply earlier migrations.
-- Adds:
--   posts.mood_kind / mood_key / mood_text      feeling or activity (S8, S9)
--   profiles.allow_tags                         everyone | following | none
--   post_tags                                   who is tagged, optional spot on one photo (S6, S7)
--   tag_removals                                24 h cool-down after someone removes their own tag
--   RPCs  can_tag, tag_search, post_tagged_people, remove_my_tag, tagged_posts
--   create_post / update_post                   take mood + tags
--   home_feed                                   returns mood, tags, i_am_tagged
--   notifications.type 'tag'                    row written by a trigger; UI comes with Activity
-- Docs: docs/specs/post/screens/s6..s10, s11-remove-tag.md.
-- TODO (blocking is not built yet): tag_search / can_tag must also skip blocked accounts.
-- =====================================================================

-- 1. Feeling / activity on the post.
--    feeling  -> mood_key from the feelings list, mood_text null
--    activity -> mood_key a verb, mood_text = what (1..60), required
--    (activities have no UI yet; the check keeps the shape ready. TODO)
alter table public.posts
  add column mood_kind text,
  add column mood_key  text,
  add column mood_text text,
  add constraint posts_mood_valid check (
    (mood_kind is null and mood_key is null and mood_text is null)
    or (mood_kind = 'feeling'
        and mood_key in ('happy','excited','loved','relaxed','grateful','motivated','cool',
                         'amazed','tired','sad','determined','sick','funny','blessed')
        and mood_text is null)
    or (mood_kind = 'activity'
        and mood_key in ('celebrating','watching','eating','drinking','traveling','listening',
                         'reading','playing','working_out','attending')
        and mood_text is not null and char_length(mood_text) between 1 and 60)
  );

-- 2. Who may tag me. 'following' = only people I follow.
alter table public.profiles
  add column allow_tags text not null default 'everyone',
  add constraint profiles_allow_tags_valid check (allow_tags in ('everyone', 'following', 'none'));
grant update (allow_tags) on public.profiles to authenticated;

-- 3. Tags. One row per tagged person; media_position/x/y are all null (tagged in
--    the post only) or all set (a spot on that photo, x/y in 0..1).
create table public.post_tags (
  post_id        uuid not null references public.posts (id) on delete cascade,
  user_id        uuid not null references public.profiles (id) on delete cascade,
  media_position smallint,
  x              real,
  y              real,
  created_at     timestamptz not null default now(),
  primary key (post_id, user_id),
  constraint post_tags_spot check (
    (media_position is null and x is null and y is null)
    or (media_position between 0 and 9 and x between 0 and 1 and y between 0 and 1)
  )
);
create index post_tags_user_idx on public.post_tags (user_id, created_at desc);
alter table public.post_tags enable row level security;
-- Reads go through the RPCs below (they check can_view_post); no direct policies.

create table public.tag_removals (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  removed_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
alter table public.tag_removals enable row level security;

-- 4. Notifications: a tag is a notification type.
alter table public.notifications drop constraint notifications_type;
alter table public.notifications add constraint notifications_type check (type in (
  'follow', 'follow_request', 'follow_accepted',
  'like', 'comment', 'reply', 'mention', 'tag'
));

create or replace function public.notify_on_tag()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_author uuid;
begin
  select author_id into v_author from public.posts where id = new.post_id;
  perform public.notify(new.user_id, 'tag', v_author, 'tag:' || new.post_id, new.post_id);
  return null;
end;
$$;
create trigger post_tags_notify
  after insert on public.post_tags
  for each row execute function public.notify_on_tag();

-- 5. Can I (the caller) tag this person?
create or replace function public.can_tag(p_user uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select auth.uid() is not null
     and p_user <> auth.uid()
     and exists (
       select 1 from public.profiles pr
       where pr.id = p_user and pr.signup_step = 0
         and case pr.allow_tags
               when 'everyone' then true
               when 'following' then exists (
                 select 1 from public.follows f
                 where f.follower_id = p_user and f.following_id = auth.uid()
                   and f.status = 'accepted')
               else false
             end
     );
$$;
revoke all on function public.can_tag(uuid) from public, anon;
grant execute on function public.can_tag(uuid) to authenticated;

-- 6. S6: suggested (blank query) or search. Followers + people I follow (accepted).
--    Blank query: people I follow, newest follow first. A person who does not allow
--    tags is returned with can_tag = false (shown disabled).
create or replace function public.tag_search(p_q text default null, p_limit int default 30)
returns table (id uuid, username text, full_name text, avatar_url text, can_tag boolean)
language sql
stable
security definer
set search_path = ''
as $$
  with q as (select nullif(btrim(p_q), '') as t),
  pool as (
    select f.following_id as uid, f.created_at as at, 0 as rank
    from public.follows f
    where f.follower_id = auth.uid() and f.status = 'accepted'
    union all
    select f.follower_id, f.created_at, 1
    from public.follows f
    where f.following_id = auth.uid() and f.status = 'accepted'
  ),
  people as (
    select uid, min(rank) as rank, max(at) as at from pool group by uid
  )
  select pr.id, pr.username::text, pr.full_name, pr.avatar_url, public.can_tag(pr.id)
  from people pe
  join public.profiles pr on pr.id = pe.uid and pr.signup_step = 0
  cross join q
  where pe.uid <> auth.uid()
    and (q.t is null
         or pr.username ilike replace(replace(q.t, '%', ''), '_', '\_') || '%'
         or pr.full_name ilike '%' || replace(replace(q.t, '%', ''), '_', '\_') || '%')
    and (q.t is not null or pe.rank = 0)
  order by case when q.t is null then pe.at end desc nulls last, pr.username
  limit least(greatest(coalesce(p_limit, 30), 1), 50);
$$;
revoke all on function public.tag_search(text, int) from public, anon;
grant execute on function public.tag_search(text, int) to authenticated;

-- 7. S10: everyone tagged on a post I can see. follow_state: none | pending | following | me.
create or replace function public.post_tagged_people(p_post uuid)
returns table (id uuid, username text, full_name text, avatar_url text, follow_state text)
language sql
stable
security definer
set search_path = ''
as $$
  select pr.id, pr.username::text, pr.full_name, pr.avatar_url,
         case
           when pr.id = auth.uid() then 'me'
           else coalesce((select case f.status when 'accepted' then 'following' else 'pending' end
                          from public.follows f
                          where f.follower_id = auth.uid() and f.following_id = pr.id), 'none')
         end
  from public.post_tags t
  join public.posts p on p.id = t.post_id
  join public.profiles pr on pr.id = t.user_id
  where t.post_id = p_post
    and public.can_view_post(p.author_id, p.visibility)
  order by t.created_at, pr.username;
$$;
revoke all on function public.post_tagged_people(uuid) from public, anon;
grant execute on function public.post_tagged_people(uuid) to authenticated;

-- 8. Remove my tag (from the post and every photo on it). false = I was not tagged.
--    Deletes my tag notification, starts the 24 h cool-down, tells the owner nothing.
create or replace function public.remove_my_tag(p_post uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_deleted int;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  delete from public.post_tags where post_id = p_post and user_id = v_uid;
  get diagnostics v_deleted = row_count;
  if v_deleted = 0 then
    return false;
  end if;
  insert into public.tag_removals (post_id, user_id) values (p_post, v_uid)
  on conflict (post_id, user_id) do update set removed_at = now();
  delete from public.notifications where recipient_id = v_uid and group_key = 'tag:' || p_post;
  return true;
end;
$$;
revoke all on function public.remove_my_tag(uuid) from public, anon;
grant execute on function public.remove_my_tag(uuid) to authenticated;

-- 9. Profile "Tagged" tab (the profile spec will style it): posts a person is tagged in
--    that the CALLER can see. Light rows for grid tiles.
create or replace function public.tagged_posts(
  p_user uuid,
  p_limit int default 30,
  p_before_created timestamptz default null,
  p_before_id uuid default null
)
returns table (post_id uuid, author_id uuid, username text, tagged_at timestamptz, created_at timestamptz, media jsonb)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.author_id, pr.username::text, t.created_at, p.created_at,
         coalesce((select jsonb_agg(jsonb_build_object(
                     'position', m.position, 'type', m.type, 'path', m.path,
                     'thumb_path', m.thumb_path, 'width', m.width, 'height', m.height,
                     'blurhash', m.blurhash) order by m.position)
                   from public.post_media m where m.post_id = p.id and m.position = 0), '[]'::jsonb)
  from public.post_tags t
  join public.posts p on p.id = t.post_id and p.kind = 'post'
  join public.profiles pr on pr.id = p.author_id
  where t.user_id = p_user
    and public.can_view_post(p.author_id, p.visibility)
    and (p_before_created is null
         or (p.created_at, p.id) < (p_before_created,
                                    coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid)))
  order by p.created_at desc, p.id desc
  limit least(greatest(coalesce(p_limit, 30), 1), 50);
$$;
revoke all on function public.tagged_posts(uuid, int, timestamptz, uuid) from public, anon;
grant execute on function public.tagged_posts(uuid, int, timestamptz, uuid) to authenticated;

-- 10. (removed) Activity suggestions: activities are deferred; the source (API or database) is decided later. TODO.

-- 10. Shared helper: validate and store a post's tags (used by create_post and update_post).
--     p_tags = [{user_id, media_position?, x?, y?}], max 20, no duplicates, not the author,
--     only people the author can tag, and not inside their 24 h cool-down for this post.
--     People who cannot be tagged are dropped silently (the app disables them already).
--     Replaces the set: people not in the list lose their tag WITHOUT a notification;
--     new people get the 'tag' notification from the trigger.
create or replace function public.store_post_tags(p_post uuid, p_author uuid, p_tags jsonb, p_media_count int)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_tags jsonb := coalesce(p_tags, '[]'::jsonb);
  v_item jsonb;
  v_user uuid;
  v_pos  int;
begin
  if jsonb_typeof(v_tags) <> 'array' then
    raise exception 'tags must be an array' using errcode = '22023';
  end if;
  if jsonb_array_length(v_tags) > 20 then
    raise exception 'at most 20 tags' using errcode = 'check_violation';
  end if;

  delete from public.post_tags t
  where t.post_id = p_post
    and not exists (select 1 from jsonb_array_elements(v_tags) e
                    where (e->>'user_id')::uuid = t.user_id);
  delete from public.notifications n
  where n.type = 'tag' and n.post_id = p_post
    and not exists (select 1 from public.post_tags t where t.post_id = p_post and t.user_id = n.recipient_id);

  for v_item in select value from jsonb_array_elements(v_tags) loop
    v_user := (v_item->>'user_id')::uuid;
    v_pos := (v_item->>'media_position')::int;
    continue when v_user = p_author;
    -- can_tag() reads auth.uid(), the author; people already tagged keep their tag
    continue when not public.can_tag(v_user)
                  and not exists (select 1 from public.post_tags where post_id = p_post and user_id = v_user);
    continue when exists (select 1 from public.tag_removals r
                          where r.post_id = p_post and r.user_id = v_user
                            and r.removed_at > now() - interval '24 hours');
    if v_pos is not null and v_pos >= p_media_count then
      raise exception 'tag spot is on a photo that does not exist' using errcode = 'check_violation';
    end if;
    insert into public.post_tags (post_id, user_id, media_position, x, y)
    values (p_post, v_user, v_pos, (v_item->>'x')::real, (v_item->>'y')::real)
    on conflict (post_id, user_id) do update
      set media_position = excluded.media_position, x = excluded.x, y = excluded.y;
  end loop;
end;
$$;
revoke all on function public.store_post_tags(uuid, uuid, jsonb, int) from public, anon, authenticated;

-- 11. create_post: + p_mood_kind, p_mood_key, p_mood_text, p_tags. Body as in
--     20261018120000_post_visibility.sql otherwise.
drop function public.create_post(uuid, text, text, text, jsonb, boolean, text);
create function public.create_post(
  p_id               uuid,
  p_kind             text default 'post',
  p_caption          text default null,
  p_location         text default null,
  p_media            jsonb default '[]'::jsonb,
  p_comments_enabled boolean default true,
  p_visibility       text default null,
  p_mood_kind        text default null,
  p_mood_key         text default null,
  p_mood_text        text default null,
  p_tags             jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := auth.uid();
  v_prefix     text;
  v_count      int;
  v_caption    text := nullif(btrim(p_caption), '');
  v_loc        text := nullif(btrim(p_location), '');
  v_mood_text  text := nullif(btrim(p_mood_text), '');
  v_item       jsonb;
  v_visibility text;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not exists (select 1 from public.profiles where id = v_uid and signup_step = 0) then
    raise exception 'finish sign-up first' using errcode = '42501';
  end if;
  if p_id is null or p_kind not in ('post', 'short') then
    raise exception 'invalid post' using errcode = '22023';
  end if;
  if p_visibility is not null
     and p_visibility not in ('public', 'followers', 'close_friends', 'only_me') then
    raise exception 'invalid visibility' using errcode = '22023';
  end if;
  if jsonb_typeof(coalesce(p_media, '[]'::jsonb)) <> 'array' then
    raise exception 'media must be an array' using errcode = '22023';
  end if;

  select coalesce(p_visibility, pr.default_post_visibility) into v_visibility
  from public.profiles pr where pr.id = v_uid;
  if v_visibility = 'public'
     and exists (select 1 from public.profiles where id = v_uid and is_private) then
    v_visibility := 'followers';
  end if;

  v_count := jsonb_array_length(coalesce(p_media, '[]'::jsonb));
  if v_count > 10 then
    raise exception 'at most 10 media items' using errcode = 'check_violation';
  end if;
  if p_kind = 'short' and (v_count <> 1 or p_media->0->>'type' <> 'video') then
    raise exception 'a short is exactly one video' using errcode = 'check_violation';
  end if;

  v_prefix := v_uid::text || '/' || p_id::text || '/';
  for v_item in select value from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) loop
    if coalesce(v_item->>'path', '') not like v_prefix || '%'
       or (v_item ? 'thumb_path' and v_item->>'thumb_path' is not null
           and v_item->>'thumb_path' not like v_prefix || '%') then
      raise exception 'media path must be under %', v_prefix using errcode = '42501';
    end if;
    if not exists (select 1 from storage.objects o
                   where o.bucket_id = 'post-media' and o.name = v_item->>'path') then
      raise exception 'media file not uploaded: %', v_item->>'path' using errcode = '22023';
    end if;
  end loop;

  -- posts_mood_valid rejects a bad kind / key / text.
  insert into public.posts (id, author_id, kind, caption, location, media_count, comments_enabled,
                            visibility, mood_kind, mood_key, mood_text)
  values (p_id, v_uid, p_kind, v_caption, v_loc, v_count, coalesce(p_comments_enabled, true),
          v_visibility, p_mood_kind, p_mood_key, v_mood_text);

  insert into public.post_media (post_id, position, type, path, thumb_path, width, height, duration_ms, blurhash)
  select p_id, (e.ord - 1)::smallint, e.item->>'type', e.item->>'path', e.item->>'thumb_path',
         (e.item->>'width')::int, (e.item->>'height')::int,
         (e.item->>'duration_ms')::int, e.item->>'blurhash'
  from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) with ordinality as e(item, ord);

  perform public.store_post_tags(p_id, v_uid, p_tags, v_count);
  return p_id;
end;
$$;
revoke all on function public.create_post(uuid, text, text, text, jsonb, boolean, text, text, text, text, jsonb) from public, anon;
grant execute on function public.create_post(uuid, text, text, text, jsonb, boolean, text, text, text, text, jsonb) to authenticated;

-- 12. update_post: + mood and tags (replaced as a whole, like the media list).
drop function public.update_post(uuid, text, text, jsonb);
create function public.update_post(
  p_id        uuid,
  p_caption   text default null,
  p_location  text default null,
  p_media     jsonb default '[]'::jsonb,
  p_mood_kind text default null,
  p_mood_key  text default null,
  p_mood_text text default null,
  p_tags      jsonb default '[]'::jsonb
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := auth.uid();
  v_prefix    text;
  v_count     int;
  v_caption   text := nullif(btrim(p_caption), '');
  v_loc       text := nullif(btrim(p_location), '');
  v_mood_text text := nullif(btrim(p_mood_text), '');
  v_item      jsonb;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not exists (select 1 from public.posts where id = p_id and author_id = v_uid and kind = 'post') then
    raise exception 'not your post' using errcode = '42501';
  end if;
  if jsonb_typeof(coalesce(p_media, '[]'::jsonb)) <> 'array' then
    raise exception 'media must be an array' using errcode = '22023';
  end if;

  v_count := jsonb_array_length(coalesce(p_media, '[]'::jsonb));
  if v_count > 10 then
    raise exception 'at most 10 media items' using errcode = 'check_violation';
  end if;

  v_prefix := v_uid::text || '/' || p_id::text || '/';
  for v_item in select value from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) loop
    if coalesce(v_item->>'path', '') not like v_prefix || '%'
       or (v_item ? 'thumb_path' and v_item->>'thumb_path' is not null
           and v_item->>'thumb_path' not like v_prefix || '%') then
      raise exception 'media path must be under %', v_prefix using errcode = '42501';
    end if;
    if not exists (select 1 from storage.objects o
                   where o.bucket_id = 'post-media' and o.name = v_item->>'path') then
      raise exception 'media file not uploaded: %', v_item->>'path' using errcode = '22023';
    end if;
  end loop;

  update public.posts
  set caption = v_caption, location = v_loc, media_count = v_count,
      mood_kind = p_mood_kind, mood_key = p_mood_key, mood_text = v_mood_text
  where id = p_id;

  delete from public.post_media where post_id = p_id;
  insert into public.post_media (post_id, position, type, path, thumb_path, width, height, duration_ms, blurhash)
  select p_id, (e.ord - 1)::smallint, e.item->>'type', e.item->>'path', e.item->>'thumb_path',
         (e.item->>'width')::int, (e.item->>'height')::int,
         (e.item->>'duration_ms')::int, e.item->>'blurhash'
  from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) with ordinality as e(item, ord);

  -- A tag whose photo was removed becomes a post-only tag (spot cleared).
  perform public.store_post_tags(p_id, v_uid, p_tags, v_count);
end;
$$;
revoke all on function public.update_post(uuid, text, text, jsonb, text, text, text, jsonb) from public, anon;
grant execute on function public.update_post(uuid, text, text, jsonb, text, text, text, jsonb) to authenticated;

-- 13. home_feed: + mood_kind, mood_key, mood_text, tag_count, tags, i_am_tagged.
--     tags = [{user_id, username, full_name, media_position, x, y}] in tag order (max 20);
--     the headline uses the first 2 names + tag_count, the labels use the positions.
drop function public.home_feed(int, timestamptz, uuid);
create function public.home_feed(
  p_limit          int default 20,
  p_before_created timestamptz default null,
  p_before_id      uuid default null
)
returns table (
  id               uuid,
  author_id        uuid,
  username         text,
  full_name        text,
  avatar_url       text,
  caption          text,
  location         text,
  like_count       integer,
  comment_count    integer,
  comments_enabled boolean,
  visibility       text,
  created_at       timestamptz,
  liked_by_me      boolean,
  saved_by_me      boolean,
  media            jsonb,
  mood_kind        text,
  mood_key         text,
  mood_text        text,
  tag_count        integer,
  tags             jsonb,
  i_am_tagged      boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  with page as (
    select p.*
    from public.posts p
    where p.kind = 'post'
      and (
        p.author_id = auth.uid()
        or exists (select 1 from public.follows f
                   where f.follower_id = auth.uid()
                     and f.following_id = p.author_id
                     and f.status = 'accepted')
      )
      and public.can_view_post(p.author_id, p.visibility)
      and not exists (select 1 from public.post_hides h
                      where h.user_id = auth.uid() and h.post_id = p.id)
      and not exists (select 1 from public.mutes m
                      where m.user_id = auth.uid() and m.muted_id = p.author_id)
      and (
        p_before_created is null
        or (p.created_at, p.id) < (p_before_created,
                                   coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid))
      )
    order by p.created_at desc, p.id desc
    limit least(greatest(coalesce(p_limit, 20), 1), 50)
  )
  select pg.id, pg.author_id, pr.username::text, pr.full_name, pr.avatar_url,
         pg.caption, pg.location, pg.like_count, pg.comment_count, pg.comments_enabled,
         pg.visibility, pg.created_at,
         exists (select 1 from public.post_likes l where l.post_id = pg.id and l.user_id = auth.uid()),
         exists (select 1 from public.post_saves s where s.post_id = pg.id and s.user_id = auth.uid()),
         coalesce((
           select jsonb_agg(jsonb_build_object(
                    'position', m.position, 'type', m.type, 'path', m.path,
                    'thumb_path', m.thumb_path, 'width', m.width, 'height', m.height,
                    'duration_ms', m.duration_ms, 'blurhash', m.blurhash)
                  order by m.position)
           from public.post_media m where m.post_id = pg.id
         ), '[]'::jsonb),
         pg.mood_kind, pg.mood_key, pg.mood_text,
         (select count(*)::int from public.post_tags t where t.post_id = pg.id),
         coalesce((
           select jsonb_agg(jsonb_build_object(
                    'user_id', t.user_id, 'username', tp.username, 'full_name', tp.full_name,
                    'media_position', t.media_position, 'x', t.x, 'y', t.y)
                  order by t.created_at, tp.username)
           from public.post_tags t
           join public.profiles tp on tp.id = t.user_id
           where t.post_id = pg.id
         ), '[]'::jsonb),
         exists (select 1 from public.post_tags t where t.post_id = pg.id and t.user_id = auth.uid())
  from page pg
  join public.profiles pr on pr.id = pg.author_id
  order by pg.created_at desc, pg.id desc;
$$;
revoke all on function public.home_feed(int, timestamptz, uuid) from public, anon;
grant execute on function public.home_feed(int, timestamptz, uuid) to authenticated;
