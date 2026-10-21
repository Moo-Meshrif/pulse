-- =====================================================================
-- Pulse · Drafts and background publishing (Phase 1 of docs/plans/content-publishing-plan.md)
-- Depends on: home_feed, post_visibility, story_audience, story_extras, post_tags_mood.
-- Adds:
--   pending_content          a post, short or story that is not posted yet (id = the future id)
--   RPCs  open_draft, discard_content, share_content, publish_content, content_status,
--         content_cleanup_list, confirm_content_cleanup
--   jobs  publish_due (every minute), expire_pending_content (hourly), purge_pending_content (daily)
--   create_post              refuses the id of a discarded, rejected or abandoned item
--   storage (post-media)     no uploads into a finished draft's folder; draft files only for the owner;
--                            others see only the files that are part of the post
-- States: draft -> waiting (shared) -> published | rejected; draft | waiting | rejected -> discarded;
--         draft | waiting | rejected -> abandoned (by the hourly job).
-- =====================================================================

-- 1. Content that is not posted yet.
create table public.pending_content (
  id             uuid primary key,
  author_id      uuid not null references public.profiles (id) on delete cascade,
  kind           text not null,
  state          text not null,
  request        jsonb,               -- what share_content saved; read with a fixed key list
  visibility     text,                -- posts: resolved when shared
  error_code     text,                -- SQLSTATE of a rejected publish
  cleanup_due_at timestamptz,         -- when the app should next delete this item's files
  cleanup_passes smallint not null default 0,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  shared_at      timestamptz,
  finished_at    timestamptz,

  constraint pending_content_kind check (kind in ('post', 'short', 'story')),
  constraint pending_content_state check (
    state in ('draft', 'waiting', 'published', 'rejected', 'discarded', 'abandoned')
  ),
  constraint pending_content_story_no_draft check (kind <> 'story' or state <> 'draft'),
  constraint pending_content_request check (
    (state <> 'draft' or request is null) and (state <> 'waiting' or request is not null)
  ),
  constraint pending_content_request_size check (
    request is null or (jsonb_typeof(request) = 'object' and octet_length(request::text) <= 65536)
  )
);

comment on table public.pending_content is
  'Posts, shorts and stories that are not posted yet. Written only through the RPCs below.';

create index pending_content_author_idx  on public.pending_content (author_id, state);
create index pending_content_waiting_idx on public.pending_content (shared_at) where state = 'waiting';
create index pending_content_cleanup_idx on public.pending_content (author_id, cleanup_due_at)
  where cleanup_due_at is not null;

-- RPC access only.
revoke all on public.pending_content from anon, authenticated;
alter table public.pending_content enable row level security;

-- 2. Helpers (internal).

-- Where an item's files live: {uid}/{id}/ for a post or short, {uid}/stories/{id}… for a story.
create or replace function public.pending_prefix(p_kind text, p_author uuid, p_id uuid)
returns text
language sql
immutable
set search_path = ''
as $$
  select case when p_kind = 'story'
              then p_author::text || '/stories/' || p_id::text
              else p_author::text || '/' || p_id::text || '/' end;
$$;

-- True when p_name is one of the item's files.
create or replace function public.pending_owns_name(p_kind text, p_author uuid, p_id uuid, p_name text)
returns boolean
language sql
immutable
set search_path = ''
as $$
  select case when p_kind = 'story'
              then p_name ~ ('^' || public.pending_prefix(p_kind, p_author, p_id) || '(_thumb)?\.[a-z0-9]+$')
              else starts_with(p_name, public.pending_prefix(p_kind, p_author, p_id))
                   and substr(p_name, char_length(public.pending_prefix(p_kind, p_author, p_id)) + 1)
                       ~ '^[A-Za-z0-9._-]+$' end;
$$;

-- The files a shared request expects: [{name, size, mime}], each path checked. Throws 22023 on a bad
-- shape. size may be null (a video still being shrunk when shared); mime is required.
-- Item keys: path, size, mime, thumb_path, thumb_size, thumb_mime (a post's request.media[], or the
-- story request itself).
create or replace function public.pending_expected_files(
  p_kind text, p_author uuid, p_id uuid, p_request jsonb
)
returns table (name text, size bigint, mime text)
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_items jsonb := case when p_kind = 'story' then jsonb_build_array(p_request)
                        else coalesce(p_request->'media', '[]'::jsonb) end;
  v_mimes constant text[] := array['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/quicktime'];
  v_item  jsonb;
  v_main  boolean;
