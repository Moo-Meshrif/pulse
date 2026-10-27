-- =====================================================================
-- Migration: supabase/migrations/20261027105047_liked_by_you.sql
-- Plan: docs/plans/post-plan.md (Phase 32), spec docs/specs/post/screens/s15-post-page.md
-- Changes: liked_by_preview(p_post) answers "Liked by you" when you are the only person who liked the post
--          (new column only_me; first_* and the avatar are you). With other people it is as before and
--          never names you.
-- =====================================================================
drop function if exists public.liked_by_preview(uuid);

create function public.liked_by_preview(p_post uuid)
returns table(
  first_id uuid, first_username text, first_full_name text, others integer, avatars jsonb, only_me boolean
)
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
             where r.rank <= 2),
           false
      from ranked r1
      join public.profiles first_p on first_p.id = r1.user_id
     where r1.rank = 1
    union all
    select me.id, me.username::text, me.full_name, 0,
           jsonb_build_array(jsonb_build_object(
             'id', me.id, 'name', coalesce(nullif(btrim(me.full_name), ''), me.username::text),
             'avatar_url', me.avatar_url)),
           true
      from public.post_likes l
      join public.profiles me on me.id = l.user_id
     where l.post_id = p_post and l.user_id = v_uid
       and not exists (select 1 from visible);
end;
$$;

revoke all on function public.liked_by_preview(uuid) from public, anon;
grant execute on function public.liked_by_preview(uuid) to authenticated;
