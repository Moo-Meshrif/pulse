-- =====================================================================
-- Pulse · Content changes: what changed in posts, shorts and stories since a moment
-- Migration: supabase/migrations/20261021190119_content_changes.sql
-- Plan: docs/plans/content-changes-plan.md (Phase 1)
-- Adds: content_deletions (the log of deleted posts, shorts and stories), changes_since(),
--       posts_by_ids(), post_counts(); posts.updated_at no longer moves for a like or comment;
--       an edit of a post's pictures or tags moves it.
-- A post and a short are both rows of public.posts (kind 'post' | 'short'). Stories have no edit: they
-- are new (created_at) or gone (the log).
-- =====================================================================

-- 1. A like or a comment only moves a counter: it is not a change of the post. -------------------------
create or replace function public.posts_touch()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (to_jsonb(new) - 'like_count' - 'comment_count' - 'updated_at')
       = (to_jsonb(old) - 'like_count' - 'comment_count' - 'updated_at')
     and (new.like_count is distinct from old.like_count
          or new.comment_count is distinct from old.comment_count) then
    new.updated_at := old.updated_at;
  else
    new.updated_at := now();
  end if;
  return new;
end;
$$;

-- Pictures and tags live in their own rows: changing them moves the post (the update changes nothing
-- else, so posts_touch sets the time).
create or replace function public.posts_touch_from_child()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.posts set id = id where id = coalesce(new.post_id, old.post_id);
  return null;
end;
$$;

drop trigger if exists post_media_touch_post on public.post_media;
create trigger post_media_touch_post
  after insert or delete on public.post_media
  for each row execute function public.posts_touch_from_child();

drop trigger if exists post_tags_touch_post on public.post_tags;
create trigger post_tags_touch_post
  after insert or delete on public.post_tags
  for each row execute function public.posts_touch_from_child();

-- 2. Indexes for "since" reads. -------------------------------------------------------------------------
create index if not exists posts_changes_idx on public.posts (kind, updated_at, id);
create index if not exists stories_changes_idx on public.stories (created_at, id);

-- 3. The log of deleted content: an id, its kind and its author, never the content. ------------------------
create table if not exists public.content_deletions (
  id         uuid primary key,
  kind       text not null check (kind in ('post', 'short', 'story')),
  author_id  uuid not null,
  deleted_at timestamptz not null default now()
);
create index if not exists content_deletions_since_idx on public.content_deletions (kind, deleted_at, id);

alter table public.content_deletions enable row level security;
revoke all on public.content_deletions from public, anon, authenticated;

comment on table public.content_deletions is
  'Deleted posts, shorts and stories (id, kind, author) for changes_since(). Written by triggers, cleared after 3 days.';

create or replace function public.log_content_deletion()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_table_name = 'stories' then
    insert into public.content_deletions (id, kind, author_id)
    values (old.id, 'story', old.author_id)
    on conflict (id) do nothing;
  else
    insert into public.content_deletions (id, kind, author_id)
    values (old.id, old.kind, old.author_id)
    on conflict (id) do nothing;
  end if;
  return null;
end;
$$;

drop trigger if exists posts_log_deletion on public.posts;
create trigger posts_log_deletion
  after delete on public.posts
  for each row execute function public.log_content_deletion();

drop trigger if exists stories_log_deletion on public.stories;
create trigger stories_log_deletion
  after delete on public.stories
  for each row execute function public.log_content_deletion();

create or replace function public.purge_content_deletions()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.content_deletions where deleted_at < now() - interval '3 days';
$$;
revoke all on function public.purge_content_deletions() from public, anon, authenticated;

select cron.schedule('purge-content-deletions', '29 3 * * *', 'select public.purge_content_deletions()');