begin
  if jsonb_typeof(v_items) <> 'array' or jsonb_array_length(v_items) > 10 then
    raise exception 'media must be an array of at most 10 items' using errcode = '22023';
  end if;
  for v_item in select value from jsonb_array_elements(v_items) loop
    if jsonb_typeof(v_item) <> 'object' then
      raise exception 'media item must be an object' using errcode = '22023';
    end if;
    foreach v_main in array array[true, false] loop
      if v_main then
        name := v_item->>'path';
        size := (v_item->>'size')::bigint;
        mime := v_item->>'mime';
      else
        continue when v_item->>'thumb_path' is null;
        name := v_item->>'thumb_path';
        size := (v_item->>'thumb_size')::bigint;
        mime := v_item->>'thumb_mime';
      end if;
      if name is null or not public.pending_owns_name(p_kind, p_author, p_id, name) then
        raise exception 'media path must be under %', public.pending_prefix(p_kind, p_author, p_id)
          using errcode = '22023';
      end if;
      if (size is not null and size not between 1 and 52428800) or not (mime = any (v_mimes)) then
        raise exception 'invalid size or type for %', name using errcode = '22023';
      end if;
      return next;
    end loop;
  end loop;
end;
$$;

-- Expected files that are not in storage yet, or not as expected (owner, size, type).
create or replace function public.pending_missing_files(
  p_kind text, p_author uuid, p_id uuid, p_request jsonb
)
returns text[]
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(array_agg(f.name order by f.name), '{}')
  from public.pending_expected_files(p_kind, p_author, p_id, p_request) f
  where not exists (
    select 1 from storage.objects o
    where o.bucket_id = 'post-media'
      and o.name = f.name
      and o.owner_id = p_author::text
      and (f.size is null or (o.metadata->>'size')::bigint = f.size)
      and o.metadata->>'mimetype' = f.mime
  );
$$;

-- The item's files in storage that the author owns and no post or story uses: what cleanup may delete.
create or replace function public.pending_leftover_files(p_kind text, p_author uuid, p_id uuid)
returns text[]
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(array_agg(o.name order by o.name), '{}')
  from storage.objects o
  where o.bucket_id = 'post-media'
    and o.name like public.pending_prefix(p_kind, p_author, p_id) || '%'
    and public.pending_owns_name(p_kind, p_author, p_id, o.name)
    and o.owner_id = p_author::text
    and not exists (select 1 from public.post_media m
                    where m.post_id = p_id and o.name in (m.path, m.thumb_path))
    and not exists (select 1 from public.stories s
                    where s.id = p_id and o.name in (s.path, s.thumb_path));
$$;

