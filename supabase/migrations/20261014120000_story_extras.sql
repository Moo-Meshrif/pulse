-- =====================================================================
-- Pulse · Story extras — SPEC-LEVEL migration, NOT applied
-- Migration: supabase/migrations/20261014120000_story_extras.sql
-- Depends on: 20261012120000_home_feed.sql (home/schema.sql)
-- P1 (story plan): story_viewers pages with p_before; story_rail also skips story_mutes.
-- Adds: stories.overlays (JSON stickers), story_likes, RPCs
--       author_stories, set_story_like, story_viewers.
-- Replies are NOT here: they go to Chat when it exists.
-- Review before applying.
-- =====================================================================

-- 1. Overlays: text / location stickers stored as JSON, rendered by the viewer.
--    Item shape: {"type":"text"|"location","text":"…","x":0.5,"y":0.4,
--                 "scale":1.0,"rotation":-4.0,"color":"#FFFFFF"}  (x, y = fractions of the frame)
alter table public.stories
  add column overlays jsonb not null default '[]'::jsonb;
alter table public.stories
  add constraint stories_overlays_shape
  check (jsonb_typeof(overlays) = 'array' and jsonb_array_length(overlays) <= 20);

grant insert (overlays) on public.stories to authenticated;

-- 2. story_likes
create table public.story_likes (
  story_id   uuid not null references public.stories (id) on delete cascade,
  user_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (story_id, user_id)
);
create index story_likes_user_idx on public.story_likes (user_id);

revoke all on public.story_likes from anon, authenticated;
grant select, insert, delete on public.story_likes to authenticated;
alter table public.story_likes enable row level security;

create policy "story_likes: read own or on own story" on public.story_likes
  for select to authenticated using (
    user_id = auth.uid()
    or exists (select 1 from public.stories s where s.id = story_id and s.author_id = auth.uid())
  );
create policy "story_likes: insert own" on public.story_likes
  for insert to authenticated with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.stories s
      where s.id = story_id and s.expires_at > now() and public.can_view_author(s.author_id)
    )
  );
create policy "story_likes: delete own" on public.story_likes
  for delete to authenticated using (user_id = auth.uid());

-- 3. set_story_like: idempotent like / unlike, returns the new state.
create or replace function public.set_story_like(p_story uuid, p_liked boolean)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_liked then
    insert into public.story_likes (story_id, user_id) values (p_story, auth.uid())
    on conflict do nothing;
  else
    delete from public.story_likes where story_id = p_story and user_id = auth.uid();
  end if;
  return p_liked;
end;
$$;

-- 4. author_stories: the viewer's playlist for one person (oldest first).
--    RLS on stories already hides expired stories from everyone but the author.
--    view_count is filled only for your own stories.
create or replace function public.author_stories(p_author uuid)
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
  view_count  integer
)
language sql
stable
security invoker
set search_path = ''
as $$
  select s.id, s.type, s.path, s.thumb_path, s.width, s.height, s.duration_ms, s.blurhash,
         s.overlays, s.created_at, s.expires_at,
         exists (select 1 from public.story_views v where v.story_id = s.id and v.viewer_id = auth.uid()),
         exists (select 1 from public.story_likes l where l.story_id = s.id and l.user_id = auth.uid()),
         case when s.author_id = auth.uid()
              then (select count(*)::int from public.story_views v where v.story_id = s.id)
              else null end
  from public.stories s
  where s.author_id = p_author
    and (s.author_id = auth.uid() or s.expires_at > now())
  order by s.created_at asc;
$$;

