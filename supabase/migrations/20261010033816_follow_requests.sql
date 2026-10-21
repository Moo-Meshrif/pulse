-- =====================================================================
-- FOLLOW REQUESTS
-- Public profile: a follow is accepted at once. Private profile: a follow is a pending request the
-- owner accepts (UPDATE status) or declines (DELETE). Only accepted follows count.
-- =====================================================================
alter table public.profiles
  add column if not exists is_private boolean not null default false;

-- Existing rows keep working as accepted follows.
alter table public.follows
  add column if not exists status text not null default 'accepted';

alter table public.follows
  drop constraint if exists follows_status_check;
alter table public.follows
  add constraint follows_status_check check (status in ('pending', 'accepted'));

-- Pending requests are listed per followed user, newest first.
create index if not exists follows_pending_idx
  on public.follows (following_id, created_at desc)
  where status = 'pending';

-- The status is decided here, never by the client.
create or replace function public.follows_set_status()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.status := case
    when exists (
      select 1 from public.profiles p
      where p.id = new.following_id and p.is_private
    ) then 'pending'
    else 'accepted'
  end;
  return new;
end;
$$;

revoke all on function public.follows_set_status() from public, anon, authenticated;

drop trigger if exists follows_set_status on public.follows;
create trigger follows_set_status
  before insert on public.follows
  for each row execute function public.follows_set_status();

-- The followed user accepts; nobody else can change a row, and only `status` is writable.
drop policy if exists "follows: accept own requests" on public.follows;
create policy "follows: accept own requests"
  on public.follows for update
  to authenticated
  using (following_id = (select auth.uid()) and status = 'pending')
  with check (following_id = (select auth.uid()) and status = 'accepted');

-- The follower cancels / unfollows; the followed user declines / removes.
drop policy if exists "follows: delete own" on public.follows;
create policy "follows: delete own"
  on public.follows for delete
  to authenticated
  using (
    follower_id = (select auth.uid()) or following_id = (select auth.uid())
  );

grant update (status) on public.follows to authenticated;

-- ---------------------------------------------------------------------
-- Requests waiting for the signed-in user (Follow requests screen).
-- mutual_count: people the user follows who also follow the requester.
-- ---------------------------------------------------------------------
create or replace function public.follow_requests(
  p_limit  integer default 20,
  p_offset integer default 0
)
returns table (
  id            uuid,
  username      text,
  full_name     text,
  avatar_url    text,
  city          text,
  mutual_count  integer,
  requested_at  timestamptz
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

  return query
  select
    p.id, p.username::text, p.full_name, p.avatar_url, p.city,
    (select count(*)::int
       from public.follows f1
       join public.follows f2 on f2.follower_id = f1.following_id
      where f1.follower_id = v_uid and f1.status = 'accepted'
        and f2.following_id = p.id and f2.status = 'accepted') as mutual_count,
    f.created_at as requested_at
  from public.follows f
  join public.profiles p on p.id = f.follower_id
  where f.following_id = v_uid
    and f.status = 'pending'
  order by f.created_at desc
  limit greatest(1, least(coalesce(p_limit, 20), 50))
  offset greatest(0, coalesce(p_offset, 0));
end;
$$;

revoke all on function public.follow_requests(integer, integer) from public, anon;
grant execute on function public.follow_requests(integer, integer) to authenticated;

-- ---------------------------------------------------------------------
-- suggested_profiles: now also returns is_private, and counts accepted follows only.
-- (The return type changes, so the function is dropped and created again.)
-- ---------------------------------------------------------------------
drop function if exists public.suggested_profiles(text, integer, integer);

create function public.suggested_profiles(
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
  mutual_count  integer,
  is_private    boolean
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
      c.id, c.username::text as username, c.full_name, c.avatar_url, c.city, c.is_private,
      (select count(*)::int
         from public.follows f1
         join public.follows f2 on f2.follower_id = f1.following_id
        where f1.follower_id = v_uid and f1.status = 'accepted'
          and f2.following_id = c.id and f2.status = 'accepted')             as mutual_count,
      (select count(*)::int
         from public.user_interests a
         join public.user_interests b on b.interest_id = a.interest_id
        where a.user_id = v_uid and b.user_id = c.id)                        as shared_interests,
      (select count(*) from public.follows f
        where f.following_id = c.id and f.status = 'accepted')               as follower_count
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
    s.mutual_count,
    s.is_private
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

revoke all on function public.suggested_profiles(text, integer, integer) from public, anon;
grant execute on function public.suggested_profiles(text, integer, integer) to authenticated;
