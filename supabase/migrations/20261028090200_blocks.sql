-- =====================================================================
-- Migration: supabase/migrations/20261028090200_blocks.sql
-- Plan: docs/plans/profile-plan.md (Phase 2), specs s6-blocked-accounts.md, s12-other-profile.md
-- Adds: blocks, is_blocked_pair(), block_user(), unblock_user(), blocked_users()
-- Blocking works both ways and hides the pair from each other:
--   can_view_author / can_user_view_author / can_view_post are false for a blocked pair, and everything built on them
--   follows the posts, post media, comments, likes, stories and storage rules; the follows between the two are removed
--   and cannot be made again; notify() skips the pair; search and the people lists leave them out.
--   profile_by_id returns no row to someone the target blocked (the app shows "User not found"), and
--   blocked_by_me = true to the blocker (the app shows "You blocked this account" with Unblock).
-- Unblocking does not bring the follows back.
-- Also replaces: profile_by_id (can_message now follows who_can_message), profile_id_by_username,
--   mutual_followers_preview, followers_of, following_of, mutual_followers, suggested_profiles (appear_in_search),
--   tag_search, comment_mention_candidates, notify, follows_set_status.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. The table: the blocker reads their own rows; every write goes through block_user / unblock_user
-- ---------------------------------------------------------------------
create table public.blocks (
  blocker_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint blocks_not_self check (blocker_id <> blocked_id)
);
create index blocks_blocked_idx on public.blocks (blocked_id);

revoke all on public.blocks from anon, authenticated;
grant select on public.blocks to authenticated;
alter table public.blocks enable row level security;
create policy "blocks: read own" on public.blocks
  for select to authenticated using (blocker_id = (select auth.uid()));

-- True when either of the two blocked the other.
create or replace function public.is_blocked_pair(p_a uuid, p_b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.blocks b
     where (b.blocker_id = p_a and b.blocked_id = p_b)
        or (b.blocker_id = p_b and b.blocked_id = p_a)
  );
