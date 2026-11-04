-- =====================================================================
-- Migration: supabase/migrations/20261028100000_effective_comments_enabled.sql
-- Plan: docs/plans/profile-plan.md (Phase 9, privacy), spec docs/specs/profile/screens/s5-privacy.md
-- Changes: the comments_enabled column of home_feed and posts_by_ids (get_post reads posts_by_ids, so the post page
--   and every list that uses it follow) is now what the CALLER may do: the post's own switch AND the author's
--   "Who can comment" choice (everyone / followers / none). The app already draws "Comments are off" for false, so
--   Home shows it with no client change. The author always sees their own post's switch as it is, so editing a post
--   still shows its real value. add_comment already enforces the same rule on the server.
-- Adds: comments_open_for_viewer(p_enabled, p_author).
-- =====================================================================

create or replace function public.comments_open_for_viewer(p_enabled boolean, p_author uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_enabled and (
    p_author = auth.uid()
    or case (select pr.who_can_comment from public.profiles pr where pr.id = p_author)
         when 'none' then false
         when 'followers' then public.is_accepted_follower(p_author)
         else true
       end
  );
$$;
revoke all on function public.comments_open_for_viewer(boolean, uuid) from public, anon;
grant execute on function public.comments_open_for_viewer(boolean, uuid) to authenticated;

-- home_feed: as in 20261021120000_post_share.sql, with the caller's effective comments_enabled.
create or replace function public.home_feed(
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
         pg.caption, pg.location, pg.like_count, pg.comment_count,
         public.comments_open_for_viewer(pg.comments_enabled, pg.author_id),
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

-- posts_by_ids: as in 20261021190119_content_changes.sql, with the caller's effective comments_enabled.
create or replace function public.posts_by_ids(p_ids uuid[])
returns table(
  id uuid, author_id uuid, username text, full_name text, avatar_url text, caption text,
  location text, like_count integer, comment_count integer, comments_enabled boolean,
  visibility text, created_at timestamptz, liked_by_me boolean, saved_by_me boolean, media jsonb,
  mood_kind text, mood_key text, mood_text text, tag_count integer, tags jsonb,
  i_am_tagged boolean, is_share boolean, shared_post_id uuid, shared_post jsonb
)
language sql
stable
security definer
set search_path = ''
as $$
  select pg.id, pg.author_id, pr.username::text, pr.full_name, pr.avatar_url,
         pg.caption, pg.location, pg.like_count, pg.comment_count,
         public.comments_open_for_viewer(pg.comments_enabled, pg.author_id),
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
  from public.posts pg
  join public.profiles pr on pr.id = pg.author_id
  where pg.id = any (p_ids[1:50])
    and public.can_view_post(pg.author_id, pg.visibility)
  order by pg.created_at desc, pg.id desc;
$$;
revoke all on function public.posts_by_ids(uuid[]) from public, anon;
grant execute on function public.posts_by_ids(uuid[]) to authenticated;
