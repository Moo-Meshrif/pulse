-- Applied to the Supabase project `pulse` (xwldtqsvcpyzktysgmuv) on 2026-10-08 with the Supabase MCP.
-- Kept here for the record; do not re-apply. Source of truth: docs/specs/auth/schema.sql.

-- =====================================================================
-- Pulse · Supabase schema (v2, trimmed to docs/specs/auth)
-- Profile · Interests · Follows · Avatar upload · Suggested profiles · Sign in by email OR username
-- Resume = read profiles.signup_step directly (no RPC).
--
-- Run as a migration: supabase/migrations/<timestamp>_pulse_schema.sql
-- APPLIED 2026-10-08 to the Supabase project "pulse" (xwldtqsvcpyzktysgmuv, eu-west-1) as migrations
-- `pulse_schema` + `pulse_harden_function_grants` (the grant block at the end of this file).
--
-- Removed from the original draft because no auth spec uses it:
--   sha256_hex, profiles.phone_hash (+ index), contact_hashes, set_contact_hashes,
--   profile_stats, public_profiles view, profiles.avatar_updated_at,
--   the 'contacts' tab of suggested_profiles (S8 "From contacts" = "Coming soon"),
--   and the unused columns of suggested_profiles (bio, shared_interests, is_following).
-- =====================================================================

create extension if not exists citext with schema extensions;

-- =====================================================================
-- 1. PROFILES
-- =====================================================================
create table if not exists public.profiles (
  id               uuid primary key references auth.users (id) on delete cascade,
  username         extensions.citext unique,
  full_name        text,
  birthday         date,
  gender           text,
  bio              varchar(150),
  city             text,
  phone            text,
  avatar_url       text,
  signup_step  smallint not null default 3,   -- 3..6 = next step, 0 = complete
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),

  constraint profiles_username_format
    check (username is null or username::text ~ '^[a-z0-9._]{3,30}$'),
  constraint profiles_full_name_len
    check (full_name is null or char_length(full_name) between 1 and 80),
  constraint profiles_gender_values
    check (gender is null or gender in ('female', 'male', 'prefer_not_to_say')),
  -- S6: digits / space / + only, 7-15 digits. The app strips spaces before saving.
  constraint profiles_phone_format
    check (phone is null or phone ~ '^\+?[0-9]{7,15}$'),
  -- S5: min age 18 (the app also checks it and shows "You must be at least 18").
  constraint profiles_birthday_min_age
    check (birthday is null or birthday <= (current_date - interval '18 years')::date),
  constraint profiles_city_len
    check (city is null or char_length(city) <= 60),
  constraint profiles_signup_step_range
    check (signup_step in (0, 3, 4, 5, 6))
);

comment on column public.profiles.signup_step is
  'Next sign-up step (3 About you, 4 Profile, 5 Interests, 6 Follow). 0 = complete. The app reads this directly to resume onboarding.';

create index if not exists profiles_signup_step_idx on public.profiles (signup_step);

-- Normalize username + maintain updated_at
create or replace function public.profiles_before_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.username is not null then
    new.username := lower(trim(new.username::text));
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists profiles_before_write on public.profiles;
create trigger profiles_before_write
  before insert or update on public.profiles
  for each row execute function public.profiles_before_write();

-- Step 3 can't be left until the required fields are set
create or replace function public.profiles_guard_required()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.signup_step <> 3
     and (new.username is null or new.full_name is null or new.birthday is null) then
    raise exception 'username, full_name and birthday are required before leaving step 3'
      using errcode = 'check_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_guard_required on public.profiles;
create trigger profiles_guard_required
  before update on public.profiles
  for each row execute function public.profiles_guard_required();

-- Create the profile row when a user signs up
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Users created before this migration (e.g. test accounts) get a profile row too
insert into public.profiles (id)
select id from auth.users
on conflict (id) do nothing;

-- RLS: users read & update only their own row
alter table public.profiles enable row level security;

drop policy if exists "profiles: read own" on public.profiles;
create policy "profiles: read own"
  on public.profiles for select
  to authenticated
  using (id = (select auth.uid()));

drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own"
  on public.profiles for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- Clients may update profile fields, but not id / timestamps
revoke insert, update, delete on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant update (username, full_name, birthday, gender, bio, city, phone, avatar_url, signup_step)
  on public.profiles to authenticated;

