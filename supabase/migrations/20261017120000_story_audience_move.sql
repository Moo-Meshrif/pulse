-- =====================================================================
-- Pulse · Story audience lists: adding someone to one list MOVES them off the other
-- Migration: supabase/migrations/20261017120000_story_audience_move.sql
-- Depends on: 20261016120000_story_audience_lists.sql
-- The app asks the person to confirm first ("X is in Close friends. Hiding your stories from them takes
-- them off that list"), so the server moves them instead of skipping them. An emptied Close friends list
-- still sends your Close friends stories back to Followers.
-- =====================================================================
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
    delete from public.story_hidden_from
      where user_id = auth.uid() and hidden_id = any (coalesce(p_add, '{}'));
    insert into public.close_friends (user_id, friend_id)
      select auth.uid(), f.follower_id
      from public.follows f
      where f.following_id = auth.uid() and f.status = 'accepted'
        and f.follower_id = any (coalesce(p_add, '{}'))
      on conflict do nothing;
  elsif p_list = 'hidden' then
    delete from public.story_hidden_from
      where user_id = auth.uid() and hidden_id = any (coalesce(p_remove, '{}'));
    delete from public.close_friends
      where user_id = auth.uid() and friend_id = any (coalesce(p_add, '{}'));
    insert into public.story_hidden_from (user_id, hidden_id)
      select auth.uid(), f.follower_id
      from public.follows f
      where f.following_id = auth.uid() and f.status = 'accepted'
        and f.follower_id = any (coalesce(p_add, '{}'))
      on conflict do nothing;
  else
    raise exception 'invalid list' using errcode = '22023';
  end if;
  -- Whichever list changed, an emptied Close friends list sends its stories back to Followers.
  if not exists (select 1 from public.close_friends c where c.user_id = auth.uid()) then
    update public.stories set audience = 'followers'
    where author_id = auth.uid() and audience = 'close_friends';
  end if;
end;
$$;
revoke all on function public.update_audience_list(text, uuid[], uuid[]) from public, anon;
grant execute on function public.update_audience_list(text, uuid[], uuid[]) to authenticated;
