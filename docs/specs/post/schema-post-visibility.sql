-- SPEC copy of supabase/migrations/20261018120000_post_visibility.sql (keep in sync; the migration is the source that gets applied).
-- Validated in rolled-back batches, then APPLIED to the linked project on 2026-10-14 (post_visibility, then shared_content_actions).
-- =====================================================================
-- Pulse · Post visibility — Who can see this post (S4)
-- Migration: supabase/migrations/20261018120000_post_visibility.sql
-- Depends on: 20261012120000_home_feed.sql, 20261013140000_post_options.sql,
--             20261015120000_story_audience.sql (close_friends, audience_summary)
-- Adds: posts.visibility, profiles.default_post_visibility, can_view_post(),
--       the helpers is_accepted_follower() / is_close_friend(),
--       create_post(..., p_visibility), and replaces the policies and
--       home_feed so they follow the post's visibility. Changing the
--       audience and reporting are the shared RPCs of
--       20261019120000_shared_content_actions.sql.
--       Docs: docs/specs/post/screens/s4-visibility.md.
-- Validate in a rolled-back transaction; apply only after the user approves.
-- =====================================================================

-- 1. The audience of one post, and the default for the next one.
--    Existing posts become public.
alter table public.posts
  add column visibility text not null default 'public',
  add constraint posts_visibility_valid
    check (visibility in ('public', 'followers', 'close_friends', 'only_me'));

alter table public.profiles
  add column default_post_visibility text not null default 'public',
  add constraint profiles_default_post_visibility_valid
    check (default_post_visibility in ('public', 'followers', 'close_friends', 'only_me'));

grant update (default_post_visibility) on public.profiles to authenticated;

-- 2. Helpers shared with can_view_story(). SECURITY DEFINER: they read the
--    AUTHOR's follows and private close friends list for the viewer.
create or replace function public.is_accepted_follower(p_author uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.follows f
    where f.follower_id = auth.uid()
      and f.following_id = p_author
      and f.status = 'accepted'
  );
$$;
create or replace function public.is_close_friend(p_author uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.close_friends c
    where c.user_id = p_author and c.friend_id = auth.uid()
  );
$$;
revoke all on function public.is_accepted_follower(uuid) from public, anon;
revoke all on function public.is_close_friend(uuid) from public, anon;
grant execute on function public.is_accepted_follower(uuid) to authenticated;
grant execute on function public.is_close_friend(uuid) to authenticated;

-- Who may see a post: its author; public posts to whoever can view the
-- author; followers posts to accepted followers; close friends posts to
-- accepted followers on the author's close friends list; only me to nobody
-- else.
create or replace function public.can_view_post(p_author uuid, p_visibility text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select auth.uid() is not null and (
    p_author = auth.uid()
    or case p_visibility
         when 'public' then public.can_view_author(p_author)
         when 'followers' then public.is_accepted_follower(p_author)
         when 'close_friends' then public.is_accepted_follower(p_author)
                                   and public.is_close_friend(p_author)
         else false
       end
  );
$$;
revoke all on function public.can_view_post(uuid, text) from public, anon;
grant execute on function public.can_view_post(uuid, text) to authenticated;

-- Storage: a post folder is {uid}/{post_id}/. When that post exists, its
-- files follow the post's visibility; any other folder (stories, files not
-- yet attached to a post) keeps the author check. Never throws on bad input.
create or replace function public.can_view_media_object(p_name text)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_parts text[] := string_to_array(p_name, '/');
  v_uuid  constant text := '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
  v_post  record;
begin
  if coalesce(array_length(v_parts, 1), 0) < 2 or v_parts[1] !~ v_uuid then
    return false;
  end if;
  if v_parts[2] ~ v_uuid then
    select p.author_id, p.visibility into v_post
    from public.posts p
    where p.id = v_parts[2]::uuid and p.author_id = v_parts[1]::uuid;
    if found then
      return public.can_view_post(v_post.author_id, v_post.visibility);
    end if;
  end if;
  return public.can_view_author(v_parts[1]::uuid);
