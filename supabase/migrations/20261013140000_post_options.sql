-- =====================================================================
-- Pulse · Post options (S2) — SPEC-LEVEL migration, NOT applied
-- Migration: supabase/migrations/20261013120000_post_options.sql
-- Depends on: 20261012120000_home_feed.sql (schema.sql)
-- Adds: posts.comments_enabled, post_hides, mutes, reports,
--       RPCs hide_post, set_mute, report_post, and replaces home_feed /
--       story_rail so hidden posts and muted authors are filtered.
-- Review before applying.
-- =====================================================================

-- 1. Comments on/off (Turn off comments). Enforced in the insert policy.
alter table public.posts add column comments_enabled boolean not null default true;

grant update (caption, location, comments_enabled) on public.posts to authenticated;

drop policy "comments: insert own" on public.comments;
create policy "comments: insert own" on public.comments
  for insert to authenticated with check (
    author_id = auth.uid()
    and exists (
      select 1 from public.posts p
      where p.id = post_id
        and public.can_view_author(p.author_id)
        and p.comments_enabled
    )
  );

-- 2. post_hides (Not interested, and every submitted report)
create table public.post_hides (
  user_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  post_id    uuid not null references public.posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, post_id)
);

-- 3. mutes (hide an author without unfollowing)
create table public.mutes (
  user_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  muted_id   uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, muted_id),
  constraint mutes_not_self check (user_id <> muted_id)
);

-- 4. reports (insert-only for clients, written through report_post)
create table public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  post_id     uuid not null references public.posts (id) on delete cascade,
  reason      text not null,
  note        text,
  created_at  timestamptz not null default now(),
  constraint reports_reason check (reason in
    ('spam','nudity','hate','bullying','violence','false_info','other')),
  constraint reports_note_len check (note is null or char_length(note) between 1 and 500),
  constraint reports_one_per_user unique (reporter_id, post_id)
);

revoke all on public.post_hides, public.mutes, public.reports from anon, authenticated;
grant select, insert, delete on public.post_hides to authenticated;
grant select, insert, delete on public.mutes      to authenticated;
-- reports: no direct client access; report_post() is security definer

alter table public.post_hides enable row level security;
alter table public.mutes      enable row level security;
alter table public.reports    enable row level security;

create policy "post_hides: own" on public.post_hides
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "mutes: own" on public.mutes
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- 5. RPCs
-- hide_post: Not interested (p_hidden true) or Undo (false). Idempotent.
create or replace function public.hide_post(p_post uuid, p_hidden boolean)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_hidden then
    insert into public.post_hides (user_id, post_id) values (auth.uid(), p_post)
    on conflict do nothing;
  else
    delete from public.post_hides where user_id = auth.uid() and post_id = p_post;
  end if;
  return p_hidden;
end;
$$;

-- set_mute: Mute / Undo. Idempotent.
create or replace function public.set_mute(p_user uuid, p_muted boolean)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_muted then
    insert into public.mutes (user_id, muted_id) values (auth.uid(), p_user)
    on conflict do nothing;
  else
    delete from public.mutes where user_id = auth.uid() and muted_id = p_user;
  end if;
  return p_muted;
end;
$$;

-- report_post: stores the report and hides the post for the reporter.
create or replace function public.report_post(p_post uuid, p_reason text, p_note text default null)
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
  if not exists (select 1 from public.posts p
                 where p.id = p_post and public.can_view_author(p.author_id)) then
    raise exception 'post not found' using errcode = '22023';
  end if;
  insert into public.reports (reporter_id, post_id, reason, note)
  values (v_uid, p_post, p_reason, nullif(btrim(p_note), ''))
  on conflict (reporter_id, post_id) do nothing;
  insert into public.post_hides (user_id, post_id) values (v_uid, p_post)
  on conflict do nothing;
end;
$$;

revoke all on function public.hide_post(uuid, boolean)            from public, anon;
revoke all on function public.set_mute(uuid, boolean)             from public, anon;
revoke all on function public.report_post(uuid, text, text)       from public, anon;
grant execute on function public.hide_post(uuid, boolean)         to authenticated;
grant execute on function public.set_mute(uuid, boolean)          to authenticated;
grant execute on function public.report_post(uuid, text, text)    to authenticated;

-- 6. home_feed: same as the first migration, plus comments_enabled and the
--    hide / mute filters. The return type changes, so drop first.
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
         pg.created_at,
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

-- 7. story_rail: muted authors leave the rail. Body otherwise unchanged
--    (people with active stories; "me" only when you have an active story).
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
  group by s.author_id, pr.username, pr.full_name, pr.avatar_url
  order by (s.author_id = auth.uid()) desc, all_seen asc, latest_at desc
  limit least(greatest(coalesce(p_limit, 30), 1), 100);
$$;

-- 8. create_post: add p_comments_enabled (New post "Allow comments"). The
--    signature changes, so drop the old one. Body otherwise as in
--    20261012120000_home_feed.sql.
drop function public.create_post(uuid, text, text, text, jsonb);
create function public.create_post(
  p_id               uuid,
  p_kind             text default 'post',
  p_caption          text default null,
  p_location         text default null,
  p_media            jsonb default '[]'::jsonb,
  p_comments_enabled boolean default true
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_prefix  text;
  v_count   int;
  v_caption text := nullif(btrim(p_caption), '');
  v_loc     text := nullif(btrim(p_location), '');
  v_item    jsonb;
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
  if jsonb_typeof(coalesce(p_media, '[]'::jsonb)) <> 'array' then
    raise exception 'media must be an array' using errcode = '22023';
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

  insert into public.posts (id, author_id, kind, caption, location, media_count, comments_enabled)
  values (p_id, v_uid, p_kind, v_caption, v_loc, v_count, coalesce(p_comments_enabled, true));

  insert into public.post_media (post_id, position, type, path, thumb_path, width, height, duration_ms, blurhash)
  select p_id, (e.ord - 1)::smallint, e.item->>'type', e.item->>'path', e.item->>'thumb_path',
         (e.item->>'width')::int, (e.item->>'height')::int,
         (e.item->>'duration_ms')::int, e.item->>'blurhash'
  from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) with ordinality as e(item, ord);

  return p_id;
end;
$$;
revoke all on function public.create_post(uuid, text, text, text, jsonb, boolean) from public, anon;
grant execute on function public.create_post(uuid, text, text, text, jsonb, boolean) to authenticated;