$$;
revoke all on function public.is_blocked_pair(uuid, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. The visibility rules every other rule is built on
-- ---------------------------------------------------------------------
create or replace function public.can_view_author(p_author uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_author = auth.uid()
      or (
        not public.is_blocked_pair(auth.uid(), p_author)
        and (
          exists (
            select 1 from public.profiles p
            where p.id = p_author and not p.is_private and p.signup_step = 0
          )
          or exists (
            select 1 from public.follows f
            where f.follower_id = auth.uid()
              and f.following_id = p_author
              and f.status = 'accepted'
          )
        )
      );
$$;

create or replace function public.can_user_view_author(p_viewer uuid, p_author uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_viewer = p_author
      or (
        not public.is_blocked_pair(p_viewer, p_author)
        and (
          exists (select 1 from public.profiles p
                  where p.id = p_author and not p.is_private and p.signup_step = 0)
          or exists (select 1 from public.follows f
                     where f.follower_id = p_viewer and f.following_id = p_author
                       and f.status = 'accepted')
        )
      );
$$;

create or replace function public.can_view_post(p_author uuid, p_visibility text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select auth.uid() is not null and (
    p_author = auth.uid()
    or (
      not public.is_blocked_pair(auth.uid(), p_author)
      and case p_visibility
            when 'public' then public.can_view_author(p_author)
            when 'followers' then public.is_accepted_follower(p_author)
            when 'close_friends' then public.is_accepted_follower(p_author)
                                      and public.is_close_friend(p_author)
            else false
          end
    )
  );
$$;

-- A follow (or request) between a blocked pair is refused; the answer is the one for a person who does not exist.
create or replace function public.follows_set_status()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if public.is_blocked_pair(new.follower_id, new.following_id) then
    raise exception 'user_unavailable' using errcode = 'P0002';
  end if;
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

-- ---------------------------------------------------------------------
-- 3. block_user / unblock_user / blocked_users
-- ---------------------------------------------------------------------
-- Errors: 22023 (yourself), P0002 (no such person). Blocking twice is a no-op.
-- Removes the follows and pending requests both ways, and the pair's close friends, mutes, post notifications and
-- notifications about each other.
create or replace function public.block_user(p_user uuid)
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
  if p_user is null or p_user = v_uid then
    raise exception 'cannot block yourself' using errcode = '22023';
  end if;
  if not exists (select 1 from public.profiles pr where pr.id = p_user and pr.signup_step = 0) then
    raise exception 'user_unavailable' using errcode = 'P0002';
  end if;

  insert into public.blocks (blocker_id, blocked_id) values (v_uid, p_user)
  on conflict do nothing;

  delete from public.follows
   where (follower_id = v_uid and following_id = p_user) or (follower_id = p_user and following_id = v_uid);
  delete from public.close_friends
   where (user_id = v_uid and friend_id = p_user) or (user_id = p_user and friend_id = v_uid);
  delete from public.mutes
   where (user_id = v_uid and muted_id = p_user) or (user_id = p_user and muted_id = v_uid);
  delete from public.story_mutes
   where (user_id = v_uid and muted_id = p_user) or (user_id = p_user and muted_id = v_uid);
  delete from public.post_subscriptions
   where (user_id = v_uid and author_id = p_user) or (user_id = p_user and author_id = v_uid);
  delete from public.notifications
   where (recipient_id = v_uid and actor_id = p_user) or (recipient_id = p_user and actor_id = v_uid);
end;
$$;

-- Idempotent. The follows removed by the block stay removed.
create or replace function public.unblock_user(p_user uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  delete from public.blocks where blocker_id = auth.uid() and blocked_id = p_user;
end;
$$;

-- The caller's blocked people, newest block first. sort_at (the time of the block) and id are the paging key.
create or replace function public.blocked_users(
  p_limit       integer default 20,
  p_before_time timestamptz default null,
  p_before_id   uuid default null
)
returns table(
  id uuid, username text, full_name text, avatar_url text, is_verified boolean, sort_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_limit integer := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_after uuid := coalesce(p_before_id, 'ffffffff-ffff-ffff-ffff-ffffffffffff'::uuid);
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  return query
    select pr.id, pr.username::text, pr.full_name, pr.avatar_url, pr.is_verified, b.created_at
      from public.blocks b
      join public.profiles pr on pr.id = b.blocked_id
     where b.blocker_id = v_uid
       and (p_before_time is null or (b.created_at, pr.id) < (p_before_time, v_after))
     order by b.created_at desc, pr.id desc
     limit v_limit;
end;
$$;

revoke all on function public.block_user(uuid) from public, anon;
revoke all on function public.unblock_user(uuid) from public, anon;
revoke all on function public.blocked_users(integer, timestamptz, uuid) from public, anon;
grant execute on function public.block_user(uuid) to authenticated;
grant execute on function public.unblock_user(uuid) to authenticated;
grant execute on function public.blocked_users(integer, timestamptz, uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 4. Profile pages and people lists leave a blocked pair out (Phase 1 functions, same signatures)
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
           pr.id <> v_uid
             and not exists (select 1 from public.blocks b where b.blocker_id = v_uid and b.blocked_id = pr.id)
             and case pr.who_can_message
                   when 'everyone' then true
                   when 'following' then exists (select 1 from public.follows f
                                                  where f.follower_id = pr.id and f.following_id = v_uid
                                                    and f.status = 'accepted')
                   else false
                 end,
           exists (select 1 from public.blocks b where b.blocker_id = v_uid and b.blocked_id = pr.id)
      from public.profiles pr
     where pr.id = p_user
       and (pr.id = v_uid or pr.signup_step = 0)
       and not exists (select 1 from public.blocks b where b.blocker_id = pr.id and b.blocked_id = v_uid);
end;
$$;

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
     and not exists (select 1 from public.blocks b where b.blocker_id = pr.id and b.blocked_id = auth.uid())
     and pr.username = lower(btrim(ltrim(btrim(coalesce(p_username, '')), '@')))::extensions.citext;
$$;

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
  if v_uid is null or v_uid = p_user or public.is_blocked_pair(v_uid, p_user) then
    return;
  end if;
  return query
    with mutual as (
      select f2.follower_id as person, row_number() over (order by f2.created_at desc, f2.follower_id desc) as rank
        from public.follows f2
        join public.follows f1 on f1.following_id = f2.follower_id and f1.follower_id = v_uid and f1.status = 'accepted'
        join public.profiles pr on pr.id = f2.follower_id and pr.signup_step = 0
       where f2.following_id = p_user and f2.status = 'accepted'
         and not public.is_blocked_pair(v_uid, f2.follower_id)
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
       and not public.is_blocked_pair(v_uid, pr.id)
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
       and not public.is_blocked_pair(v_uid, pr.id)
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
  if v_uid = p_user or public.is_blocked_pair(v_uid, p_user) then
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
       and not public.is_blocked_pair(v_uid, f2.follower_id)
       and (v_q = ''
            or position(v_q in lower(coalesce(pr.username::text, ''))) > 0
            or position(v_q in lower(coalesce(pr.full_name, ''))) > 0)
       and (p_before_time is null or (f2.created_at, pr.id) < (p_before_time, v_after))
     order by f2.created_at desc, pr.id desc
     limit v_limit;
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Search, mentions and notifications leave a blocked pair out; suggestions honour appear_in_search
-- ---------------------------------------------------------------------
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
      and p.appear_in_search
      and not public.is_blocked_pair(v_uid, p.id)
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

create or replace function public.tag_search(p_q text default null, p_limit int default 30)
returns table (id uuid, username text, full_name text, avatar_url text, can_tag boolean)
language sql
stable
security definer
set search_path = ''
as $$
  with q as (select nullif(btrim(p_q), '') as t),
  pool as (
    select f.following_id as uid, f.created_at as at, 0 as rank
    from public.follows f
    where f.follower_id = auth.uid() and f.status = 'accepted'
    union all
    select f.follower_id, f.created_at, 1
    from public.follows f
    where f.following_id = auth.uid() and f.status = 'accepted'
  ),
  people as (
    select uid, min(rank) as rank, max(at) as at from pool group by uid
  )
  select pr.id, pr.username::text, pr.full_name, pr.avatar_url, public.can_tag(pr.id)
  from people pe
  join public.profiles pr on pr.id = pe.uid and pr.signup_step = 0
  cross join q
  where pe.uid <> auth.uid()
    and not public.is_blocked_pair(auth.uid(), pr.id)
    and (q.t is null
         or pr.username ilike replace(replace(q.t, '%', ''), '_', '\_') || '%'
         or pr.full_name ilike '%' || replace(replace(q.t, '%', ''), '_', '\_') || '%')
    and (q.t is not null or pe.rank = 0)
  order by case when q.t is null then pe.at end desc nulls last, pr.username
  limit least(greatest(coalesce(p_limit, 30), 1), 50);
$$;

create or replace function public.comment_mention_candidates(
  p_post uuid, p_query text default null, p_limit integer default 3
) returns table (id uuid, username text, full_name text, avatar_url text)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_author uuid := public.comments_post_author(p_post);
  v_q      text := lower(coalesce(btrim(p_query), ''));
  v_limit  integer := least(greatest(coalesce(p_limit, 3), 1), 10);
begin
  return query
    select pr.id, pr.username::text, pr.full_name, pr.avatar_url
      from (
        select u.id, min(u.source) as source
          from (
            select v_author, 0
            union all
            select c.author_id, 0 from public.comments c
             where c.post_id = p_post and (c.hidden_at is null or c.author_id = v_uid)
            union all
            select f.follower_id, 1 from public.follows f
             where f.following_id = v_uid and f.status = 'accepted'
          ) u(id, source)
         group by u.id
      ) cand
      join public.profiles pr on pr.id = cand.id
     where pr.id <> v_uid
       and pr.username is not null
       and starts_with(lower(pr.username::text), v_q)
       and public.can_user_view_author(pr.id, v_author)
       and not public.is_blocked_pair(v_uid, pr.id)
     order by cand.source, pr.username
     limit v_limit;
end;
$$;

create or replace function public.notify(
  p_recipient uuid, p_type text, p_actor uuid, p_group text,
  p_post uuid default null, p_comment uuid default null,
  p_preview text default null, p_actor_count integer default 1
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_recipient is null or p_actor is null or p_recipient = p_actor
     or public.is_blocked_pair(p_recipient, p_actor) then
    return;
  end if;
  insert into public.notifications as n
    (recipient_id, type, actor_id, actor_count, post_id, comment_id, preview, group_key)
  values
    (p_recipient, p_type, p_actor, greatest(p_actor_count, 1), p_post, p_comment,
     left(p_preview, 140), p_group)
  on conflict (recipient_id, group_key) do update
    set actor_id    = excluded.actor_id,
        actor_count = excluded.actor_count,
        type        = excluded.type,
        comment_id  = excluded.comment_id,
        preview     = excluded.preview,
        updated_at  = now(),
        read_at     = null;
end;
$$;

