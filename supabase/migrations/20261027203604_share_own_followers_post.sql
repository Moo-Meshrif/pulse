-- Share to feed also takes your own Followers post. The share keeps the original's audience (the audience
-- the caller sends is ignored); any other original must still be Public. Nothing else changes.
create or replace function public.share_to_feed(
  p_post       uuid,
  p_caption    text default null,
  p_visibility text default null,
  p_mood_kind  text default null,
  p_mood_key   text default null,
  p_mood_text  text default null,
  p_location   text default null,
  p_tags       jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := auth.uid();
  v_given      public.posts;
  v_orig       uuid;
  v_orig_vis   text;
  v_caption    text := nullif(btrim(p_caption), '');
  v_visibility text;
  v_id         uuid := gen_random_uuid();
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not exists (select 1 from public.profiles where id = v_uid and signup_step = 0) then
    raise exception 'finish sign-up first' using errcode = '42501';
  end if;
  if p_visibility is not null
     and p_visibility not in ('public', 'followers', 'close_friends', 'only_me') then
    raise exception 'invalid visibility' using errcode = '22023';
  end if;
  if v_caption is not null and char_length(v_caption) > 2000 then
    raise exception 'caption is at most 2000 characters' using errcode = 'check_violation';
  end if;
  if jsonb_typeof(coalesce(p_tags, '[]'::jsonb)) <> 'array' then
    raise exception 'tags must be an array' using errcode = '22023';
  end if;
  if exists (select 1 from jsonb_array_elements(coalesce(p_tags, '[]'::jsonb)) e
             where e.value->>'media_position' is not null) then
    raise exception 'a share has no photo to tag' using errcode = 'check_violation';
  end if;

  select * into v_given from public.posts where id = p_post;
  if not found then
    raise exception 'post_unavailable' using errcode = 'P0002';
  end if;
  v_orig := case when v_given.is_share then v_given.shared_post_id else v_given.id end;
  select o.visibility into v_orig_vis
  from public.posts o
  where o.id = v_orig and not o.is_share
    and public.can_view_post(o.author_id, o.visibility)
    and (o.visibility = 'public' or (o.visibility = 'followers' and o.author_id = v_uid));
  if v_orig is null or v_orig_vis is null then
    raise exception 'post_unavailable' using errcode = 'P0002';
  end if;

  v_visibility := case
    when v_orig_vis = 'public' then public.pending_post_visibility(v_uid, p_visibility)
    else v_orig_vis
  end;

  insert into public.posts (id, author_id, kind, caption, location, media_count, comments_enabled,
                            visibility, mood_kind, mood_key, mood_text, shared_post_id, is_share)
  values (v_id, v_uid, 'post', v_caption, nullif(btrim(p_location), ''), 0, true,
          v_visibility, p_mood_kind, p_mood_key, nullif(btrim(p_mood_text), ''), v_orig, true);

  perform public.store_post_tags(v_id, v_uid, p_tags, 0);
  return v_id;
end;
$$;
revoke all on function public.share_to_feed(uuid, text, text, text, text, text, text, jsonb) from public, anon;
grant execute on function public.share_to_feed(uuid, text, text, text, text, text, text, jsonb) to authenticated;
