-- =====================================================================
-- Pulse · Story audience — Who can see this (boards 11 and 12)
-- Migration: supabase/migrations/20261015120000_story_audience.sql
-- Depends on: 20261014120000_story_extras.sql
-- Adds: stories.audience ('followers' | 'close_friends'), the close_friends list, the story_hidden_from
--       list, can_view_story(), and the RPCs the app calls. The audience applies at once, to stories
--       already posted too: it is read at view time, never copied.
-- Validated in a rolled-back transaction, then applied.
-- =====================================================================

-- 1. The audience of one story. Followers (everyone who can view the author) is the default.
alter table public.stories
  add column audience text not null default 'followers';
alter table public.stories
  add constraint stories_audience_valid
  check (audience in ('followers', 'close_friends'));

-- 2. Two private lists of the author's followers. Only the owner reads or changes them.
create table public.close_friends (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  friend_id  uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, friend_id),
  constraint close_friends_not_self check (user_id <> friend_id)
);
create table public.story_hidden_from (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  hidden_id  uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, hidden_id),
  constraint story_hidden_from_not_self check (user_id <> hidden_id)
);
create index close_friends_friend_idx on public.close_friends (friend_id);
create index story_hidden_from_hidden_idx on public.story_hidden_from (hidden_id);

revoke all on public.close_friends, public.story_hidden_from from anon, authenticated;
grant select, insert, delete on public.close_friends, public.story_hidden_from to authenticated;
alter table public.close_friends enable row level security;
alter table public.story_hidden_from enable row level security;
create policy "close_friends: own" on public.close_friends
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy "story_hidden_from: own" on public.story_hidden_from
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- 3. Who may see a story: its author; or whoever can view the author, unless the author hid their
--    stories from them, and, for a Close friends story, only the author's close friends.
--    SECURITY DEFINER: it reads the AUTHOR's private lists on behalf of the viewer.
create or replace function public.can_view_story(p_author uuid, p_audience text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select auth.uid() is not null and (
    p_author = auth.uid()
    or (
      public.can_view_author(p_author)
      and not exists (select 1 from public.story_hidden_from h
                      where h.user_id = p_author and h.hidden_id = auth.uid())
      and (
        p_audience = 'followers'
        or exists (select 1 from public.close_friends c
                   where c.user_id = p_author and c.friend_id = auth.uid())
      )
    )
  );
$$;
revoke all on function public.can_view_story(uuid, text) from public, anon;
grant execute on function public.can_view_story(uuid, text) to authenticated;

-- 4. Every place a story is read, liked, viewed or reported goes through can_view_story.
drop policy "stories: read active visible" on public.stories;
create policy "stories: read active visible" on public.stories
  for select to authenticated
  using (
    author_id = auth.uid()
    or (expires_at > now() and public.can_view_story(author_id, audience))
  );

drop policy "story_likes: insert own" on public.story_likes;
create policy "story_likes: insert own" on public.story_likes
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (select 1 from public.stories s
                where s.id = story_likes.story_id and s.expires_at > now()
                  and public.can_view_story(s.author_id, s.audience))
  );

drop policy "story_views: insert own" on public.story_views;
create policy "story_views: insert own" on public.story_views
  for insert to authenticated
  with check (
    viewer_id = auth.uid()
    and exists (select 1 from public.stories s
                where s.id = story_views.story_id and s.expires_at > now()
                  and public.can_view_story(s.author_id, s.audience))
  );

