-- =====================================================================
-- Pulse · Home feed schema
-- Migration: supabase/migrations/20261012120000_home_feed.sql
-- Depends on: pulse_schema, follow_requests (profiles.is_private,
--             follows.status). Do not re-apply earlier migrations.
--
-- Adds: posts + post_media (mixed image/video list, max 10),
--       post_likes, post_saves, comments (one reply level),
--       stories + story_views (24 h), private bucket post-media,
--       RPCs create_post, home_feed, set_post_like, set_post_save,
--       story_rail.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Visibility helpers
--    A viewer may see an author's content when it is their own, the
--    author is public, or the viewer has an accepted follow.
-- ---------------------------------------------------------------------
create or replace function public.can_view_author(p_author uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_author = auth.uid()
      or exists (
           select 1 from public.profiles p
           where p.id = p_author and not p.is_private and p.signup_step = 0
         )
      or exists (
           select 1 from public.follows f
           where f.follower_id = auth.uid()
             and f.following_id = p_author
             and f.status = 'accepted'
         );
$$;

-- Same check for a storage folder name (text); never throws on bad input.
create or replace function public.can_view_folder(p_folder text)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if p_folder is null
     or p_folder !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    return false;
  end if;
  return public.can_view_author(p_folder::uuid);
end;
$$;

revoke all on function public.can_view_author(uuid) from public, anon;
revoke all on function public.can_view_folder(text) from public, anon;
grant execute on function public.can_view_author(uuid) to authenticated;
grant execute on function public.can_view_folder(text) to authenticated;

-- ---------------------------------------------------------------------
-- 1. posts
-- ---------------------------------------------------------------------
create table public.posts (
  id            uuid primary key default gen_random_uuid(),
  author_id     uuid not null references public.profiles (id) on delete cascade,
  kind          text not null default 'post',
  caption       text,
  location      text,
  media_count   smallint not null default 0,
  like_count    integer not null default 0,
  comment_count integer not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),

  constraint posts_kind check (kind in ('post', 'short')),
  constraint posts_caption_len check (caption is null or char_length(caption) between 1 and 2200),
  constraint posts_location_len check (location is null or char_length(location) between 1 and 80),
  constraint posts_media_count check (media_count between 0 and 10),
  constraint posts_has_content check (caption is not null or media_count > 0),
  constraint posts_counts check (like_count >= 0 and comment_count >= 0)
);

comment on table public.posts is 'Feed posts and shorts. Created only through create_post().';

create index posts_author_created_idx on public.posts (author_id, created_at desc, id desc);
create index posts_kind_created_idx   on public.posts (kind, created_at desc, id desc);

create or replace function public.posts_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger posts_touch
  before update on public.posts
  for each row execute function public.posts_touch();

-- ---------------------------------------------------------------------
-- 2. post_media — ordered list, image or video, max 10 per post
-- ---------------------------------------------------------------------
create table public.post_media (
  post_id     uuid not null references public.posts (id) on delete cascade,
  position    smallint not null,
  type        text not null,
  path        text not null,      -- object name in bucket post-media
  thumb_path  text,               -- poster frame (videos)
  width       integer not null,
  height      integer not null,
  duration_ms integer,
  blurhash    text,

  primary key (post_id, position),
  constraint post_media_position check (position between 0 and 9),
  constraint post_media_type check (type in ('image', 'video')),
  constraint post_media_size check (width > 0 and height > 0),
  constraint post_media_duration check (
    (type = 'video' and duration_ms between 1 and 600000) or (type = 'image' and duration_ms is null)
  ),
  constraint post_media_blurhash_len check (blurhash is null or char_length(blurhash) <= 64)
);

