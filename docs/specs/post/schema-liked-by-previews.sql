-- =====================================================================
-- Spec copy of supabase/migrations/20261027150000_liked_by_previews.sql
-- Plan: docs/plans/feed-liked-by-plan.md (Phase 1)
-- Changes: liked_by_previews(p_posts) answers the "Liked by" line of up to 50 posts in one call, with the
--          rules of liked_by_preview. A post the caller cannot see, or with nobody to name, is left out.
-- =====================================================================
create or replace function public.liked_by_previews(p_posts uuid[])
returns table(
  post_id uuid, first_id uuid, first_username text, first_full_name text, others integer,
  avatars jsonb, only_me boolean
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if coalesce(cardinality(p_posts), 0) > 50 then
    raise exception 'too_many_posts' using errcode = '22023';
  end if;

  return query
    with posts_seen as (
      select p.id, p.author_id
        from public.posts p
       where p.id = any (p_posts)
         and public.can_view_post(p.author_id, p.visibility)
    ),
    visible as (
      select s.id as post_id, l.user_id, l.created_at,
             exists (select 1 from public.follows f
                      where f.follower_id = v_uid and f.following_id = l.user_id and f.status = 'accepted') as followed
        from posts_seen s
        join public.post_likes l on l.post_id = s.id
       where l.user_id <> v_uid
         and (v_uid = s.author_id or public.can_user_view_author(v_uid, l.user_id))
    ),
    ranked as (
      select v.post_id, v.user_id,
             row_number() over (partition by v.post_id
                                order by v.followed desc, v.created_at desc, v.user_id desc) as rank,
             count(*) over (partition by v.post_id) as total
        from visible v
    )
    select r1.post_id, first_p.id, first_p.username::text, first_p.full_name,
           (r1.total - 1)::integer,
           (select jsonb_agg(jsonb_build_object(
                     'id', p.id, 'name', coalesce(nullif(btrim(p.full_name), ''), p.username::text),
                     'avatar_url', p.avatar_url) order by r.rank)
              from ranked r join public.profiles p on p.id = r.user_id
             where r.post_id = r1.post_id and r.rank <= 2),
           false
      from ranked r1
      join public.profiles first_p on first_p.id = r1.user_id
     where r1.rank = 1
    union all
    select s.id, me.id, me.username::text, me.full_name, 0,
           jsonb_build_array(jsonb_build_object(
             'id', me.id, 'name', coalesce(nullif(btrim(me.full_name), ''), me.username::text),
             'avatar_url', me.avatar_url)),
           true
      from posts_seen s
      join public.post_likes l on l.post_id = s.id and l.user_id = v_uid
      join public.profiles me on me.id = v_uid
     where not exists (select 1 from visible v where v.post_id = s.id);
end;
$$;

revoke all on function public.liked_by_previews(uuid[]) from public, anon;
grant execute on function public.liked_by_previews(uuid[]) to authenticated;
