-- =====================================================================
-- Migration: supabase/migrations/20261027223146_profile_pages.sql
-- Plan: docs/plans/profile-plan.md (Phase 1), specs docs/specs/profile/screens/s1-profile.md, s12-other-profile.md, s13-people-list.md
-- Adds: profiles.cover_url, profiles.is_verified, the public `covers` bucket
--       profile_by_id(...)             the profile page header: fields, counts, follow state
--       profile_id_by_username(...)    @mention -> id
--       mutual_followers_preview(...)  "Followed by": two names, up to three avatars, total
--       user_posts(...)                the Posts / Tagged grids of a person
--       saved_posts(...)               the caller's own Saved grid
--       followers_of / following_of / mutual_followers   the people lists
-- Blocking (Phase 2) later replaces profile_by_id with `create or replace` to hide a profile from someone
--       who is blocked; until then blocked_by_me is always false.
-- Settings that do not exist yet (who_can_message) are answered as "everyone" until Phase 2 adds them.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Columns and the covers bucket
--    is_verified is set by the team only: no client grant on it.
-- ---------------------------------------------------------------------
alter table public.profiles
  add column cover_url   text,
  add column is_verified boolean not null default false;

grant update (cover_url) on public.profiles to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('covers', 'covers', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "covers: public read" on storage.objects;
create policy "covers: public read"
  on storage.objects for select
  using (bucket_id = 'covers');

drop policy if exists "covers: owner insert" on storage.objects;
create policy "covers: owner insert"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'covers' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "covers: owner update" on storage.objects;
create policy "covers: owner update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'covers' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'covers' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "covers: owner delete" on storage.objects;
create policy "covers: owner delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'covers' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- ---------------------------------------------------------------------
-- 2. profile_by_id
--    One row, or none when the person does not exist or has not finished signing up (the app shows
--    "User not found"). Never returns phone, birthday or email.
--    posts: the person's posts anyone could be told about (everything but Only me; all of them for yourself).
--    followers / following: accepted follows only.
--    i_follow: none | pending | accepted.  follows_me: they follow the caller (accepted).
--    can_message: true until Phase 2 adds who_can_message.  blocked_by_me: false until Phase 2 adds blocks.
-- ---------------------------------------------------------------------
create or replace function public.profile_by_id(p_user uuid)
returns table(
  id uuid, username text, full_name text, bio text, city text, avatar_url text, cover_url text,
  is_verified boolean, is_private boolean,
  posts_count bigint, followers_count bigint, following_count bigint,
  i_follow text, follows_me boolean, can_message boolean, blocked_by_me boolean
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
  return query
    select pr.id, pr.username::text, pr.full_name, pr.bio::text, pr.city, pr.avatar_url, pr.cover_url,
           pr.is_verified, pr.is_private,
           (select count(*) from public.posts po
             where po.author_id = pr.id and po.kind = 'post'
               and (pr.id = v_uid or po.visibility <> 'only_me')),
           (select count(*) from public.follows f where f.following_id = pr.id and f.status = 'accepted'),
           (select count(*) from public.follows f where f.follower_id = pr.id and f.status = 'accepted'),
           case when pr.id = v_uid then 'none'
                else coalesce((select f.status from public.follows f
                                where f.follower_id = v_uid and f.following_id = pr.id), 'none') end,
           exists (select 1 from public.follows f
                    where f.follower_id = pr.id and f.following_id = v_uid and f.status = 'accepted'),
           pr.id <> v_uid,
           false
      from public.profiles pr
     where pr.id = p_user
       and (pr.id = v_uid or pr.signup_step = 0);
end;
$$;

-- ---------------------------------------------------------------------
-- 3. profile_id_by_username (the @mention tap). Null when nobody has that name.
-- ---------------------------------------------------------------------
create or replace function public.profile_id_by_username(p_username text)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select pr.id
    from public.profiles pr
   where auth.uid() is not null
     and pr.signup_step = 0
     and pr.username = lower(btrim(ltrim(btrim(coalesce(p_username, '')), '@')))::extensions.citext;
$$;

-- ---------------------------------------------------------------------
-- 4. mutual_followers_preview
--    People the caller follows who follow p_user (both accepted), most recent follow of p_user first.
--    names: first and second; avatars: up to three, in the same order; total: how many in all.
--    No row when there are none, or p_user is the caller.
-- ---------------------------------------------------------------------
create or replace function public.mutual_followers_preview(p_user uuid)
returns table(
  first_id uuid, first_username text, first_full_name text,
  second_username text, second_full_name text,
  total integer, avatars jsonb
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null or v_uid = p_user then
    return;
  end if;
  return query
    with mutual as (
      select f2.follower_id as person, row_number() over (order by f2.created_at desc, f2.follower_id desc) as rank
        from public.follows f2
        join public.follows f1 on f1.following_id = f2.follower_id and f1.follower_id = v_uid and f1.status = 'accepted'
        join public.profiles pr on pr.id = f2.follower_id and pr.signup_step = 0
       where f2.following_id = p_user and f2.status = 'accepted'
    )
    select p1.id, p1.username::text, p1.full_name,
           p2.username::text, p2.full_name,
           (select count(*) from mutual)::integer,
           (select jsonb_agg(jsonb_build_object('id', p.id, 'name', coalesce(nullif(btrim(p.full_name), ''), p.username::text),
                                                'avatar_url', p.avatar_url) order by m.rank)
              from mutual m join public.profiles p on p.id = m.person
             where m.rank <= 3)
      from mutual m1
      join public.profiles p1 on p1.id = m1.person
      left join mutual m2 on m2.rank = 2
      left join public.profiles p2 on p2.id = m2.person
     where m1.rank = 1;
end;
$$;

-- ---------------------------------------------------------------------
-- 5. The grids
--    One row per post: first media for the tile, media_count to tell a photo from an album, first_type for the
--    video badge. sort_at is the paging key together with id: pass the last row's sort_at and id as
--    p_before_time / p_before_id.
-- ---------------------------------------------------------------------

-- user_posts: p_kind 'posts' (their own posts) or 'tagged' (posts they are tagged in). Only posts the caller
-- may see (can_view_post). Tagged is also hidden when the caller may not see the person (private, not followed).
-- Shorts are not here yet: any other p_kind is 22023.
create or replace function public.user_posts(
  p_user        uuid,
  p_kind        text default 'posts',
  p_limit       integer default 24,
  p_before_time timestamptz default null,
  p_before_id   uuid default null
)
returns table(
  id uuid, author_id uuid, sort_at timestamptz, media_count smallint,
  first_type text, first_path text, first_thumb_path text, first_blurhash text, first_width integer, first_height integer
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_limit integer := least(greatest(coalesce(p_limit, 24), 1), 50);
  v_after uuid := coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid);
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_kind is null or p_kind not in ('posts', 'tagged') then
    raise exception 'unknown kind %', p_kind using errcode = '22023';
  end if;
  if p_kind = 'tagged' and not public.can_user_view_author(v_uid, p_user) then
    return;
  end if;
  return query
    select po.id, po.author_id, po.created_at, po.media_count,
           m.type, m.path, m.thumb_path, m.blurhash, m.width, m.height
      from public.posts po
      left join public.post_media m on m.post_id = po.id and m.position = 0
     where po.kind = 'post'
       and (case when p_kind = 'posts'
                 then po.author_id = p_user
                 else exists (select 1 from public.post_tags t where t.post_id = po.id and t.user_id = p_user) end)
       and public.can_view_post(po.author_id, po.visibility)
       and (p_before_time is null or (po.created_at, po.id) < (p_before_time, v_after))
     order by po.created_at desc, po.id desc
     limit v_limit;
end;
$$;

-- saved_posts: the caller's saved posts they may still see, last saved first (sort_at = when it was saved).
create or replace function public.saved_posts(
  p_limit       integer default 24,
  p_before_time timestamptz default null,
  p_before_id   uuid default null
)
returns table(
  id uuid, author_id uuid, sort_at timestamptz, media_count smallint,
  first_type text, first_path text, first_thumb_path text, first_blurhash text, first_width integer, first_height integer
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_limit integer := least(greatest(coalesce(p_limit, 24), 1), 50);
  v_after uuid := coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid);
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  return query
    select po.id, po.author_id, s.created_at, po.media_count,
           m.type, m.path, m.thumb_path, m.blurhash, m.width, m.height
      from public.post_saves s
      join public.posts po on po.id = s.post_id and po.kind = 'post'
      left join public.post_media m on m.post_id = po.id and m.position = 0
     where s.user_id = v_uid
       and public.can_view_post(po.author_id, po.visibility)
       and (p_before_time is null or (s.created_at, po.id) < (p_before_time, v_after))
     order by s.created_at desc, po.id desc
     limit v_limit;
end;
$$;

-- ---------------------------------------------------------------------
-- 6. The people lists
--    Rows: the person, follow_status (the caller's follow of them: none | pending | accepted), follows_me,
--    and sort_at (paging key with id). Searchable by name or @name. Accepted follows only.
--    followers_of / following_of: empty when the caller may not see p_user (private, not followed).
--    mutual_followers: people the caller follows who follow p_user.
-- ---------------------------------------------------------------------
create or replace function public.followers_of(
  p_user        uuid,
  p_q           text default null,
  p_limit       integer default 20,
  p_before_time timestamptz default null,
  p_before_id   uuid default null
)
returns table(
  id uuid, username text, full_name text, avatar_url text, is_verified boolean,
  follow_status text, follows_me boolean, sort_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_q     text := lower(coalesce(btrim(p_q), ''));
  v_limit integer := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_after uuid := coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid);
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not public.can_user_view_author(v_uid, p_user) then
    return;
  end if;
  return query
    select pr.id, pr.username::text, pr.full_name, pr.avatar_url, pr.is_verified,
           coalesce(mine.status, 'none'),
           exists (select 1 from public.follows fm
                    where fm.follower_id = pr.id and fm.following_id = v_uid and fm.status = 'accepted'),
           f.created_at
      from public.follows f
      join public.profiles pr on pr.id = f.follower_id and pr.signup_step = 0
      left join public.follows mine on mine.follower_id = v_uid and mine.following_id = pr.id
     where f.following_id = p_user and f.status = 'accepted'
       and (v_q = ''
            or position(v_q in lower(coalesce(pr.username::text, ''))) > 0
            or position(v_q in lower(coalesce(pr.full_name, ''))) > 0)
       and (p_before_time is null or (f.created_at, pr.id) < (p_before_time, v_after))
     order by f.created_at desc, pr.id desc
     limit v_limit;
end;
$$;

create or replace function public.following_of(
  p_user        uuid,
  p_q           text default null,
  p_limit       integer default 20,
  p_before_time timestamptz default null,
  p_before_id   uuid default null
)
returns table(
  id uuid, username text, full_name text, avatar_url text, is_verified boolean,
  follow_status text, follows_me boolean, sort_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_q     text := lower(coalesce(btrim(p_q), ''));
  v_limit integer := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_after uuid := coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid);
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not public.can_user_view_author(v_uid, p_user) then
    return;
  end if;
  return query
    select pr.id, pr.username::text, pr.full_name, pr.avatar_url, pr.is_verified,
           coalesce(mine.status, 'none'),
           exists (select 1 from public.follows fm
                    where fm.follower_id = pr.id and fm.following_id = v_uid and fm.status = 'accepted'),
           f.created_at
      from public.follows f
      join public.profiles pr on pr.id = f.following_id and pr.signup_step = 0
      left join public.follows mine on mine.follower_id = v_uid and mine.following_id = pr.id
     where f.follower_id = p_user and f.status = 'accepted'
       and (v_q = ''
            or position(v_q in lower(coalesce(pr.username::text, ''))) > 0
            or position(v_q in lower(coalesce(pr.full_name, ''))) > 0)
       and (p_before_time is null or (f.created_at, pr.id) < (p_before_time, v_after))
     order by f.created_at desc, pr.id desc
     limit v_limit;
end;
$$;

create or replace function public.mutual_followers(
  p_user        uuid,
  p_q           text default null,
  p_limit       integer default 20,
  p_before_time timestamptz default null,
  p_before_id   uuid default null
)
returns table(
  id uuid, username text, full_name text, avatar_url text, is_verified boolean,
  follow_status text, follows_me boolean, sort_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_q     text := lower(coalesce(btrim(p_q), ''));
  v_limit integer := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_after uuid := coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid);
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if v_uid = p_user then
    return;
  end if;
  return query
    select pr.id, pr.username::text, pr.full_name, pr.avatar_url, pr.is_verified,
           'accepted'::text,
           exists (select 1 from public.follows fm
                    where fm.follower_id = pr.id and fm.following_id = v_uid and fm.status = 'accepted'),
           f2.created_at
      from public.follows f2
      join public.follows f1 on f1.following_id = f2.follower_id and f1.follower_id = v_uid and f1.status = 'accepted'
      join public.profiles pr on pr.id = f2.follower_id and pr.signup_step = 0
     where f2.following_id = p_user and f2.status = 'accepted'
       and (v_q = ''
            or position(v_q in lower(coalesce(pr.username::text, ''))) > 0
            or position(v_q in lower(coalesce(pr.full_name, ''))) > 0)
       and (p_before_time is null or (f2.created_at, pr.id) < (p_before_time, v_after))
     order by f2.created_at desc, pr.id desc
     limit v_limit;
end;
$$;

-- ---------------------------------------------------------------------
-- 7. Who can run what: signed-in users only
-- ---------------------------------------------------------------------
revoke all on function public.profile_by_id(uuid) from public, anon;
revoke all on function public.profile_id_by_username(text) from public, anon;
revoke all on function public.mutual_followers_preview(uuid) from public, anon;
revoke all on function public.user_posts(uuid, text, integer, timestamptz, uuid) from public, anon;
revoke all on function public.saved_posts(integer, timestamptz, uuid) from public, anon;
revoke all on function public.followers_of(uuid, text, integer, timestamptz, uuid) from public, anon;
revoke all on function public.following_of(uuid, text, integer, timestamptz, uuid) from public, anon;
revoke all on function public.mutual_followers(uuid, text, integer, timestamptz, uuid) from public, anon;
grant execute on function public.profile_by_id(uuid) to authenticated;
grant execute on function public.profile_id_by_username(text) to authenticated;
grant execute on function public.mutual_followers_preview(uuid) to authenticated;
grant execute on function public.user_posts(uuid, text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.saved_posts(integer, timestamptz, uuid) to authenticated;
grant execute on function public.followers_of(uuid, text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.following_of(uuid, text, integer, timestamptz, uuid) to authenticated;
grant execute on function public.mutual_followers(uuid, text, integer, timestamptz, uuid) to authenticated;
