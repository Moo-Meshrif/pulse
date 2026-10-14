-- =====================================================================
-- Pulse · Shared content actions — one RPC per action for post, short and story
-- Migration: supabase/migrations/20261019120000_shared_content_actions.sql
-- Depends on: 20261018120000_post_visibility.sql (can_view_post, helpers),
--             20261015120000_story_audience.sql (can_view_story, stories.audience),
--             20261014120000_story_extras.sql (story_mutes, reports.story_id)
-- Adds: report_content(), set_content_audience(), set_mute(p_scope), and
--       can_view_story() rebuilt on the shared helpers.
-- Drops: report_post, report_story, set_story_audience, set_story_mute and the
--        2-argument set_mute. The app calls only the new ones.
-- p_kind: 'post' | 'short' | 'story'. A short is a posts row with kind 'short'.
-- Posts and stories are still muted on their own: p_scope 'posts' writes
-- `mutes`, 'stories' writes `story_mutes`.
-- Validate in a rolled-back transaction; apply only after the user approves.
-- =====================================================================

-- 1. can_view_story: same rules, built on the shared helpers.
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
      and (p_audience = 'followers' or public.is_close_friend(p_author))
    )
  );
$$;

-- 2. report_content: only content you can see can be reported. A post or a
--    short is also hidden for the reporter; a story is skipped by the viewer.
create or replace function public.report_content(
  p_kind   text,
  p_id     uuid,
  p_reason text,
  p_note   text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := auth.uid();
  v_note text := nullif(btrim(p_note), '');
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_kind not in ('post', 'short', 'story') then
    raise exception 'invalid kind' using errcode = '22023';
  end if;

  if p_kind = 'story' then
    if not exists (select 1 from public.stories s
                   where s.id = p_id and s.expires_at > now()
                     and public.can_view_story(s.author_id, s.audience)) then
      raise exception 'story not found' using errcode = '22023';
    end if;
    insert into public.reports (reporter_id, story_id, reason, note)
    values (v_uid, p_id, p_reason, v_note)
    on conflict (reporter_id, story_id) do nothing;
  else
    if not exists (select 1 from public.posts p
                   where p.id = p_id and p.kind = p_kind
                     and public.can_view_post(p.author_id, p.visibility)) then
      raise exception 'post not found' using errcode = '22023';
    end if;
    insert into public.reports (reporter_id, post_id, reason, note)
    values (v_uid, p_id, p_reason, v_note)
    on conflict (reporter_id, post_id) do nothing;
    insert into public.post_hides (user_id, post_id) values (v_uid, p_id)
    on conflict do nothing;
  end if;
end;
$$;
revoke all on function public.report_content(text, uuid, text, text) from public, anon;
grant execute on function public.report_content(text, uuid, text, text) to authenticated;

-- 3. set_content_audience: change who can see YOUR content, at once. The app
--    role has no UPDATE on these columns, so this is the whole gate. A story
--    only takes followers / close_friends.
create or replace function public.set_content_audience(
  p_kind     text,
  p_id       uuid,
  p_audience text
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_kind not in ('post', 'short', 'story') then
    raise exception 'invalid kind' using errcode = '22023';
  end if;

  if p_kind = 'story' then
    if p_audience is null or p_audience not in ('followers', 'close_friends') then
      raise exception 'invalid audience' using errcode = '22023';
    end if;
    update public.stories set audience = p_audience
    where id = p_id and author_id = auth.uid();
  else
    if p_audience is null
       or p_audience not in ('public', 'followers', 'close_friends', 'only_me') then
      raise exception 'invalid audience' using errcode = '22023';
    end if;
    update public.posts set visibility = p_audience
    where id = p_id and author_id = auth.uid() and kind = p_kind;
  end if;

  if not found then
    raise exception 'not your content' using errcode = '42501';
  end if;
  return p_audience;
end;
$$;
revoke all on function public.set_content_audience(text, uuid, text) from public, anon;
grant execute on function public.set_content_audience(text, uuid, text) to authenticated;

-- 4. set_mute: Mute / Undo for a scope. Idempotent. Replaces the 2-argument
--    set_mute (posts) and set_story_mute (stories).
drop function public.set_mute(uuid, boolean);
create function public.set_mute(p_user uuid, p_muted boolean, p_scope text)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_scope = 'posts' then
    if p_muted then
      insert into public.mutes (user_id, muted_id) values (auth.uid(), p_user)
      on conflict do nothing;
    else
      delete from public.mutes where user_id = auth.uid() and muted_id = p_user;
    end if;
  elsif p_scope = 'stories' then
    if p_muted then
      insert into public.story_mutes (user_id, muted_id) values (auth.uid(), p_user)
      on conflict do nothing;
    else
      delete from public.story_mutes where user_id = auth.uid() and muted_id = p_user;
    end if;
  else
    raise exception 'invalid scope' using errcode = '22023';
  end if;
  return p_muted;
end;
$$;
revoke all on function public.set_mute(uuid, boolean, text) from public, anon;
grant execute on function public.set_mute(uuid, boolean, text) to authenticated;

-- 5. The per-kind functions the shared ones replace.
drop function public.report_post(uuid, text, text);
drop function public.report_story(uuid, text, text);
drop function public.set_story_audience(uuid, text);
drop function public.set_story_mute(uuid, boolean);