-- 5. story_viewers: who viewed one of YOUR stories, newest first, with a like flag.
--    Keyset paging: pass the last row's viewed_at as p_before for the next page. total is
--    the full view count, not the page size.
create or replace function public.story_viewers(
  p_story  uuid,
  p_limit  int default 30,
  p_before timestamptz default null
)
returns table (
  user_id    uuid,
  username   text,
  full_name  text,
  avatar_url text,
  viewed_at  timestamptz,
  liked      boolean,
  total      bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from public.stories s where s.id = p_story and s.author_id = auth.uid()) then
    raise exception 'not your story' using errcode = '42501';
  end if;
  return query
    select v.viewer_id, pr.username::text, pr.full_name, pr.avatar_url, v.viewed_at,
           exists (select 1 from public.story_likes l where l.story_id = p_story and l.user_id = v.viewer_id),
           (select count(*) from public.story_views t where t.story_id = p_story)
    from public.story_views v
    join public.profiles pr on pr.id = v.viewer_id
    where v.story_id = p_story
      and (p_before is null or v.viewed_at < p_before)
    order by v.viewed_at desc
    limit least(greatest(coalesce(p_limit, 30), 1), 100);
end;
$$;

revoke all on function public.set_story_like(uuid, boolean) from public, anon;
revoke all on function public.author_stories(uuid)          from public, anon;
revoke all on function public.story_viewers(uuid, int, timestamptz) from public, anon;
grant execute on function public.set_story_like(uuid, boolean) to authenticated;
grant execute on function public.author_stories(uuid)          to authenticated;
grant execute on function public.story_viewers(uuid, int, timestamptz) to authenticated;

-- =====================================================================
-- 4. Story mute + story reports (S6). Depends on schema-post-options.sql (reports).
--    story_mutes hides someone's STORIES only (post mutes stay in `mutes`).
--    NOTE for the plan: story_rail() must skip authors present in story_mutes
--    for auth.uid(); the viewer skips them too.
-- =====================================================================
create table public.story_mutes (
  user_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  muted_id   uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, muted_id),
  constraint story_mutes_not_self check (user_id <> muted_id)
);
revoke all on public.story_mutes from anon, authenticated;
grant select, insert, delete on public.story_mutes to authenticated;
alter table public.story_mutes enable row level security;
create policy "story_mutes: own" on public.story_mutes
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- set_story_mute: Mute / Undo. Idempotent.
create or replace function public.set_story_mute(p_user uuid, p_muted boolean)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_muted then
    insert into public.story_mutes (user_id, muted_id) values (auth.uid(), p_user)
    on conflict do nothing;
  else
    delete from public.story_mutes where user_id = auth.uid() and muted_id = p_user;
  end if;
  return p_muted;
end;
$$;

-- reports: a report targets a post OR a story (exactly one).
alter table public.reports alter column post_id drop not null;
alter table public.reports
  add column story_id uuid references public.stories (id) on delete cascade;
alter table public.reports
  add constraint reports_one_target check ((post_id is null) <> (story_id is null));
alter table public.reports
  add constraint reports_one_per_user_story unique (reporter_id, story_id);

-- report_story: stores the report; the viewer then skips to the next story.
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
                 where s.id = p_story and s.expires_at > now() and public.can_view_author(s.author_id)) then
    raise exception 'story not found' using errcode = '22023';
  end if;
  insert into public.reports (reporter_id, story_id, reason, note)
  values (v_uid, p_story, p_reason, nullif(btrim(p_note), ''))
  on conflict (reporter_id, story_id) do nothing;
end;
$$;

revoke all on function public.set_story_mute(uuid, boolean)          from public, anon;
revoke all on function public.report_story(uuid, text, text)         from public, anon;
grant execute on function public.set_story_mute(uuid, boolean)          to authenticated;
grant execute on function public.report_story(uuid, text, text)         to authenticated;

-- story_rail (P1): also skips authors the caller muted for stories. Same as the version in
-- 20261013140000_post_options.sql plus the story_mutes condition.
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
    and not exists (select 1 from public.mutes m
                    where m.user_id = auth.uid() and m.muted_id = s.author_id)
    and not exists (select 1 from public.story_mutes sm
                    where sm.user_id = auth.uid() and sm.muted_id = s.author_id)
  group by s.author_id, pr.username, pr.full_name, pr.avatar_url
  order by (s.author_id = auth.uid()) desc, all_seen asc, latest_at desc
  limit least(greatest(coalesce(p_limit, 30), 1), 100);
$$;
