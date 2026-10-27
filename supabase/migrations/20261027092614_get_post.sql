-- =====================================================================
-- Migration: supabase/migrations/20261027092614_get_post.sql
-- Plan: docs/plans/post-plan.md (Phase 31), spec docs/specs/post/screens/s15-post-page.md
-- Adds: get_post(p_post), one post for its own page. The same row as posts_by_ids / home_feed;
--       no row when the post is gone or the caller may not see it (can_view_post). Hidden and muted
--       posts still open: the caller asked for this one.
-- =====================================================================
create or replace function public.get_post(p_post uuid)
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
  select * from public.posts_by_ids(array[p_post]);
$$;

revoke all on function public.get_post(uuid) from public, anon;
grant execute on function public.get_post(uuid) to authenticated;
