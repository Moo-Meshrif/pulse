-- =====================================================================
-- Pulse · Story audience lists: one list per person, and an empty Close friends list
-- Migration: supabase/migrations/20261016120000_story_audience_lists.sql
-- Depends on: 20261015120000_story_audience.sql
-- 1. A follower is in Close friends or in Hide story from, never both: audience_people tells which
--    people are on the other list (the app shows them as unavailable) and update_audience_list will not
--    add someone who is on it.
-- 2. When the Close friends list becomes empty, your stories set to Close friends go back to Followers.
-- =====================================================================

-- audience_people also returns in_other_list; the return type changes, so it is dropped and made again.
drop function public.audience_people(text, text, text, int, int);
create function public.audience_people(
  p_list   text,
  p_tab    text default 'suggested',
  p_query  text default null,
  p_limit  int  default 30,
  p_offset int  default 0
)
returns table (
  user_id       uuid,
  username      text,
  full_name     text,
  avatar_url    text,
  selected      boolean,
  in_other_list boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  with mine as (
    select f.follower_id as id, f.created_at as since
    from public.follows f
    where f.following_id = auth.uid() and f.status = 'accepted'
  ), picked as (
    select m.id,
           case p_list
             when 'close_friends' then exists (select 1 from public.close_friends c
                                               where c.user_id = auth.uid() and c.friend_id = m.id)
             else exists (select 1 from public.story_hidden_from h
                          where h.user_id = auth.uid() and h.hidden_id = m.id)
           end as selected,
           case p_list
             when 'close_friends' then exists (select 1 from public.story_hidden_from h
                                               where h.user_id = auth.uid() and h.hidden_id = m.id)
             else exists (select 1 from public.close_friends c
                          where c.user_id = auth.uid() and c.friend_id = m.id)
           end as in_other_list,
           m.since,
           (select max(v.viewed_at) from public.story_views v
              join public.stories s on s.id = v.story_id
             where s.author_id = auth.uid() and v.viewer_id = m.id) as last_seen
    from mine m
  )
  select p.id, pr.username::text, pr.full_name, pr.avatar_url, k.selected, k.in_other_list
  from mine p
  join picked k on k.id = p.id
  join public.profiles pr on pr.id = p.id
  where p_list in ('close_friends', 'hidden')
    and (p_tab <> 'selected' or k.selected)
    and (p_query is null or btrim(p_query) = ''
         or pr.username::text ilike '%' || btrim(p_query) || '%'
         or pr.full_name ilike '%' || btrim(p_query) || '%')
  order by k.selected desc,
           (p_tab = 'suggested' and k.last_seen is not null) desc,
           k.last_seen desc nulls last,
           k.since desc
  limit least(greatest(coalesce(p_limit, 30), 1), 100)
  offset greatest(coalesce(p_offset, 0), 0);
$$;
revoke all on function public.audience_people(text, text, text, int, int) from public, anon;
grant execute on function public.audience_people(text, text, text, int, int) to authenticated;

-- update_audience_list: never adds someone who is on the other list, and an empty Close friends list sends
-- your Close friends stories back to Followers. SECURITY DEFINER because the app role has no UPDATE on
-- stories; every statement is scoped to auth.uid().
create or replace function public.update_audience_list(
  p_list   text,
  p_add    uuid[] default '{}',
  p_remove uuid[] default '{}'
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_list = 'close_friends' then
    delete from public.close_friends
      where user_id = auth.uid() and friend_id = any (coalesce(p_remove, '{}'));
    insert into public.close_friends (user_id, friend_id)
      select auth.uid(), f.follower_id
      from public.follows f
      where f.following_id = auth.uid() and f.status = 'accepted'
        and f.follower_id = any (coalesce(p_add, '{}'))
        and not exists (select 1 from public.story_hidden_from h
                        where h.user_id = auth.uid() and h.hidden_id = f.follower_id)
      on conflict do nothing;
    if not exists (select 1 from public.close_friends c where c.user_id = auth.uid()) then
      update public.stories set audience = 'followers'
      where author_id = auth.uid() and audience = 'close_friends';
    end if;
  elsif p_list = 'hidden' then
    delete from public.story_hidden_from
      where user_id = auth.uid() and hidden_id = any (coalesce(p_remove, '{}'));
    insert into public.story_hidden_from (user_id, hidden_id)
      select auth.uid(), f.follower_id
      from public.follows f
      where f.following_id = auth.uid() and f.status = 'accepted'
        and f.follower_id = any (coalesce(p_add, '{}'))
        and not exists (select 1 from public.close_friends c
                        where c.user_id = auth.uid() and c.friend_id = f.follower_id)
      on conflict do nothing;
  else
    raise exception 'invalid list' using errcode = '22023';
  end if;
end;
$$;
revoke all on function public.update_audience_list(text, uuid[], uuid[]) from public, anon;
grant execute on function public.update_audience_list(text, uuid[], uuid[]) to authenticated;