create or replace function public.report_story(p_story uuid, p_reason text, p_note text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not exists (select 1 from public.stories s
                 where s.id = p_story and s.expires_at > now()
                   and public.can_view_story(s.author_id, s.audience)) then
    raise exception 'story not found' using errcode = '22023';
  end if;
  insert into public.reports (reporter_id, story_id, reason, note)
  values (v_uid, p_story, p_reason, nullif(btrim(p_note), ''))
  on conflict (reporter_id, story_id) do nothing;
end;
$$;

-- story_rail: same as before, plus can_view_story (the rail is SECURITY DEFINER, so RLS does not apply).
create or replace function public.story_rail(p_limit int default 30)
returns table (
  author_id   uuid,
  username    text,
  full_name   text,
  avatar_url  text,
  is_me       boolean,
  story_count integer,
  latest_at   timestamptz,
  all_seen    boolean
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
      or (
        exists (select 1 from public.follows f
                where f.follower_id = auth.uid()
                  and f.following_id = s.author_id
                  and f.status = 'accepted')
        and public.can_view_story(s.author_id, s.audience)
      )
    )
    and not exists (select 1 from public.mutes m
                    where m.user_id = auth.uid() and m.muted_id = s.author_id)
    and not exists (select 1 from public.story_mutes sm
                    where sm.user_id = auth.uid() and sm.muted_id = s.author_id)
  group by s.author_id, pr.username, pr.full_name, pr.avatar_url
  order by (s.author_id = auth.uid()) desc, all_seen asc, latest_at desc
  limit least(greatest(coalesce(p_limit, 30), 1), 100);
$$;

-- author_stories now also returns the audience (the options sheet shows it). The return type changes,
-- so the function is dropped and made again; RLS (stories: read active visible) still filters the rows.
drop function public.author_stories(uuid);
create function public.author_stories(p_author uuid)
returns table (
  id          uuid,
  type        text,
  path        text,
  thumb_path  text,
  width       integer,
  height      integer,
  duration_ms integer,
  blurhash    text,
  overlays    jsonb,
  created_at  timestamptz,
  expires_at  timestamptz,
  seen_by_me  boolean,
  liked_by_me boolean,
  view_count  integer,
  audience    text
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
         s.audience
  from public.stories s
  where s.author_id = p_author
    and (s.author_id = auth.uid() or s.expires_at > now())
  order by s.created_at asc;
$$;
revoke all on function public.author_stories(uuid) from public, anon;
grant execute on function public.author_stories(uuid) to authenticated;

-- 5. RPCs of the Who can see this sheet and the lists.

-- Changes the audience of one of YOUR stories, at once. SECURITY DEFINER because the app role has no
-- UPDATE on stories (a story is otherwise immutable); the author check below is the whole gate.
create or replace function public.set_story_audience(p_story uuid, p_audience text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_audience not in ('followers', 'close_friends') then
    raise exception 'invalid audience' using errcode = '22023';
  end if;
  update public.stories set audience = p_audience
  where id = p_story and author_id = auth.uid();
  if not found then
    raise exception 'not your story' using errcode = '42501';
  end if;
  return p_audience;
end;
$$;

-- The three numbers on the sheet: followers, close friends, hidden from.
create or replace function public.audience_summary()
returns table (followers integer, close_friends integer, hidden integer)
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select count(*)::int from public.follows f
      where f.following_id = auth.uid() and f.status = 'accepted'),
    (select count(*)::int from public.close_friends c where c.user_id = auth.uid()),
    (select count(*)::int from public.story_hidden_from h where h.user_id = auth.uid());
$$;

-- YOUR followers for the two list screens. p_list: 'close_friends' | 'hidden'. p_tab: 'suggested' (people
-- who viewed or liked your stories most recently first, then the newest followers) | 'selected' (only
-- those on the list). p_query matches username or name.
create or replace function public.audience_people(
  p_list   text,
  p_tab    text default 'suggested',
  p_query  text default null,
  p_limit  int  default 30,
  p_offset int  default 0
)
returns table (user_id uuid, username text, full_name text, avatar_url text, selected boolean)
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
           m.since,
           (select max(v.viewed_at) from public.story_views v
              join public.stories s on s.id = v.story_id
             where s.author_id = auth.uid() and v.viewer_id = m.id) as last_seen
    from mine m
  )
  select p.id, pr.username::text, pr.full_name, pr.avatar_url, k.selected
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

-- Adds and removes people on one list in a single call (Done on a list screen). Only YOUR followers can be
-- added; everyone in p_remove is taken off.
create or replace function public.update_audience_list(
  p_list   text,
  p_add    uuid[] default '{}',
  p_remove uuid[] default '{}'
)
returns void
language plpgsql
set search_path = ''
as $$
begin
  if p_list = 'close_friends' then
    delete from public.close_friends
      where user_id = auth.uid() and friend_id = any (coalesce(p_remove, '{}'));
    insert into public.close_friends (user_id, friend_id)
      select auth.uid(), f.follower_id
      from public.follows f
      where f.following_id = auth.uid() and f.status = 'accepted'
        and f.follower_id = any (coalesce(p_add, '{}'))
      on conflict do nothing;
  elsif p_list = 'hidden' then
    delete from public.story_hidden_from
      where user_id = auth.uid() and hidden_id = any (coalesce(p_remove, '{}'));
    insert into public.story_hidden_from (user_id, hidden_id)
      select auth.uid(), f.follower_id
      from public.follows f
      where f.following_id = auth.uid() and f.status = 'accepted'
        and f.follower_id = any (coalesce(p_add, '{}'))
      on conflict do nothing;
  else
    raise exception 'invalid list' using errcode = '22023';
  end if;
end;
$$;

revoke all on function public.set_story_audience(uuid, text)                from public, anon;
revoke all on function public.audience_summary()                            from public, anon;
revoke all on function public.audience_people(text, text, text, int, int)   from public, anon;
revoke all on function public.update_audience_list(text, uuid[], uuid[])    from public, anon;
revoke all on function public.report_story(uuid, text, text)                from public, anon;
revoke all on function public.story_rail(int)                               from public, anon;
grant execute on function public.set_story_audience(uuid, text)              to authenticated;
grant execute on function public.audience_summary()                          to authenticated;
grant execute on function public.audience_people(text, text, text, int, int) to authenticated;
grant execute on function public.update_audience_list(text, uuid[], uuid[])  to authenticated;
grant execute on function public.report_story(uuid, text, text)              to authenticated;
grant execute on function public.story_rail(int)                             to authenticated;