end;
$$;
revoke all on function public.can_view_media_object(text) from public, anon;
grant execute on function public.can_view_media_object(text) to authenticated;

-- 3. Policies: every read, like, save and comment follows the post.
drop policy "posts: read visible" on public.posts;
create policy "posts: read visible" on public.posts
  for select to authenticated using (public.can_view_post(author_id, visibility));

drop policy "post_media: read visible" on public.post_media;
create policy "post_media: read visible" on public.post_media
  for select to authenticated using (
    exists (select 1 from public.posts p
            where p.id = post_id and public.can_view_post(p.author_id, p.visibility))
  );

drop policy "post_likes: read visible" on public.post_likes;
create policy "post_likes: read visible" on public.post_likes
  for select to authenticated using (
    exists (select 1 from public.posts p
            where p.id = post_id and public.can_view_post(p.author_id, p.visibility))
  );
drop policy "post_likes: insert own" on public.post_likes;
create policy "post_likes: insert own" on public.post_likes
  for insert to authenticated with check (
    user_id = auth.uid()
    and exists (select 1 from public.posts p
                where p.id = post_id and public.can_view_post(p.author_id, p.visibility))
  );

drop policy "post_saves: insert own" on public.post_saves;
create policy "post_saves: insert own" on public.post_saves
  for insert to authenticated with check (
    user_id = auth.uid()
    and exists (select 1 from public.posts p
                where p.id = post_id and public.can_view_post(p.author_id, p.visibility))
  );

drop policy "comments: read visible" on public.comments;
create policy "comments: read visible" on public.comments
  for select to authenticated using (
    exists (select 1 from public.posts p
            where p.id = post_id and public.can_view_post(p.author_id, p.visibility))
  );
drop policy "comments: insert own" on public.comments;
create policy "comments: insert own" on public.comments
  for insert to authenticated with check (
    author_id = auth.uid()
    and exists (
      select 1 from public.posts p
      where p.id = post_id
        and public.can_view_post(p.author_id, p.visibility)
        and p.comments_enabled
    )
  );

drop policy "post-media: read visible" on storage.objects;
create policy "post-media: read visible" on storage.objects
  for select to authenticated using (
    bucket_id = 'post-media' and public.can_view_media_object(name)
  );

-- 4. create_post: add p_visibility (null = the profile's default). The
--    signature changes, so drop the old one. Body otherwise as in
--    20261013140000_post_options.sql.
drop function public.create_post(uuid, text, text, text, jsonb, boolean);
create function public.create_post(
  p_id               uuid,
  p_kind             text default 'post',
  p_caption          text default null,
  p_location         text default null,
  p_media            jsonb default '[]'::jsonb,
  p_comments_enabled boolean default true,
  p_visibility       text default null
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

  -- A private account never posts publicly.
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

  insert into public.posts (id, author_id, kind, caption, location, media_count, comments_enabled, visibility)
  values (p_id, v_uid, p_kind, v_caption, v_loc, v_count, coalesce(p_comments_enabled, true), v_visibility);

  insert into public.post_media (post_id, position, type, path, thumb_path, width, height, duration_ms, blurhash)
  select p_id, (e.ord - 1)::smallint, e.item->>'type', e.item->>'path', e.item->>'thumb_path',
         (e.item->>'width')::int, (e.item->>'height')::int,
         (e.item->>'duration_ms')::int, e.item->>'blurhash'
  from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) with ordinality as e(item, ord);

  return p_id;
end;
$$;
revoke all on function public.create_post(uuid, text, text, text, jsonb, boolean, text) from public, anon;
grant execute on function public.create_post(uuid, text, text, text, jsonb, boolean, text) to authenticated;

-- 5. home_feed: the visibility filter and `visibility` in the rows. The
--    return type changes, so drop first.
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
  media            jsonb
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
         ), '[]'::jsonb)
  from page pg
  join public.profiles pr on pr.id = pg.author_id
  order by pg.created_at desc, pg.id desc;
$$;
revoke all on function public.home_feed(int, timestamptz, uuid) from public, anon;
grant execute on function public.home_feed(int, timestamptz, uuid) to authenticated;
