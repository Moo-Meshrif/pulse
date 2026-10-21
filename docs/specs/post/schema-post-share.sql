-- SPEC copy of supabase/migrations/20261021120000_post_share.sql (keep in sync; the migration is what gets applied).
-- Validated in a rolled-back batch, then applied 2026-10-21 (B11).
-- Pulse · Share a post to your feed (S12) and put a post on a story (S13).
-- Spec copy: docs/specs/post/schema-post-share.sql (keep both in sync).
-- Adds:
--   posts.shared_post_id / is_share     a share embeds an original (shared_post_id is set null when the
--                                       original is deleted; is_share stays so the card shows "unavailable")
--   post_embed(post)                    the original's feed columns as json, or null when you can't see it
--   share_to_feed(...)                  creates a share of a Public post
--   notifications.type 'share'          one row per original post
--   home_feed                           + is_share, shared_post_id, shared_post
--   stories.shared_post_id / sticker    a post sticker on a story (shared through share_content)
--   check_story_post(...)               the rules for that sticker; share_content and publish_pending call it
--   author_stories                      + shared_post_id, sticker, shared_post
-- Not built (needs Chat tables): share_targets, share_post.

-- 1. Posts: a share has no media of its own and may have no caption.
alter table public.posts
  add column shared_post_id uuid references public.posts (id) on delete set null,
  add column is_share boolean not null default false,
  add constraint posts_shared_not_self check (shared_post_id is null or shared_post_id <> id),
  add constraint posts_share_flag check (shared_post_id is null or is_share),
  add constraint posts_share_no_media check (not is_share or media_count = 0);
create index posts_shared_post_idx on public.posts (shared_post_id) where shared_post_id is not null;

alter table public.posts drop constraint posts_has_content;
alter table public.posts add constraint posts_has_content
  check (caption is not null or media_count > 0 or is_share);

-- A share never gets media rows (create_post, update_post and direct inserts all go through here).
create or replace function public.post_media_not_on_share()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (select 1 from public.posts p where p.id = new.post_id and p.is_share) then
    raise exception 'a shared post has no media' using errcode = 'check_violation';
  end if;
  return new;
end;
$$;
create trigger post_media_not_on_share
  before insert on public.post_media
  for each row execute function public.post_media_not_on_share();
revoke all on function public.post_media_not_on_share() from public, anon, authenticated;

-- 2. The original of a share (or a story sticker) as the feed columns, or null when it does not exist or
--    the caller can't see it. Counts and like / save state are not included: the card does not show them.
create or replace function public.post_embed(p_post uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', p.id, 'author_id', p.author_id, 'username', pr.username, 'full_name', pr.full_name,
    'avatar_url', pr.avatar_url, 'caption', p.caption, 'location', p.location,
    'visibility', p.visibility, 'created_at', p.created_at,
    'media', coalesce((
      select jsonb_agg(jsonb_build_object(
               'position', m.position, 'type', m.type, 'path', m.path,
               'thumb_path', m.thumb_path, 'width', m.width, 'height', m.height,
               'duration_ms', m.duration_ms, 'blurhash', m.blurhash)
             order by m.position)
      from public.post_media m where m.post_id = p.id
    ), '[]'::jsonb),
    'mood_kind', p.mood_kind, 'mood_key', p.mood_key, 'mood_text', p.mood_text,
    'tag_count', (select count(*)::int from public.post_tags t where t.post_id = p.id),
    'tags', coalesce((
      select jsonb_agg(jsonb_build_object(
               'user_id', t.user_id, 'username', tp.username, 'full_name', tp.full_name,
               'media_position', t.media_position, 'x', t.x, 'y', t.y)
             order by t.created_at, tp.username)
      from public.post_tags t
      join public.profiles tp on tp.id = t.user_id
      where t.post_id = p.id
    ), '[]'::jsonb))
  from public.posts p
  join public.profiles pr on pr.id = p.author_id
  where p.id = p_post
    and not p.is_share
    and public.can_view_post(p.author_id, p.visibility);
