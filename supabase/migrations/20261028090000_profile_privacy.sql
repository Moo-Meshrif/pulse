-- =====================================================================
-- Migration: supabase/migrations/20261028090000_profile_privacy.sql
-- Plan: docs/plans/profile-plan.md (Phase 2), spec docs/specs/profile/screens/s5-privacy.md
-- Adds: profiles.who_can_message, who_can_comment, show_activity, appear_in_search
--       client update grants for these columns and is_private
--       add_comment now follows the author's who_can_comment choice
-- who_can_message is only stored: it is enforced when Chat exists (plan T9).
-- Turning is_private off changes nothing in `follows`: pending requests stay pending until the owner answers them.
-- add_comment errors (all 22023): comments_off (post switch, or the author turned comments off),
--       comments_followers_only (the author allows followers only and the caller is not an accepted follower).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Columns and grants
-- ---------------------------------------------------------------------
alter table public.profiles
  add column who_can_message text    not null default 'everyone',
  add column who_can_comment text    not null default 'everyone',
  add column show_activity   boolean not null default true,
  add column appear_in_search boolean not null default true,
  add constraint profiles_who_can_message_valid check (who_can_message in ('everyone', 'following', 'none')),
  add constraint profiles_who_can_comment_valid check (who_can_comment in ('everyone', 'followers', 'none'));

grant update (is_private, who_can_message, who_can_comment, show_activity, appear_in_search)
  on public.profiles to authenticated;

-- ---------------------------------------------------------------------
-- 2. add_comment honours who_can_comment (comments cannot be written any other way: the table has no client grants)
-- ---------------------------------------------------------------------
create or replace function public.add_comment(
  p_post      uuid,
  p_body      text,
  p_parent    uuid default null,
  p_client_id uuid default null
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_author  uuid := public.comments_post_author(p_post);
  v_body    text := btrim(coalesce(p_body, ''));
  v_parent  uuid := null;
  v_id      uuid;
  v_rule    text;
  c         public.comments;
begin
  if not (select p.comments_enabled from public.posts p where p.id = p_post) then
    raise exception 'comments_off' using errcode = '22023';
  end if;
  -- the author's own choice of who may comment on any of their posts (the author always may)
  if v_uid <> v_author then
    select pr.who_can_comment into v_rule from public.profiles pr where pr.id = v_author;
    if v_rule = 'none' then
      raise exception 'comments_off' using errcode = '22023';
    elsif v_rule = 'followers' and not public.is_accepted_follower(v_author) then
      raise exception 'comments_followers_only' using errcode = '22023';
    end if;
  end if;
  if char_length(v_body) not between 1 and 1000 then
    raise exception 'invalid body' using errcode = '22023';
  end if;

  if p_parent is not null then
    select coalesce(pc.parent_id, pc.id) into v_parent
      from public.comments pc
     where pc.id = p_parent and pc.post_id = p_post
       and (pc.hidden_at is null or pc.author_id = v_uid);
    if v_parent is null then
      raise exception 'comment_unavailable' using errcode = 'P0002';
    end if;
  end if;

  insert into public.comments (post_id, author_id, parent_id, body, client_id)
  values (p_post, v_uid, v_parent, v_body, p_client_id)
  on conflict (author_id, client_id) where client_id is not null do nothing
  returning id into v_id;

  if v_id is null then
    select id into v_id from public.comments where author_id = v_uid and client_id = p_client_id;
  end if;

  select * into c from public.comments where id = v_id;
  return public.comment_json(c, v_author);
end;
$$;

revoke all on function public.add_comment(uuid, text, uuid, uuid) from public, anon;
grant execute on function public.add_comment(uuid, text, uuid, uuid) to authenticated;