-- 4. What changed since a point. -------------------------------------------------------------------------
-- p_kind: 'post' | 'short' | 'story'. The point is (p_after_at, p_after_id), both from the last answer's
-- next_at / next_id; none, or older than the log keeps (3 days), or more than 300 changes behind, answers
-- {reset: true}: load normally, then continue from next_at.
-- Answer: {reset, ops: [{op, id, at}], next_at, next_id, has_more}. op is 'upsert' (new or changed, the
-- caller can see it: read it with posts_by_ids), 'remove' (changed and the caller can no longer see it) or
-- 'delete'. Only the caller's own and accepted follows' content. The point trails now() by 5 seconds so a
-- slow transaction is not missed; every op is safe to apply twice.
create or replace function public.changes_since(
  p_kind     text,
  p_after_at timestamptz default null,
  p_after_id uuid default null,
  p_limit    integer default 50
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_limit   integer := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_max     constant integer := 300;
  v_lag     constant interval := interval '5 seconds';
  v_keep    constant interval := interval '3 days';
  v_zero    constant uuid := '00000000-0000-0000-0000-000000000000';
  v_all     jsonb;
  v_n       integer;
  v_ops     jsonb;
  v_has_more boolean;
  v_last    jsonb;
  v_next_at timestamptz;
  v_next_id uuid;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_kind not in ('post', 'short', 'story') then
    raise exception 'invalid kind' using errcode = '22023';
  end if;

  if p_after_at is null or p_after_at < now() - v_keep then
    return jsonb_build_object('reset', true, 'ops', '[]'::jsonb,
                              'next_at', now() - v_lag, 'next_id', null, 'has_more', false);
  end if;

  select coalesce(jsonb_agg(jsonb_build_object('op', c.op, 'id', c.id, 'at', c.at) order by c.at, c.id),
                  '[]'::jsonb)
  into v_all
  from (
    select * from (
      select p.updated_at as at, p.id,
             case when public.can_view_post(p.author_id, p.visibility)
                       and not exists (select 1 from public.post_hides h
                                       where h.user_id = v_uid and h.post_id = p.id)
                       and not exists (select 1 from public.mutes m
                                       where m.user_id = v_uid and m.muted_id = p.author_id)
                  then 'upsert' else 'remove' end as op
      from public.posts p
      where p_kind <> 'story'
        and p.kind = p_kind
        and (p.updated_at, p.id) > (p_after_at, coalesce(p_after_id, v_zero))
        and (p.author_id = v_uid
             or exists (select 1 from public.follows f
                        where f.follower_id = v_uid and f.following_id = p.author_id
                          and f.status = 'accepted'))
      union all
      select s.created_at, s.id, 'upsert'
      from public.stories s
      where p_kind = 'story'
        and s.expires_at > now()
        and (s.created_at, s.id) > (p_after_at, coalesce(p_after_id, v_zero))
        and (s.author_id = v_uid
             or (exists (select 1 from public.follows f
                         where f.follower_id = v_uid and f.following_id = s.author_id
                           and f.status = 'accepted')
                 and public.can_view_story(s.author_id, s.audience)))
        and not exists (select 1 from public.mutes m
                        where m.user_id = v_uid and m.muted_id = s.author_id)
        and not exists (select 1 from public.story_mutes sm
                        where sm.user_id = v_uid and sm.muted_id = s.author_id)
      union all
      select d.deleted_at, d.id, 'delete'
      from public.content_deletions d
      where d.kind = p_kind
        and (d.deleted_at, d.id) > (p_after_at, coalesce(p_after_id, v_zero))
        and (d.author_id = v_uid
             or exists (select 1 from public.follows f
                        where f.follower_id = v_uid and f.following_id = d.author_id
                          and f.status = 'accepted'))
    ) u
    order by u.at, u.id
    limit v_max + 1
  ) c;

  v_n := jsonb_array_length(v_all);
  if v_n > v_max then
    return jsonb_build_object('reset', true, 'ops', '[]'::jsonb,
                              'next_at', now() - v_lag, 'next_id', null, 'has_more', false);
  end if;

  v_has_more := v_n > v_limit;
  select coalesce(jsonb_agg(e.item order by e.ord), '[]'::jsonb)
  into v_ops
  from jsonb_array_elements(v_all) with ordinality as e(item, ord)
  where e.ord <= v_limit;

  if v_has_more then
    v_last := v_ops -> (v_limit - 1);
    v_next_at := (v_last ->> 'at')::timestamptz;
    v_next_id := (v_last ->> 'id')::uuid;
  else
    v_next_at := greatest(p_after_at, now() - v_lag);
    v_next_id := case when v_next_at = p_after_at then p_after_id else null end;
  end if;

  return jsonb_build_object('reset', false, 'ops', v_ops, 'next_at', v_next_at,
                            'next_id', v_next_id, 'has_more', v_has_more);
end;
$$;
revoke all on function public.changes_since(text, timestamptz, uuid, integer) from public, anon;
grant execute on function public.changes_since(text, timestamptz, uuid, integer) to authenticated;

-- 5. The posts (and shorts) of some ids, in the shape home_feed answers: the ones to upsert. ----------------
create or replace function public.posts_by_ids(p_ids uuid[])
returns table(
  id uuid, author_id uuid, username text, full_name text, avatar_url text, caption text,
  location text, like_count integer, comment_count integer, comments_enabled boolean,
  visibility text, created_at timestamptz, liked_by_me boolean, saved_by_me boolean, media jsonb,
  mood_kind text, mood_key text, mood_text text, tag_count integer, tags jsonb,
  i_am_tagged boolean, is_share boolean, shared_post_id uuid, shared_post jsonb
)
language sql
stable
security definer
set search_path = ''
as $$
  select pg.id, pg.author_id, pr.username::text, pr.full_name, pr.avatar_url,
         pg.caption, pg.location, pg.like_count, pg.comment_count, pg.comments_enabled,
         pg.visibility, pg.created_at,
         exists (select 1 from public.post_likes l where l.post_id = pg.id and l.user_id = auth.uid()),
         exists (select 1 from public.post_saves s where s.post_id = pg.id and s.user_id = auth.uid()),
         coalesce((
           select jsonb_agg(jsonb_build_object(
                    'position', m.position, 'type', m.type, 'path', m.path,
                    'thumb_path', m.thumb_path, 'width', m.width, 'height', m.height,
                    'duration_ms', m.duration_ms, 'blurhash', m.blurhash)
                  order by m.position)
           from public.post_media m where m.post_id = pg.id
         ), '[]'::jsonb),
         pg.mood_kind, pg.mood_key, pg.mood_text,
         (select count(*)::int from public.post_tags t where t.post_id = pg.id),
         coalesce((
           select jsonb_agg(jsonb_build_object(
                    'user_id', t.user_id, 'username', tp.username, 'full_name', tp.full_name,
                    'media_position', t.media_position, 'x', t.x, 'y', t.y)
                  order by t.created_at, tp.username)
           from public.post_tags t
           join public.profiles tp on tp.id = t.user_id
           where t.post_id = pg.id
         ), '[]'::jsonb),
         exists (select 1 from public.post_tags t where t.post_id = pg.id and t.user_id = auth.uid()),
         pg.is_share,
         pg.shared_post_id,
         case when pg.shared_post_id is not null then public.post_embed(pg.shared_post_id) end
  from public.posts pg
  join public.profiles pr on pr.id = pg.author_id
  where pg.id = any (p_ids[1:50])
    and public.can_view_post(pg.author_id, pg.visibility)
  order by pg.created_at desc, pg.id desc;
$$;
revoke all on function public.posts_by_ids(uuid[]) from public, anon;
grant execute on function public.posts_by_ids(uuid[]) to authenticated;

-- 6. The counts of the posts on screen: a light answer, so likes never move a post's change time. -----------
create or replace function public.post_counts(p_ids uuid[])
returns table(id uuid, like_count integer, comment_count integer, liked_by_me boolean)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.like_count, p.comment_count,
         exists (select 1 from public.post_likes l where l.post_id = p.id and l.user_id = auth.uid())
  from public.posts p
  where p.id = any (p_ids[1:100])
    and public.can_view_post(p.author_id, p.visibility);
$$;
revoke all on function public.post_counts(uuid[]) from public, anon;
grant execute on function public.post_counts(uuid[]) to authenticated;