-- ---------------------------------------------------------------------
-- 3. Likes, saves, comments
-- ---------------------------------------------------------------------
create table public.post_likes (
  post_id    uuid not null references public.posts (id) on delete cascade,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index post_likes_user_idx on public.post_likes (user_id, created_at desc);

create table public.post_saves (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  post_id    uuid not null references public.posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);
create index post_saves_post_idx on public.post_saves (post_id);

create table public.comments (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts (id) on delete cascade,
  author_id  uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  parent_id  uuid references public.comments (id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now(),
  constraint comments_body_len check (char_length(btrim(body)) between 1 and 1000)
);
create index comments_post_created_idx on public.comments (post_id, created_at);
create index comments_parent_idx on public.comments (parent_id) where parent_id is not null;
create index comments_author_idx on public.comments (author_id);

-- Replies stay one level deep and on the same post.
create or replace function public.comments_check_parent()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_parent public.comments;
begin
  if new.parent_id is not null then
    select * into v_parent from public.comments where id = new.parent_id;
    if v_parent.post_id is distinct from new.post_id or v_parent.parent_id is not null then
      raise exception 'replies must target a top-level comment on the same post'
        using errcode = 'check_violation';
    end if;
  end if;
  return new;
end;
$$;

create trigger comments_check_parent
  before insert on public.comments
  for each row execute function public.comments_check_parent();

-- Counters on posts, so the feed never counts rows.
create or replace function public.post_counters()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_table_name = 'post_likes' then
    if tg_op = 'INSERT' then
      update public.posts set like_count = like_count + 1 where id = new.post_id;
    else
      update public.posts set like_count = greatest(like_count - 1, 0) where id = old.post_id;
    end if;
  elsif tg_table_name = 'comments' then
    if tg_op = 'INSERT' then
      update public.posts set comment_count = comment_count + 1 where id = new.post_id;
    else
      update public.posts set comment_count = greatest(comment_count - 1, 0) where id = old.post_id;
    end if;
  end if;
  return null;
end;
$$;

create trigger post_likes_count
  after insert or delete on public.post_likes
  for each row execute function public.post_counters();

create trigger comments_count
  after insert or delete on public.comments
  for each row execute function public.post_counters();

-- ---------------------------------------------------------------------
-- 4. Stories (24 h) — the round rail at the top of Home
-- ---------------------------------------------------------------------
create table public.stories (
  id          uuid primary key default gen_random_uuid(),
  author_id   uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  type        text not null,
  path        text not null,
  thumb_path  text,
  width       integer not null,
  height      integer not null,
  duration_ms integer,
  blurhash    text,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default now() + interval '24 hours',

  constraint stories_type check (type in ('image', 'video')),
  constraint stories_size check (width > 0 and height > 0),
  constraint stories_duration check (
    (type = 'video' and duration_ms between 1 and 60000) or (type = 'image' and duration_ms is null)
  ),
  constraint stories_blurhash_len check (blurhash is null or char_length(blurhash) <= 64)
);
create index stories_author_expires_idx on public.stories (author_id, expires_at desc);

create table public.story_views (
  story_id  uuid not null references public.stories (id) on delete cascade,
  viewer_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  viewed_at timestamptz not null default now(),
  primary key (story_id, viewer_id)
);
create index story_views_viewer_idx on public.story_views (viewer_id);

-- ---------------------------------------------------------------------
-- 5. Privileges + RLS
--    Supabase grants everything on new public tables to anon and
--    authenticated by default; reset, then grant only what is used.
-- ---------------------------------------------------------------------
revoke all on public.posts, public.post_media, public.post_likes, public.post_saves,
              public.comments, public.stories, public.story_views
  from anon, authenticated;

grant select, delete            on public.posts       to authenticated;
grant update (caption, location) on public.posts      to authenticated;
grant select                    on public.post_media  to authenticated;
grant select, insert, delete    on public.post_likes  to authenticated;
grant select, insert, delete    on public.post_saves  to authenticated;
grant select, delete            on public.comments    to authenticated;
grant insert (post_id, parent_id, body) on public.comments to authenticated;
grant select, delete            on public.stories     to authenticated;
grant insert (type, path, thumb_path, width, height, duration_ms, blurhash) on public.stories to authenticated;
grant select                    on public.story_views to authenticated;
grant insert (story_id)         on public.story_views to authenticated;

alter table public.posts       enable row level security;
alter table public.post_media  enable row level security;
alter table public.post_likes  enable row level security;
alter table public.post_saves  enable row level security;
alter table public.comments    enable row level security;
alter table public.stories     enable row level security;
alter table public.story_views enable row level security;

-- posts
create policy "posts: read visible" on public.posts
  for select to authenticated using (public.can_view_author(author_id));
create policy "posts: update own" on public.posts
  for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy "posts: delete own" on public.posts
  for delete to authenticated using (author_id = auth.uid());

-- post_media (written only by create_post)
create policy "post_media: read visible" on public.post_media
  for select to authenticated using (
    exists (select 1 from public.posts p where p.id = post_id and public.can_view_author(p.author_id))
  );

-- likes
create policy "post_likes: read visible" on public.post_likes
  for select to authenticated using (
    exists (select 1 from public.posts p where p.id = post_id and public.can_view_author(p.author_id))
  );
create policy "post_likes: insert own" on public.post_likes
  for insert to authenticated with check (
    user_id = auth.uid()
    and exists (select 1 from public.posts p where p.id = post_id and public.can_view_author(p.author_id))
  );
create policy "post_likes: delete own" on public.post_likes
  for delete to authenticated using (user_id = auth.uid());

-- saves (private to the saver)
create policy "post_saves: read own" on public.post_saves
  for select to authenticated using (user_id = auth.uid());
create policy "post_saves: insert own" on public.post_saves
  for insert to authenticated with check (
    user_id = auth.uid()
    and exists (select 1 from public.posts p where p.id = post_id and public.can_view_author(p.author_id))
  );
create policy "post_saves: delete own" on public.post_saves
  for delete to authenticated using (user_id = auth.uid());

-- comments
create policy "comments: read visible" on public.comments
  for select to authenticated using (
    exists (select 1 from public.posts p where p.id = post_id and public.can_view_author(p.author_id))
  );
create policy "comments: insert own" on public.comments
  for insert to authenticated with check (
    author_id = auth.uid()
    and exists (select 1 from public.posts p where p.id = post_id and public.can_view_author(p.author_id))
  );
create policy "comments: delete own or on own post" on public.comments
  for delete to authenticated using (
    author_id = auth.uid()
    or exists (select 1 from public.posts p where p.id = post_id and p.author_id = auth.uid())
  );

-- stories
create policy "stories: read active visible" on public.stories
  for select to authenticated using (
    author_id = auth.uid() or (expires_at > now() and public.can_view_author(author_id))
  );
create policy "stories: insert own" on public.stories
  for insert to authenticated with check (
    author_id = auth.uid()
    and path like auth.uid()::text || '/stories/%'
    and (thumb_path is null or thumb_path like auth.uid()::text || '/stories/%')
  );
create policy "stories: delete own" on public.stories
  for delete to authenticated using (author_id = auth.uid());

-- story views: the viewer sees their own; the author sees who viewed
create policy "story_views: read own or on own story" on public.story_views
  for select to authenticated using (
    viewer_id = auth.uid()
    or exists (select 1 from public.stories s where s.id = story_id and s.author_id = auth.uid())
  );
create policy "story_views: insert own" on public.story_views
  for insert to authenticated with check (
    viewer_id = auth.uid()
    and exists (
      select 1 from public.stories s
      where s.id = story_id and s.expires_at > now() and public.can_view_author(s.author_id)
    )
  );

-- ---------------------------------------------------------------------
-- 6. Storage — private bucket post-media
--    Paths: {uid}/{post_id}/{n}.jpg|mp4, {uid}/{post_id}/{n}_thumb.jpg,
--           {uid}/stories/{story_id}.jpg|mp4
--    Reads go through signed URLs; the select policy applies the same
--    visibility as the tables, so private accounts stay private.
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('post-media', 'post-media', false, 52428800,
        array['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/quicktime'])
on conflict (id) do nothing;

create policy "post-media: read visible" on storage.objects
  for select to authenticated using (
    bucket_id = 'post-media' and public.can_view_folder((storage.foldername(name))[1])
  );
create policy "post-media: owner insert" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "post-media: owner update" on storage.objects
  for update to authenticated
  using (bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "post-media: owner delete" on storage.objects
  for delete to authenticated using (
    bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ---------------------------------------------------------------------
-- 7. RPCs
-- ---------------------------------------------------------------------

-- create_post: the app generates p_id (uuid v4), uploads the files to
-- post-media/{uid}/{p_id}/..., then calls this once. Atomic.
-- p_media: [{"type":"image","path":"…","width":1080,"height":1350,
--            "blurhash":"…"}, {"type":"video","path":"…","thumb_path":"…",
--            "width":1080,"height":1920,"duration_ms":12000}]
create or replace function public.create_post(
  p_id       uuid,
  p_kind     text default 'post',
  p_caption  text default null,
  p_location text default null,
  p_media    jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_prefix  text;
  v_count   int;
  v_caption text := nullif(btrim(p_caption), '');
  v_loc     text := nullif(btrim(p_location), '');
  v_item    jsonb;
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
  if jsonb_typeof(coalesce(p_media, '[]'::jsonb)) <> 'array' then
    raise exception 'media must be an array' using errcode = '22023';
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

  insert into public.posts (id, author_id, kind, caption, location, media_count)
  values (p_id, v_uid, p_kind, v_caption, v_loc, v_count);

  insert into public.post_media (post_id, position, type, path, thumb_path, width, height, duration_ms, blurhash)
  select p_id, (e.ord - 1)::smallint, e.item->>'type', e.item->>'path', e.item->>'thumb_path',
         (e.item->>'width')::int, (e.item->>'height')::int,
         (e.item->>'duration_ms')::int, e.item->>'blurhash'
  from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) with ordinality as e(item, ord);

  return p_id;
end;
$$;

-- home_feed: own posts + accepted follows, newest first, keyset paging.
-- First page: home_feed(20). Next page: pass the last row's created_at and id.
create or replace function public.home_feed(
  p_limit          int default 20,
  p_before_created timestamptz default null,
  p_before_id      uuid default null
)
returns table (
  id            uuid,
  author_id     uuid,
  username      text,
  full_name     text,
  avatar_url    text,
  caption       text,
  location      text,
  like_count    integer,
  comment_count integer,
  created_at    timestamptz,
  liked_by_me   boolean,
  saved_by_me   boolean,
  media         jsonb
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
      and (
        p_before_created is null
        or (p.created_at, p.id) < (p_before_created,
                                   coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid))
      )
    order by p.created_at desc, p.id desc
    limit least(greatest(coalesce(p_limit, 20), 1), 50)
  )
  select pg.id, pg.author_id, pr.username::text, pr.full_name, pr.avatar_url,
         pg.caption, pg.location, pg.like_count, pg.comment_count, pg.created_at,
         exists (select 1 from public.post_likes l where l.post_id = pg.id and l.user_id = auth.uid()),
         exists (select 1 from public.post_saves s where s.post_id = pg.id and s.user_id = auth.uid()),
         coalesce((
           select jsonb_agg(jsonb_build_object(
                    'position', m.position, 'type', m.type, 'path', m.path,
                    'thumb_path', m.thumb_path, 'width', m.width, 'height', m.height,
                    'duration_ms', m.duration_ms, 'blurhash', m.blurhash)
                  order by m.position)
           from public.post_media m where m.post_id = pg.id
         ), '[]'::jsonb)
  from page pg
  join public.profiles pr on pr.id = pg.author_id
  order by pg.created_at desc, pg.id desc;
$$;

-- set_post_like: idempotent like/unlike, returns the new like_count.
create or replace function public.set_post_like(p_post uuid, p_liked boolean)
returns integer
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_liked then
    insert into public.post_likes (post_id, user_id) values (p_post, auth.uid())
    on conflict do nothing;
  else
    delete from public.post_likes where post_id = p_post and user_id = auth.uid();
  end if;
  return (select like_count from public.posts where id = p_post);
end;
$$;

-- set_post_save: idempotent save/unsave, returns the new state.
create or replace function public.set_post_save(p_post uuid, p_saved boolean)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_saved then
    insert into public.post_saves (user_id, post_id) values (auth.uid(), p_post)
    on conflict do nothing;
  else
    delete from public.post_saves where user_id = auth.uid() and post_id = p_post;
  end if;
  return p_saved;
end;
$$;

-- story_rail: who to show in the story row — yourself first (if you have
-- an active story), then followed accounts with active stories, unseen first.
create or replace function public.story_rail(p_limit int default 30)
returns table (
  author_id  uuid,
  username   text,
  full_name  text,
  avatar_url text,
  is_me      boolean,
  story_count integer,
  latest_at  timestamptz,
  all_seen   boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select s.author_id, pr.username::text, pr.full_name, pr.avatar_url,
         s.author_id = auth.uid() as is_me,
         count(*)::int as story_count,
         max(s.created_at) as latest_at,
         bool_and(exists (select 1 from public.story_views v
                          where v.story_id = s.id and v.viewer_id = auth.uid())) as all_seen
  from public.stories s
  join public.profiles pr on pr.id = s.author_id
  where s.expires_at > now()
    and (
      s.author_id = auth.uid()
      or exists (select 1 from public.follows f
                 where f.follower_id = auth.uid()
                   and f.following_id = s.author_id
                   and f.status = 'accepted')
    )
  group by s.author_id, pr.username, pr.full_name, pr.avatar_url
  order by (s.author_id = auth.uid()) desc, all_seen asc, latest_at desc
  limit least(greatest(coalesce(p_limit, 30), 1), 100);
$$;

revoke all on function public.create_post(uuid, text, text, text, jsonb) from public, anon;
revoke all on function public.home_feed(int, timestamptz, uuid)          from public, anon;
revoke all on function public.set_post_like(uuid, boolean)               from public, anon;
revoke all on function public.set_post_save(uuid, boolean)               from public, anon;
revoke all on function public.story_rail(int)                            from public, anon;
revoke all on function public.post_counters()                            from public, anon, authenticated;
revoke all on function public.comments_check_parent()                    from public, anon, authenticated;
revoke all on function public.posts_touch()                              from public, anon, authenticated;

grant execute on function public.create_post(uuid, text, text, text, jsonb) to authenticated;
grant execute on function public.home_feed(int, timestamptz, uuid)          to authenticated;
grant execute on function public.set_post_like(uuid, boolean)               to authenticated;
grant execute on function public.set_post_save(uuid, boolean)               to authenticated;
grant execute on function public.story_rail(int)                            to authenticated;
