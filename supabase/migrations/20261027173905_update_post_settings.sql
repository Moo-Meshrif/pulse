-- =====================================================================
-- update_post also saves the comments switch and the audience, so Edit post changes
-- caption, place, media, mood, tags, comments and audience in ONE transaction
-- (before, the app set the last two with separate calls before the edit, so a failed
-- edit could leave them changed).
--   p_comments_enabled  null = leave as it is
--   p_visibility        null = leave as it is; else one of the four audiences
--                       (same check as set_content_audience)
-- Everything else is as in 20261015162526_post_tags_mood.sql.
-- =====================================================================

drop function public.update_post(uuid, text, text, jsonb, text, text, text, jsonb);

create function public.update_post(
  p_id               uuid,
  p_caption          text default null,
  p_location         text default null,
  p_media            jsonb default '[]'::jsonb,
  p_mood_kind        text default null,
  p_mood_key         text default null,
  p_mood_text        text default null,
  p_tags             jsonb default '[]'::jsonb,
  p_comments_enabled boolean default null,
  p_visibility       text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := auth.uid();
  v_prefix    text;
  v_count     int;
  v_caption   text := nullif(btrim(p_caption), '');
  v_loc       text := nullif(btrim(p_location), '');
  v_mood_text text := nullif(btrim(p_mood_text), '');
  v_item      jsonb;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not exists (select 1 from public.posts where id = p_id and author_id = v_uid and kind = 'post') then
    raise exception 'not your post' using errcode = '42501';
  end if;
  if p_visibility is not null
     and p_visibility not in ('public', 'followers', 'close_friends', 'only_me') then
    raise exception 'invalid audience' using errcode = '22023';
  end if;
  if jsonb_typeof(coalesce(p_media, '[]'::jsonb)) <> 'array' then
    raise exception 'media must be an array' using errcode = '22023';
  end if;

  v_count := jsonb_array_length(coalesce(p_media, '[]'::jsonb));
  if v_count > 10 then
    raise exception 'at most 10 media items' using errcode = 'check_violation';
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

  update public.posts
  set caption = v_caption, location = v_loc, media_count = v_count,
      mood_kind = p_mood_kind, mood_key = p_mood_key, mood_text = v_mood_text,
      comments_enabled = coalesce(p_comments_enabled, comments_enabled),
      visibility = coalesce(p_visibility, visibility)
  where id = p_id;

  delete from public.post_media where post_id = p_id;
  insert into public.post_media (post_id, position, type, path, thumb_path, width, height, duration_ms, blurhash)
  select p_id, (e.ord - 1)::smallint, e.item->>'type', e.item->>'path', e.item->>'thumb_path',
         (e.item->>'width')::int, (e.item->>'height')::int,
         (e.item->>'duration_ms')::int, e.item->>'blurhash'
  from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) with ordinality as e(item, ord);

  -- A tag whose photo was removed becomes a post-only tag (spot cleared).
  perform public.store_post_tags(p_id, v_uid, p_tags, v_count);
end;
$$;
revoke all on function public.update_post(uuid, text, text, jsonb, text, text, text, jsonb, boolean, text) from public, anon;
grant execute on function public.update_post(uuid, text, text, jsonb, text, text, text, jsonb, boolean, text) to authenticated;