$$;
revoke all on function public.post_embed(uuid) from public, anon;
grant execute on function public.post_embed(uuid) to authenticated;

-- 3. Share to feed. Public originals only; a share of a share resolves to its original.
--    Same shapes as create_post (mood, location, tags); tags have no media position (a share has no photo).
--    Errors: 42501 not signed in / sign-up unfinished, P0002 post_unavailable, 22023 bad input,
--    check_violation caption over 2000 or a tag spot.
create or replace function public.share_to_feed(
  p_post       uuid,
  p_caption    text default null,
  p_visibility text default null,
  p_mood_kind  text default null,
  p_mood_key   text default null,
  p_mood_text  text default null,
  p_location   text default null,
  p_tags       jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := auth.uid();
  v_given      public.posts;
  v_orig       uuid;
  v_caption    text := nullif(btrim(p_caption), '');
  v_visibility text;
  v_id         uuid := gen_random_uuid();
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not exists (select 1 from public.profiles where id = v_uid and signup_step = 0) then
    raise exception 'finish sign-up first' using errcode = '42501';
  end if;
  if p_visibility is not null
     and p_visibility not in ('public', 'followers', 'close_friends', 'only_me') then
    raise exception 'invalid visibility' using errcode = '22023';
  end if;
  if v_caption is not null and char_length(v_caption) > 2000 then
    raise exception 'caption is at most 2000 characters' using errcode = 'check_violation';
  end if;
  if jsonb_typeof(coalesce(p_tags, '[]'::jsonb)) <> 'array' then
    raise exception 'tags must be an array' using errcode = '22023';
  end if;
  if exists (select 1 from jsonb_array_elements(coalesce(p_tags, '[]'::jsonb)) e
             where e.value->>'media_position' is not null) then
    raise exception 'a share has no photo to tag' using errcode = 'check_violation';
  end if;

  select * into v_given from public.posts where id = p_post;
  if not found then
    raise exception 'post_unavailable' using errcode = 'P0002';
  end if;
  v_orig := case when v_given.is_share then v_given.shared_post_id else v_given.id end;
  if v_orig is null
     or not exists (select 1 from public.posts o
                    where o.id = v_orig and o.visibility = 'public' and not o.is_share
                      and public.can_view_post(o.author_id, o.visibility)) then
    raise exception 'post_unavailable' using errcode = 'P0002';
  end if;

  v_visibility := public.pending_post_visibility(v_uid, p_visibility);

  -- posts_mood_valid and posts_location_len reject a bad mood or place.
  insert into public.posts (id, author_id, kind, caption, location, media_count, comments_enabled,
                            visibility, mood_kind, mood_key, mood_text, shared_post_id, is_share)
  values (v_id, v_uid, 'post', v_caption, nullif(btrim(p_location), ''), 0, true,
          v_visibility, p_mood_kind, p_mood_key, nullif(btrim(p_mood_text), ''), v_orig, true);

  perform public.store_post_tags(v_id, v_uid, p_tags, 0);
  return v_id;
end;
$$;
revoke all on function public.share_to_feed(uuid, text, text, text, text, text, text, jsonb) from public, anon;
grant execute on function public.share_to_feed(uuid, text, text, text, text, text, text, jsonb) to authenticated;

-- 4. Notification: the original's author hears about a share (one row per original post; notify skips yourself).
alter table public.notifications drop constraint notifications_type;
alter table public.notifications add constraint notifications_type check (type in (
  'follow', 'follow_request', 'follow_accepted',
  'like', 'comment', 'reply', 'mention', 'tag', 'share'
));

create or replace function public.notify_on_share()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform public.notify(
    (select o.author_id from public.posts o where o.id = new.shared_post_id),
    'share', new.author_id, 'share:' || new.shared_post_id, new.shared_post_id);
  return new;
end;
$$;
create trigger posts_notify_share
  after insert on public.posts
  for each row when (new.shared_post_id is not null)
  execute function public.notify_on_share();
revoke all on function public.notify_on_share() from public, anon, authenticated;

-- 5. home_feed: + is_share, shared_post_id, shared_post. Otherwise as in 20261015162526_post_tags_mood.sql.
--    A share has no media; its counts and like / save state are its own.
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
  i_am_tagged      boolean,
  is_share         boolean,
  shared_post_id   uuid,
  shared_post      jsonb
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
         exists (select 1 from public.post_tags t where t.post_id = pg.id and t.user_id = auth.uid()),
         pg.is_share,
         pg.shared_post_id,
         case when pg.shared_post_id is not null then public.post_embed(pg.shared_post_id) end
  from page pg
  join public.profiles pr on pr.id = pg.author_id
  order by pg.created_at desc, pg.id desc;
$$;
revoke all on function public.home_feed(int, timestamptz, uuid) from public, anon;
grant execute on function public.home_feed(int, timestamptz, uuid) to authenticated;

-- 6. Stories: a post sticker. shared_post_id is set null when the post is deleted, the sticker stays
--    (the viewer shows "Post unavailable"). The columns are not in the client's insert grant: only
--    share_content / publish_pending write them.
alter table public.stories
  add column shared_post_id uuid references public.posts (id) on delete set null,
  add column sticker jsonb;

-- The rules for a post sticker on a story by p_author (the signed-in user). Both null = no sticker.
--   post: Public, or your own Public / Followers; never a share (the sticker is for the original).
--   audience: the story's audience can't be wider than the post's; stories are Followers or Close
--   friends, which is never wider than Public or Followers.
--   sticker: {style: card|media|compact, x, y (0..1), scale, rotation, bg: {kind, colors[]}}.
create or replace function public.check_story_post(
  p_author uuid, p_post uuid, p_sticker jsonb, p_audience text
)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_post public.posts;
begin
  if p_post is null and p_sticker is null then
    return;
  end if;
  if p_post is null or jsonb_typeof(p_sticker) is distinct from 'object' then
    raise exception 'a post sticker needs a post and a sticker' using errcode = '22023';
  end if;
  if p_audience not in ('followers', 'close_friends') then
    raise exception 'invalid audience' using errcode = '22023';
  end if;
  if p_sticker->>'style' is null or p_sticker->>'style' not in ('card', 'media', 'compact')
     or jsonb_typeof(p_sticker->'x') <> 'number' or (p_sticker->>'x')::numeric not between 0 and 1
     or jsonb_typeof(p_sticker->'y') <> 'number' or (p_sticker->>'y')::numeric not between 0 and 1
     or jsonb_typeof(p_sticker->'scale') <> 'number' or (p_sticker->>'scale')::numeric not between 0.1 and 10
     or jsonb_typeof(p_sticker->'rotation') <> 'number'
     or jsonb_typeof(p_sticker->'bg') <> 'object'
     or jsonb_typeof(p_sticker->'bg'->'kind') <> 'string'
     or jsonb_typeof(p_sticker->'bg'->'colors') <> 'array'
     or jsonb_array_length(p_sticker->'bg'->'colors') > 8 then
    raise exception 'invalid sticker' using errcode = '22023';
  end if;

  select * into v_post from public.posts where id = p_post;
  if not found or v_post.is_share then
    raise exception 'post_unavailable' using errcode = 'P0002';
  end if;
  if v_post.author_id = p_author then
    if v_post.visibility not in ('public', 'followers') then
      raise exception 'post_not_shareable' using errcode = '22023';
    end if;
  elsif v_post.visibility <> 'public' or not public.can_view_post(v_post.author_id, v_post.visibility) then
    raise exception 'post_not_shareable' using errcode = '22023';
  end if;
end;
$$;
revoke all on function public.check_story_post(uuid, uuid, jsonb, text) from public, anon, authenticated;

-- author_stories: + shared_post_id, sticker, shared_post (null = unavailable). Otherwise as in
-- 20261013205633_story_audience.sql.
drop function public.author_stories(uuid);
create function public.author_stories(p_author uuid)
returns table (
  id             uuid,
  type           text,
  path           text,
  thumb_path     text,
  width          integer,
  height         integer,
  duration_ms    integer,
  blurhash       text,
  overlays       jsonb,
  created_at     timestamptz,
  expires_at     timestamptz,
  seen_by_me     boolean,
  liked_by_me    boolean,
  view_count     integer,
  audience       text,
  sticker        jsonb,
  shared_post    jsonb
)
language sql
stable
set search_path = ''
as $$
  select s.id, s.type, s.path, s.thumb_path, s.width, s.height, s.duration_ms, s.blurhash,
         s.overlays, s.created_at, s.expires_at,
         exists (select 1 from public.story_views v where v.story_id = s.id and v.viewer_id = auth.uid()),
         exists (select 1 from public.story_likes l where l.story_id = s.id and l.user_id = auth.uid()),
         case when s.author_id = auth.uid()
              then (select count(*)::int from public.story_views v where v.story_id = s.id)
              else null end,
         s.audience,
         s.sticker,
         case when s.shared_post_id is not null then public.post_embed(s.shared_post_id) end
  from public.stories s
  where s.author_id = p_author
    and (s.author_id = auth.uid() or s.expires_at > now())
  order by s.created_at asc;
$$;
revoke all on function public.author_stories(uuid) from public, anon;
grant execute on function public.author_stories(uuid) to authenticated;

-- 7. share_content / publish_pending: a story request may carry shared_post_id and sticker.
--    Story request: {..., audience, shared_post_id, sticker}. Bodies otherwise as in
--    20261020132458_content_publishing.sql.

create or replace function public.share_content(p_id uuid, p_kind text, p_request jsonb)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := public.pending_caller();
  v_row        public.pending_content;
  v_visibility text;
begin
  if p_id is null or p_kind not in ('post', 'short', 'story') then
    raise exception 'invalid content' using errcode = '22023';
  end if;
  if jsonb_typeof(p_request) is distinct from 'object' or octet_length(p_request::text) > 65536 then
    raise exception 'request must be an object of at most 64 KB' using errcode = '22023';
  end if;
  perform 1 from public.pending_expected_files(p_kind, v_uid, p_id, p_request);
  if p_kind = 'story' and coalesce(p_request->>'audience', 'followers') not in ('followers', 'close_friends') then
    raise exception 'invalid audience' using errcode = '22023';
  end if;
  if p_kind = 'story' then
    perform public.check_story_post(v_uid, nullif(p_request->>'shared_post_id', '')::uuid,
                                    nullif(p_request->'sticker', 'null'::jsonb),
                                    coalesce(p_request->>'audience', 'followers'));
  end if;
  v_visibility := case when p_kind <> 'story'
                       then public.pending_post_visibility(v_uid, p_request->>'visibility') end;

  -- One share at a time per author, so the waiting limit holds.
  perform 1 from public.profiles where id = v_uid for update;

  v_row := public.pending_lock(p_id, v_uid);
  if v_row.id is not null and v_row.kind <> p_kind then
    raise exception 'kind does not match' using errcode = '22023';
  end if;
  if v_row.state in ('waiting', 'published') then
    if v_row.request = p_request then
      return v_row.state;
    end if;
    raise exception 'already shared with a different request' using errcode = '22023';
  end if;
  if v_row.id is not null and v_row.state <> 'draft' then
    raise exception 'this content can no longer be shared (%)', v_row.state using errcode = '55000';
  end if;
  if (select count(*) from public.pending_content
      where author_id = v_uid and state = 'waiting') >= 3 then
    raise exception 'at most 3 waiting' using errcode = '53400';
  end if;

  insert into public.pending_content (id, author_id, kind, state, request, visibility, shared_at)
  values (p_id, v_uid, p_kind, 'waiting', p_request, v_visibility, clock_timestamp())
  on conflict (id) do update
    set state = 'waiting', request = excluded.request, visibility = excluded.visibility,
        shared_at = excluded.shared_at, updated_at = now();
  return 'waiting';
end;
$$;

create or replace function public.publish_pending(p_id uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row        public.pending_content;
  v_r          jsonb;
  v_media      jsonb;
  v_old_claims text := current_setting('request.jwt.claims', true);
  v_old_sub    text := current_setting('request.jwt.claim.sub', true);
  v_code       text;
begin
  select * into v_row from public.pending_content where id = p_id for update;
  if not found then
    return null;
  end if;
  if v_row.state <> 'waiting' then
    return v_row.state;
  end if;

  if public.pending_is_posted(v_row.kind, v_row.id) then
    update public.pending_content
    set state = 'published', finished_at = now(), updated_at = now()
    where id = p_id;
    return 'published';
  end if;
  if cardinality(public.pending_missing_files(v_row.kind, v_row.author_id, v_row.id, v_row.request)) > 0 then
    return 'waiting';
  end if;
  -- Posts go out in the order they were shared.
  if v_row.kind <> 'story' and exists (
       select 1 from public.pending_content o
       where o.author_id = v_row.author_id and o.kind <> 'story' and o.state = 'waiting'
         and (o.shared_at, o.id) < (v_row.shared_at, v_row.id)) then
    return 'waiting';
  end if;

  perform set_config('request.jwt.claims',
                     json_build_object('sub', v_row.author_id, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', v_row.author_id::text, true);

  v_r := v_row.request;
  begin
    if v_row.kind = 'story' then
      -- Paths were checked against {uid}/stories/{id} when shared; the 24 hours start now.
      perform public.check_story_post(v_row.author_id, nullif(v_r->>'shared_post_id', '')::uuid,
                                      nullif(v_r->'sticker', 'null'::jsonb),
                                      coalesce(v_r->>'audience', 'followers'));
      insert into public.stories (id, author_id, type, path, thumb_path, width, height, duration_ms,
                                  blurhash, overlays, audience, shared_post_id, sticker)
      values (v_row.id, v_row.author_id, v_r->>'type', v_r->>'path', v_r->>'thumb_path',
              (v_r->>'width')::int, (v_r->>'height')::int, (v_r->>'duration_ms')::int,
              v_r->>'blurhash', coalesce(v_r->'overlays', '[]'::jsonb),
              coalesce(v_r->>'audience', 'followers'),
              nullif(v_r->>'shared_post_id', '')::uuid, nullif(v_r->'sticker', 'null'::jsonb));
    else
      select coalesce(jsonb_agg(jsonb_build_object(
               'type', e.item->>'type', 'path', e.item->>'path', 'thumb_path', e.item->>'thumb_path',
               'width', e.item->'width', 'height', e.item->'height',
               'duration_ms', e.item->'duration_ms', 'blurhash', e.item->>'blurhash')
             order by e.ord), '[]'::jsonb)
      into v_media
      from jsonb_array_elements(coalesce(v_r->'media', '[]'::jsonb)) with ordinality as e(item, ord);

      perform public.create_post(
        p_id               => v_row.id,
        p_kind             => v_row.kind,
        p_caption          => v_r->>'caption',
        p_location         => v_r->>'location',
        p_media            => v_media,
        p_comments_enabled => coalesce((v_r->>'comments_enabled')::boolean, true),
        p_visibility       => v_row.visibility,
        p_mood_kind        => v_r->>'mood_kind',
        p_mood_key         => v_r->>'mood_key',
        p_mood_text        => v_r->>'mood_text',
        p_tags             => coalesce(v_r->'tags', '[]'::jsonb)
      );
    end if;

    update public.pending_content
    set state = 'published', finished_at = now(), updated_at = now()
    where id = p_id;
  exception when others then
    get stacked diagnostics v_code = returned_sqlstate;
    update public.pending_content
    set state = 'rejected', error_code = v_code, finished_at = now(), updated_at = now()
    where id = p_id;
  end;

  perform set_config('request.jwt.claims', coalesce(v_old_claims, ''), true);
  perform set_config('request.jwt.claim.sub', coalesce(v_old_sub, ''), true);
  return (select state from public.pending_content where id = p_id);
end;
$$;
