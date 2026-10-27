-- =====================================================================
-- Migration: supabase/migrations/20261027102442_post_likes_list.sql
-- Plan: docs/plans/post-plan.md (Phase 32), spec docs/specs/post/screens/s15-post-page.md (S16)
-- Adds: post_likers(...)      the people who liked a post, searchable, newest first, with follow state
--       liked_by_preview(...) the "Liked by" row: one name, up to two avatars, how many others
-- Who appears: the post's author sees everyone; anyone else sees the people they may see
--       (can_user_view_author: public accounts, people they follow, themselves).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. post_likers
--    Paging: pass the last row's liked_at and id as p_before_time / p_before_id.
--    total is how many people the caller may see on the post (not narrowed by p_query), same on every row.
--    follow_status is the caller's follow of that person: none, pending or accepted;
--    follows_me is true when that person follows the caller (accepted).
-- ---------------------------------------------------------------------
create or replace function public.post_likers(
  p_post        uuid,
  p_query       text default null,
  p_limit       integer default 20,
  p_before_time timestamptz default null,
  p_before_id   uuid default null
)
returns table(
  id uuid, username text, full_name text, avatar_url text, liked_at timestamptz,
  follow_status text, follows_me boolean, total bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_author uuid := public.comments_post_author(p_post);
  v_q      text := lower(coalesce(btrim(p_query), ''));
  v_limit  integer := least(greatest(coalesce(p_limit, 20), 1), 50);
begin
  return query
    with visible as (
      select l.user_id, l.created_at
        from public.post_likes l
       where l.post_id = p_post
         and (v_uid = v_author or public.can_user_view_author(v_uid, l.user_id))
    ),
    counted as (select count(*) as n from visible)
    select pr.id, pr.username::text, pr.full_name, pr.avatar_url, v.created_at,
           coalesce(f.status::text, 'none'),
           exists (select 1 from public.follows fm
                    where fm.follower_id = pr.id and fm.following_id = v_uid and fm.status = 'accepted'),
           (select n from counted)
      from visible v
      join public.profiles pr on pr.id = v.user_id
      left join public.follows f on f.follower_id = v_uid and f.following_id = pr.id
     where (v_q = ''
            or position(v_q in lower(coalesce(pr.username::text, ''))) > 0
            or position(v_q in lower(coalesce(pr.full_name, ''))) > 0)
       and (p_before_time is null
            or (v.created_at, v.user_id) < (p_before_time, coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid)))
     order by v.created_at desc, v.user_id desc
     limit v_limit;
end;
$$;

-- ---------------------------------------------------------------------
-- 2. liked_by_preview
--    first_*: the person you follow who liked it most recently, else the most recent person you may see
--    (never yourself). others: the other people you may see who liked it, yourself not counted.
--    avatars: that person and the next one, newest first. No row when nobody else liked it.
-- ---------------------------------------------------------------------
create or replace function public.liked_by_preview(p_post uuid)
returns table(first_id uuid, first_username text, first_full_name text, others integer, avatars jsonb)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_author uuid := public.comments_post_author(p_post);
begin
  return query
    with visible as (
      select l.user_id, l.created_at,
             exists (select 1 from public.follows f
                      where f.follower_id = v_uid and f.following_id = l.user_id and f.status = 'accepted') as followed
        from public.post_likes l
       where l.post_id = p_post
         and l.user_id <> v_uid
         and (v_uid = v_author or public.can_user_view_author(v_uid, l.user_id))
    ),
    ranked as (
      select v.user_id, row_number() over (order by v.followed desc, v.created_at desc, v.user_id desc) as rank
        from visible v
    )
    select first_p.id, first_p.username::text, first_p.full_name,
           ((select count(*) from ranked) - 1)::integer,
           (select jsonb_agg(jsonb_build_object(
                     'id', p.id, 'name', coalesce(nullif(btrim(p.full_name), ''), p.username::text),
                     'avatar_url', p.avatar_url) order by r.rank)
              from ranked r join public.profiles p on p.id = r.user_id
             where r.rank <= 2)
      from ranked r1
      join public.profiles first_p on first_p.id = r1.user_id
     where r1.rank = 1;
end;
$$;

revoke all on function public.post_likers(uuid, text, integer, timestamptz, uuid) from public, anon;
revoke all on function public.liked_by_preview(uuid) from public, anon;
grant execute on function public.post_likers(uuid, text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.liked_by_preview(uuid) to authenticated;