-- The post or story already exists (published here, or by create_post directly).
create or replace function public.pending_is_posted(p_kind text, p_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case when p_kind = 'story'
              then exists (select 1 from public.stories where id = p_id)
              else exists (select 1 from public.posts where id = p_id) end;
$$;

-- The audience a post gets: the request's, or the profile default; a private account never posts
-- publicly (same rule as create_post).
create or replace function public.pending_post_visibility(p_author uuid, p_visibility text)
returns text
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_profile public.profiles;
  v_result  text;
begin
  if p_visibility is not null
     and p_visibility not in ('public', 'followers', 'close_friends', 'only_me') then
    raise exception 'invalid visibility' using errcode = '22023';
  end if;
  select * into v_profile from public.profiles where id = p_author;
  v_result := coalesce(p_visibility, v_profile.default_post_visibility);
  if v_result = 'public' and v_profile.is_private then
    v_result := 'followers';
  end if;
  return v_result;
end;
$$;

-- The signed-in user, who must have finished sign-up.
create or replace function public.pending_caller()
returns uuid
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
  if not exists (select 1 from public.profiles where id = v_uid and signup_step = 0) then
    raise exception 'finish sign-up first' using errcode = '42501';
  end if;
  return v_uid;
end;
$$;

-- Locks and returns the caller's item; another author's item throws 42501.
create or replace function public.pending_lock(p_id uuid, p_uid uuid)
returns public.pending_content
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row public.pending_content;
begin
  select * into v_row from public.pending_content where id = p_id for update;
  if found and v_row.author_id <> p_uid then
    raise exception 'not your content' using errcode = '42501';
  end if;
  return v_row;
end;
$$;

-- Publishes one waiting item, once. Runs for the app (publish_content) and for the minute job, so it
-- acts as the author: request.jwt.claims is set to them for this transaction (create_post and
-- store_post_tags read auth.uid()). A failing publish marks the item rejected with its SQLSTATE.
-- Returns the state after the call, or null for an unknown id.
create or replace function public.publish_pending(p_id uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row        public.pending_content;
  v_r          jsonb;
  v_media      jsonb;
  v_old_claims text := current_setting('request.jwt.claims', true);
  v_old_sub    text := current_setting('request.jwt.claim.sub', true);
  v_code       text;
begin
  select * into v_row from public.pending_content where id = p_id for update;
  if not found then
    return null;
  end if;
  if v_row.state <> 'waiting' then
    return v_row.state;
  end if;

  if public.pending_is_posted(v_row.kind, v_row.id) then
    update public.pending_content
    set state = 'published', finished_at = now(), updated_at = now()
    where id = p_id;
    return 'published';
  end if;
  if cardinality(public.pending_missing_files(v_row.kind, v_row.author_id, v_row.id, v_row.request)) > 0 then
    return 'waiting';
  end if;
  -- Posts go out in the order they were shared.
  if v_row.kind <> 'story' and exists (
       select 1 from public.pending_content o
       where o.author_id = v_row.author_id and o.kind <> 'story' and o.state = 'waiting'
         and (o.shared_at, o.id) < (v_row.shared_at, v_row.id)) then
    return 'waiting';
  end if;

  perform set_config('request.jwt.claims',
                     json_build_object('sub', v_row.author_id, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', v_row.author_id::text, true);

  v_r := v_row.request;
  begin
    if v_row.kind = 'story' then
      -- Paths were checked against {uid}/stories/{id} when shared; the 24 hours start now.
      insert into public.stories (id, author_id, type, path, thumb_path, width, height, duration_ms,
                                  blurhash, overlays, audience)
      values (v_row.id, v_row.author_id, v_r->>'type', v_r->>'path', v_r->>'thumb_path',
              (v_r->>'width')::int, (v_r->>'height')::int, (v_r->>'duration_ms')::int,
              v_r->>'blurhash', coalesce(v_r->'overlays', '[]'::jsonb),
              coalesce(v_r->>'audience', 'followers'));
    else
      select coalesce(jsonb_agg(jsonb_build_object(
               'type', e.item->>'type', 'path', e.item->>'path', 'thumb_path', e.item->>'thumb_path',
               'width', e.item->'width', 'height', e.item->'height',
               'duration_ms', e.item->'duration_ms', 'blurhash', e.item->>'blurhash')
             order by e.ord), '[]'::jsonb)
      into v_media
      from jsonb_array_elements(coalesce(v_r->'media', '[]'::jsonb)) with ordinality as e(item, ord);

      perform public.create_post(
        p_id               => v_row.id,
        p_kind             => v_row.kind,
        p_caption          => v_r->>'caption',
        p_location         => v_r->>'location',
        p_media            => v_media,
        p_comments_enabled => coalesce((v_r->>'comments_enabled')::boolean, true),
        p_visibility       => v_row.visibility,
        p_mood_kind        => v_r->>'mood_kind',
        p_mood_key         => v_r->>'mood_key',
        p_mood_text        => v_r->>'mood_text',
        p_tags             => coalesce(v_r->'tags', '[]'::jsonb)
      );
    end if;

    update public.pending_content
    set state = 'published', finished_at = now(), updated_at = now()
    where id = p_id;
  exception when others then
    get stacked diagnostics v_code = returned_sqlstate;
    update public.pending_content
    set state = 'rejected', error_code = v_code, finished_at = now(), updated_at = now()
    where id = p_id;
  end;

  perform set_config('request.jwt.claims', coalesce(v_old_claims, ''), true);
  perform set_config('request.jwt.claim.sub', coalesce(v_old_sub, ''), true);
  return (select state from public.pending_content where id = p_id);
end;
$$;

-- 3. RPCs the app calls.

-- Opens (or touches) a draft for a post or short. Returns its state; anything but 'draft' means the
-- app must not keep editing it.
create or replace function public.open_draft(p_id uuid, p_kind text default 'post')
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := public.pending_caller();
  v_row public.pending_content;
begin
  if p_id is null or p_kind not in ('post', 'short') then
    raise exception 'invalid draft' using errcode = '22023';
  end if;
  insert into public.pending_content (id, author_id, kind, state)
  values (p_id, v_uid, p_kind, 'draft')
  on conflict (id) do nothing;

  v_row := public.pending_lock(p_id, v_uid);
  if v_row.kind <> p_kind then
    raise exception 'kind does not match' using errcode = '22023';
  end if;
  if v_row.state = 'draft' then
    update public.pending_content set updated_at = now() where id = p_id;
  end if;
  return v_row.state;
end;
$$;

-- Discards a draft, a waiting item or a rejected one. Final: it can never be posted after this.
-- An id the server never saw is recorded as discarded, so a late call cannot post it either.
-- Returns the state after the call: 'published' means it already went out and nothing changed.
create or replace function public.discard_content(p_id uuid, p_kind text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.pending_content;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_id is null or p_kind not in ('post', 'short', 'story') then
    raise exception 'invalid content' using errcode = '22023';
  end if;
  insert into public.pending_content (id, author_id, kind, state, finished_at, cleanup_due_at)
  values (p_id, v_uid, p_kind, 'discarded', now(), now())
  on conflict (id) do nothing;

  v_row := public.pending_lock(p_id, v_uid);
  if v_row.state in ('draft', 'waiting', 'rejected') then
    if public.pending_is_posted(v_row.kind, p_id) then
      update public.pending_content
      set state = 'published', finished_at = now(), updated_at = now()
      where id = p_id;
      return 'published';
    end if;
    update public.pending_content
    set state = 'discarded', finished_at = now(), updated_at = now(),
        cleanup_due_at = now(), cleanup_passes = 0
    where id = p_id;
    return 'discarded';
  end if;
  if v_row.state = 'discarded' and public.pending_is_posted(v_row.kind, p_id) then
    return 'published';   -- posted before the server knew this id
  end if;
  return v_row.state;
end;
$$;

-- Shares a post, short or story: saves what to post, so the server can post it once its files arrive.
-- A post may come from a draft or straight from the app; a story never has a draft.
-- Post request:  {caption, location, comments_enabled, visibility, mood_kind, mood_key, mood_text,
--                 tags: [...], media: [{type, path, thumb_path, width, height, duration_ms, blurhash,
--                                       size, mime, thumb_size, thumb_mime}]}
-- Story request: {type, path, thumb_path, width, height, duration_ms, blurhash, overlays, audience,
--                 size, mime, thumb_size, thumb_mime}
-- The same id and request again returns the current state; a different request throws 22023;
-- a discarded, rejected or abandoned item throws 55000; more than 3 waiting throws 53400.
create or replace function public.share_content(p_id uuid, p_kind text, p_request jsonb)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := public.pending_caller();
  v_row        public.pending_content;
  v_visibility text;
begin
  if p_id is null or p_kind not in ('post', 'short', 'story') then
    raise exception 'invalid content' using errcode = '22023';
  end if;
  if jsonb_typeof(p_request) is distinct from 'object' or octet_length(p_request::text) > 65536 then
    raise exception 'request must be an object of at most 64 KB' using errcode = '22023';
  end if;
  perform 1 from public.pending_expected_files(p_kind, v_uid, p_id, p_request);
  if p_kind = 'story' and coalesce(p_request->>'audience', 'followers') not in ('followers', 'close_friends') then
    raise exception 'invalid audience' using errcode = '22023';
  end if;
  v_visibility := case when p_kind <> 'story'
                       then public.pending_post_visibility(v_uid, p_request->>'visibility') end;

  -- One share at a time per author, so the waiting limit holds.
  perform 1 from public.profiles where id = v_uid for update;

  v_row := public.pending_lock(p_id, v_uid);
  if v_row.id is not null and v_row.kind <> p_kind then
    raise exception 'kind does not match' using errcode = '22023';
  end if;
  if v_row.state in ('waiting', 'published') then
    if v_row.request = p_request then
      return v_row.state;
    end if;
    raise exception 'already shared with a different request' using errcode = '22023';
  end if;
  if v_row.id is not null and v_row.state <> 'draft' then
    raise exception 'this content can no longer be shared (%)', v_row.state using errcode = '55000';
  end if;
  if (select count(*) from public.pending_content
      where author_id = v_uid and state = 'waiting') >= 3 then
    raise exception 'at most 3 waiting' using errcode = '53400';
  end if;

  insert into public.pending_content (id, author_id, kind, state, request, visibility, shared_at)
  values (p_id, v_uid, p_kind, 'waiting', p_request, v_visibility, clock_timestamp())
  on conflict (id) do update
    set state = 'waiting', request = excluded.request, visibility = excluded.visibility,
        shared_at = excluded.shared_at, updated_at = now();
  return 'waiting';
end;
$$;

-- Posts a shared item now if every file has arrived; safe to call any number of times.
-- Returns waiting (files missing), published, rejected, discarded or abandoned; null for an unknown id.
create or replace function public.publish_content(p_id uuid)
returns text
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
  if exists (select 1 from public.pending_content where id = p_id and author_id <> v_uid) then
    raise exception 'not your content' using errcode = '42501';
  end if;
  return public.publish_pending(p_id);
end;
$$;

-- State of the caller's items, with the files still missing for a waiting one. p_ids null = every item
-- that is not finished yet (draft, waiting, rejected, or with files left to clean).
create or replace function public.content_status(p_ids uuid[] default null)
returns table (id uuid, kind text, state text, error_code text, missing text[])
language sql
stable
security definer
set search_path = ''
as $$
  select c.id, c.kind, c.state, c.error_code,
         case when c.state = 'waiting'
              then public.pending_missing_files(c.kind, c.author_id, c.id, c.request)
              else '{}'::text[] end
  from public.pending_content c
  where c.author_id = auth.uid()
    and (case when p_ids is null
              then c.state in ('draft', 'waiting', 'rejected') or c.cleanup_due_at is not null
              else c.id = any (p_ids[1:100]) end)
  order by c.created_at;
$$;

-- Files the app should delete now: the caller's discarded and abandoned items. Never lists a file of
-- a post or story, or anyone else's file.
create or replace function public.content_cleanup_list(p_limit int default 20)
returns table (id uuid, paths text[])
language sql
stable
security definer
set search_path = ''
as $$
  select c.id, public.pending_leftover_files(c.kind, c.author_id, c.id)
  from public.pending_content c
  where c.author_id = auth.uid()
    and c.cleanup_due_at <= now()
    and c.state in ('discarded', 'abandoned')
  order by c.cleanup_due_at
  limit least(greatest(coalesce(p_limit, 20), 1), 50);
$$;

-- The app deleted an item's files: returns how many are still there. When none are, the item is
-- checked once more a day later (an upload that was running can still finish), then it is done.
create or replace function public.confirm_content_cleanup(p_id uuid)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := auth.uid();
  v_row  public.pending_content;
  v_left int;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  v_row := public.pending_lock(p_id, v_uid);
  if v_row.id is null or v_row.cleanup_due_at is null then
    return 0;
  end if;
  v_left := cardinality(public.pending_leftover_files(v_row.kind, v_row.author_id, v_row.id));
  if v_left = 0 then
    update public.pending_content
    set cleanup_passes = cleanup_passes + 1,
        cleanup_due_at = case when cleanup_passes + 1 >= 2 then null else now() + interval '1 day' end,
        updated_at = now()
    where id = p_id;
  end if;
  return v_left;
end;
$$;

-- 4. Jobs (pg_cron, as postgres).

-- Every minute: posts every waiting item whose files have all arrived, oldest share first.
-- One failing item never stops the others.
create or replace function public.publish_due(p_limit int default 200)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id   uuid;
  v_done int := 0;
begin
  for v_id in
    select c.id from public.pending_content c
    where c.state = 'waiting'
    order by c.shared_at, c.id
    limit p_limit
  loop
    begin
      if public.publish_pending(v_id) = 'published' then
        v_done := v_done + 1;
      end if;
    exception when others then
      raise warning 'publish_due: % failed with %', v_id, sqlstate;
    end;
  end loop;
  return v_done;
end;
$$;

-- Hourly: a draft or rejected item untouched for 30 days, and a shared item whose files never arrived
-- in 3 days, are given up; their files are then cleaned the next time the author opens the app.
create or replace function public.expire_pending_content()
returns integer
language sql
security definer
set search_path = ''
as $$
  with expired as (
    update public.pending_content
    set state = 'abandoned', finished_at = now(), updated_at = now(),
        cleanup_due_at = now(), cleanup_passes = 0
    where (state in ('draft', 'rejected') and updated_at < now() - interval '30 days')
       or (state = 'waiting' and shared_at < now() - interval '3 days')
    returning 1
  )
  select count(*)::int from expired;
$$;

-- Daily: removes finished records 30 days after they finished (cleaned ones only).
create or replace function public.purge_pending_content()
returns integer
language sql
security definer
set search_path = ''
as $$
  with purged as (
    delete from public.pending_content
    where state in ('published', 'discarded', 'abandoned')
      and cleanup_due_at is null
      and finished_at < now() - interval '30 days'
    returning 1
  )
  select count(*)::int from purged;
$$;

-- 5. create_post refuses an id the new flow has given up on (old app versions, direct calls).
--    Body otherwise as in 20261015162526_post_tags_mood.sql.
create or replace function public.create_post(
  p_id               uuid,
  p_kind             text default 'post',
  p_caption          text default null,
  p_location         text default null,
  p_media            jsonb default '[]'::jsonb,
  p_comments_enabled boolean default true,
  p_visibility       text default null,
  p_mood_kind        text default null,
  p_mood_key         text default null,
  p_mood_text        text default null,
  p_tags             jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := auth.uid();
  v_prefix     text;
  v_count      int;
  v_caption    text := nullif(btrim(p_caption), '');
  v_loc        text := nullif(btrim(p_location), '');
  v_mood_text  text := nullif(btrim(p_mood_text), '');
  v_item       jsonb;
  v_visibility text;
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
  if exists (select 1 from public.pending_content c
             where c.id = p_id
               and (c.author_id <> v_uid or c.state in ('discarded', 'rejected', 'abandoned'))) then
    raise exception 'this post can no longer be shared' using errcode = '55000';
  end if;
  if p_visibility is not null
     and p_visibility not in ('public', 'followers', 'close_friends', 'only_me') then
    raise exception 'invalid visibility' using errcode = '22023';
  end if;
  if jsonb_typeof(coalesce(p_media, '[]'::jsonb)) <> 'array' then
    raise exception 'media must be an array' using errcode = '22023';
  end if;

  select coalesce(p_visibility, pr.default_post_visibility) into v_visibility
  from public.profiles pr where pr.id = v_uid;
  if v_visibility = 'public'
     and exists (select 1 from public.profiles where id = v_uid and is_private) then
    v_visibility := 'followers';
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

  insert into public.posts (id, author_id, kind, caption, location, media_count, comments_enabled,
                            visibility, mood_kind, mood_key, mood_text)
  values (p_id, v_uid, p_kind, v_caption, v_loc, v_count, coalesce(p_comments_enabled, true),
          v_visibility, p_mood_kind, p_mood_key, v_mood_text);

  insert into public.post_media (post_id, position, type, path, thumb_path, width, height, duration_ms, blurhash)
  select p_id, (e.ord - 1)::smallint, e.item->>'type', e.item->>'path', e.item->>'thumb_path',
         (e.item->>'width')::int, (e.item->>'height')::int,
         (e.item->>'duration_ms')::int, e.item->>'blurhash'
  from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) with ordinality as e(item, ord);

  perform public.store_post_tags(p_id, v_uid, p_tags, v_count);
  return p_id;
end;
$$;

-- 6. Storage (post-media).

-- Uploads: into your own folder, but not into the folder of a draft that was discarded, rejected or
-- abandoned. Folders with no record (today's app versions) and the stories folder keep today's rule.
create or replace function public.can_upload_media(p_name text)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_parts text[] := string_to_array(p_name, '/');
  v_uuid  constant text := '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
begin
  if auth.uid() is null or v_parts[1] is distinct from auth.uid()::text then
    return false;
  end if;
  if coalesce(v_parts[2], '') !~ v_uuid then
    return true;
  end if;
  return not exists (
    select 1 from public.pending_content c
    where c.id = v_parts[2]::uuid
      and (c.author_id <> auth.uid() or c.state in ('discarded', 'rejected', 'abandoned'))
  );
end;
$$;
revoke all on function public.can_upload_media(text) from public, anon;
grant execute on function public.can_upload_media(text) to authenticated;

drop policy "post-media: owner insert" on storage.objects;
create policy "post-media: owner insert" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text
    and public.can_upload_media(name)
  );
drop policy "post-media: owner update" on storage.objects;
create policy "post-media: owner update" on storage.objects
  for update to authenticated
  using (bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'post-media' and (storage.foldername(name))[1] = auth.uid()::text
              and public.can_upload_media(name));

-- Reads: a post folder {uid}/{id}/ shows others only the files that are part of the post, by the
-- post's visibility; a folder with no post (a draft) only to its owner. A story file of an item that is
-- not posted yet only to its owner. Other files keep the author check. Never throws on bad input.
-- Same signature as in 20261014135126_post_visibility.sql; the read policy is unchanged.
create or replace function public.can_view_media_object(p_name text)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_parts text[] := string_to_array(p_name, '/');
  v_uuid  constant text := '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
  v_own   boolean;
  v_post  record;
begin
  if coalesce(array_length(v_parts, 1), 0) < 2 or v_parts[1] !~ v_uuid then
    return false;
  end if;
  v_own := v_parts[1] = auth.uid()::text;
  if v_own then
    return true;
  end if;

  if v_parts[2] ~ v_uuid then
    select p.id, p.author_id, p.visibility into v_post
    from public.posts p
    where p.id = v_parts[2]::uuid and p.author_id = v_parts[1]::uuid;
    if not found then
      return false;
    end if;
    return public.can_view_post(v_post.author_id, v_post.visibility)
       and exists (select 1 from public.post_media m
                   where m.post_id = v_post.id and p_name in (m.path, m.thumb_path));
  end if;

  if v_parts[2] = 'stories' and left(coalesce(v_parts[3], ''), 36) ~ v_uuid
     and exists (select 1 from public.pending_content c
                 where c.id = left(v_parts[3], 36)::uuid and c.state <> 'published') then
    return false;
  end if;
  return public.can_view_author(v_parts[1]::uuid);
end;
$$;

-- 7. Grants.
revoke all on function public.pending_prefix(text, uuid, uuid)                    from public, anon, authenticated;
revoke all on function public.pending_owns_name(text, uuid, uuid, text)           from public, anon, authenticated;
revoke all on function public.pending_expected_files(text, uuid, uuid, jsonb)     from public, anon, authenticated;
revoke all on function public.pending_missing_files(text, uuid, uuid, jsonb)      from public, anon, authenticated;
revoke all on function public.pending_leftover_files(text, uuid, uuid)            from public, anon, authenticated;
revoke all on function public.pending_is_posted(text, uuid)                       from public, anon, authenticated;
revoke all on function public.pending_post_visibility(uuid, text)                 from public, anon, authenticated;
revoke all on function public.pending_caller()                                    from public, anon, authenticated;
revoke all on function public.pending_lock(uuid, uuid)                            from public, anon, authenticated;
revoke all on function public.publish_pending(uuid)                               from public, anon, authenticated;
revoke all on function public.publish_due(int)                                    from public, anon, authenticated;
revoke all on function public.expire_pending_content()                            from public, anon, authenticated;
revoke all on function public.purge_pending_content()                             from public, anon, authenticated;

revoke all on function public.open_draft(uuid, text)                from public, anon;
revoke all on function public.discard_content(uuid, text)           from public, anon;
revoke all on function public.share_content(uuid, text, jsonb)      from public, anon;
revoke all on function public.publish_content(uuid)                 from public, anon;
revoke all on function public.content_status(uuid[])                from public, anon;
revoke all on function public.content_cleanup_list(int)             from public, anon;
revoke all on function public.confirm_content_cleanup(uuid)         from public, anon;
grant execute on function public.open_draft(uuid, text)             to authenticated;
grant execute on function public.discard_content(uuid, text)        to authenticated;
grant execute on function public.share_content(uuid, text, jsonb)   to authenticated;
grant execute on function public.publish_content(uuid)              to authenticated;
grant execute on function public.content_status(uuid[])             to authenticated;
grant execute on function public.content_cleanup_list(int)          to authenticated;
grant execute on function public.confirm_content_cleanup(uuid)      to authenticated;

-- 8. Schedules.
create extension if not exists pg_cron with schema pg_catalog;
select cron.schedule('publish-pending-content', '* * * * *', 'select public.publish_due()');
select cron.schedule('expire-pending-content', '17 * * * *', 'select public.expire_pending_content()');
select cron.schedule('purge-pending-content', '43 3 * * *', 'select public.purge_pending_content()');