-- Username availability (S5)
create or replace function public.is_username_available(p_username text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    lower(trim(p_username)) ~ '^[a-z0-9._]{3,30}$'
    and not exists (
      select 1 from public.profiles
      where username = lower(trim(p_username))::extensions.citext
        and id is distinct from auth.uid()
    );
$$;

revoke all on function public.is_username_available(text) from public;
grant execute on function public.is_username_available(text) to authenticated;

-- S1 "Email or username": username -> email, then signInWithPassword(email, password).
-- Callable before login (anon), so it can reveal whether a username exists and its email:
-- rate-limit it, or replace it with an Edge Function that signs in server-side.
create or replace function public.get_email_for_username(p_username text)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select u.email::text
  from public.profiles p
  join auth.users u on u.id = p.id
  where p.username = lower(trim(p_username))::extensions.citext
  limit 1;
$$;

revoke all on function public.get_email_for_username(text) from public;
grant execute on function public.get_email_for_username(text) to anon, authenticated;

-- =====================================================================
-- 2. INTERESTS (S7)
-- =====================================================================
create table if not exists public.interests (
  id          smallint primary key,
  slug        text not null unique,
  name_en     text not null,
  name_ar     text not null,
  sort_order  smallint not null default 0,
  is_active   boolean not null default true
);

alter table public.interests enable row level security;

drop policy if exists "interests: read active" on public.interests;
create policy "interests: read active"
  on public.interests for select
  to authenticated
  using (is_active);

revoke all on public.interests from anon, authenticated;
grant select on public.interests to authenticated;

insert into public.interests (id, slug, name_en, name_ar, sort_order) values
  (1,  'travel',      'Travel',        'سفر',             1),
  (2,  'photography', 'Photography',   'تصوير',           2),
  (3,  'food',        'Food',          'طعام',            3),
  (4,  'football',    'Football',      'كرة القدم',       4),
  (5,  'fitness',     'Fitness',       'لياقة بدنية',     5),
  (6,  'music',       'Music',         'موسيقى',          6),
  (7,  'tech',        'Tech',          'تقنية',           7),
  (8,  'movies_tv',   'Movies & TV',   'أفلام ومسلسلات',  8),
  (9,  'art_design',  'Art & design',  'فن وتصميم',       9),
  (10, 'books',       'Books',         'كتب',             10),
  (11, 'gaming',      'Gaming',        'ألعاب',           11),
  (12, 'fashion',     'Fashion',       'موضة',            12),
  (13, 'nature',      'Nature',        'طبيعة',           13),
  (14, 'comedy',      'Comedy',        'كوميديا',         14)
on conflict (id) do update
  set slug = excluded.slug, name_en = excluded.name_en, name_ar = excluded.name_ar,
      sort_order = excluded.sort_order;

create table if not exists public.user_interests (
  user_id      uuid not null references public.profiles (id) on delete cascade,
  interest_id  smallint not null references public.interests (id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (user_id, interest_id)
);

create index if not exists user_interests_interest_idx on public.user_interests (interest_id);

alter table public.user_interests enable row level security;

drop policy if exists "user_interests: read own" on public.user_interests;
create policy "user_interests: read own"
  on public.user_interests for select
  to authenticated
  using (user_id = (select auth.uid()));

revoke all on public.user_interests from anon, authenticated;
grant select on public.user_interests to authenticated;

-- Replace the user's interests in one transaction (S7 Continue)
create or replace function public.set_user_interests(p_ids smallint[])
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not authenticated' using errcode = '42501';
  end if;

  delete from public.user_interests where user_id = v_uid;

  insert into public.user_interests (user_id, interest_id)
  select v_uid, i.id
  from public.interests i
  where i.is_active and i.id = any (coalesce(p_ids, '{}'))
  on conflict do nothing;
end;
$$;

revoke all on function public.set_user_interests(smallint[]) from public;
grant execute on function public.set_user_interests(smallint[]) to authenticated;

-- =====================================================================
-- 3. FOLLOWS (S8)
-- =====================================================================
create table if not exists public.follows (
  follower_id   uuid not null references public.profiles (id) on delete cascade,
  following_id  uuid not null references public.profiles (id) on delete cascade,
  created_at    timestamptz not null default now(),
  primary key (follower_id, following_id),
  constraint follows_no_self check (follower_id <> following_id)
);

create index if not exists follows_following_idx on public.follows (following_id);

alter table public.follows enable row level security;

drop policy if exists "follows: read" on public.follows;
create policy "follows: read"
  on public.follows for select
  to authenticated
  using (true);

drop policy if exists "follows: insert own" on public.follows;
create policy "follows: insert own"
  on public.follows for insert
  to authenticated
  with check (follower_id = (select auth.uid()));

drop policy if exists "follows: delete own" on public.follows;
create policy "follows: delete own"
  on public.follows for delete
  to authenticated
  using (follower_id = (select auth.uid()));

revoke all on public.follows from anon, authenticated;
grant select, insert, delete on public.follows to authenticated;

-- "Follow all" (idempotent; skips self and unfinished profiles)
create or replace function public.follow_many(p_ids uuid[])
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_count integer;
begin
  if v_uid is null then
    raise exception 'not authenticated' using errcode = '42501';
  end if;

  insert into public.follows (follower_id, following_id)
  select v_uid, p.id
  from public.profiles p
  where p.id = any (coalesce(p_ids, '{}'))
    and p.id <> v_uid
    and p.signup_step = 0
  on conflict do nothing;

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.follow_many(uuid[]) from public;
grant execute on function public.follow_many(uuid[]) to authenticated;

-- =====================================================================
-- 4. SUGGESTED PROFILES (S8 tabs: 'suggested' | 'popular'; 'From contacts' is "Coming soon")
-- reason_kind: 'mutual' (mutual_count) | 'city' (city) | 'popular'
-- The app builds the localized meta line from reason_kind + mutual_count / city.
-- =====================================================================
create or replace function public.suggested_profiles(
  p_tab    text,
  p_limit  integer default 20,
  p_offset integer default 0
)
returns table (
  id            uuid,
  username      text,
  full_name     text,
  avatar_url    text,
  city          text,
  reason_kind   text,
  mutual_count  integer
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
    raise exception 'not authenticated' using errcode = '42501';
  end if;
  if p_tab not in ('suggested', 'popular') then
    raise exception 'invalid tab: %', p_tab using errcode = '22023';
  end if;

  return query
  with candidates as (
    select p.*
    from public.profiles p
    where p.signup_step = 0
      and p.id <> v_uid
      and not exists (
        select 1 from public.follows f
        where f.follower_id = v_uid and f.following_id = p.id
      )
  ),
  scored as (
    select
      c.id, c.username::text as username, c.full_name, c.avatar_url, c.city,
      (select count(*)::int
         from public.follows f1
         join public.follows f2 on f2.follower_id = f1.following_id
        where f1.follower_id = v_uid and f2.following_id = c.id)            as mutual_count,
      (select count(*)::int
         from public.user_interests a
         join public.user_interests b on b.interest_id = a.interest_id
        where a.user_id = v_uid and b.user_id = c.id)                        as shared_interests,
      (select count(*) from public.follows f where f.following_id = c.id)  as follower_count
    from candidates c
  )
  select
    s.id, s.username, s.full_name, s.avatar_url, s.city,
    case
      when p_tab = 'popular'  then 'popular'
      when s.mutual_count > 0 then 'mutual'
      when s.city is not null then 'city'
      else 'popular'
    end as reason_kind,
    s.mutual_count
  from scored s
  where p_tab = 'popular' or s.mutual_count > 0 or s.shared_interests > 0
  order by
    case when p_tab = 'popular' then s.follower_count end desc nulls last,
    s.mutual_count desc,
    s.shared_interests desc,
    s.follower_count desc,
    s.id
  limit greatest(1, least(coalesce(p_limit, 20), 50))
  offset greatest(0, coalesce(p_offset, 0));
end;
$$;

revoke all on function public.suggested_profiles(text, integer, integer) from public;
grant execute on function public.suggested_profiles(text, integer, integer) to authenticated;

-- =====================================================================
-- 5. STORAGE: avatars (path: avatars/{auth.uid()}/avatar.jpg)
-- =====================================================================
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "avatars: public read" on storage.objects;
create policy "avatars: public read"
  on storage.objects for select
  using (bucket_id = 'avatars');

drop policy if exists "avatars: owner insert" on storage.objects;
create policy "avatars: owner insert"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "avatars: owner update" on storage.objects;
create policy "avatars: owner update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "avatars: owner delete" on storage.objects;
create policy "avatars: owner delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
