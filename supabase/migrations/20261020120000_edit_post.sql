-- =====================================================================
-- Edit post
-- Adds: update_post(p_id, p_caption, p_location, p_media), the owner's way
--       to change the caption, the place and the photos/videos of a post.
--       The media list is replaced as a whole (up to 10, in order).
--       Comments and audience keep their own paths
--       (posts.comments_enabled grant, set_content_audience).
--       Docs: docs/specs/post/screens/s5-edit-post.md.
-- Validate in a rolled-back transaction; apply only after the user approves.
-- =====================================================================

create function public.update_post(
  p_id       uuid,
  p_caption  text default null,
  p_location text default null,
  p_media    jsonb default '[]'::jsonb
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_prefix  text;
  v_count   int;
  v_caption text := nullif(btrim(p_caption), '');
  v_loc     text := nullif(btrim(p_location), '');
  v_item    jsonb;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not exists (select 1 from public.posts where id = p_id and author_id = v_uid and kind = 'post') then
    raise exception 'not your post' using errcode = '42501';
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

  -- posts_has_content (caption or media) rejects an empty post.
  update public.posts
  set caption = v_caption, location = v_loc, media_count = v_count
  where id = p_id;

  delete from public.post_media where post_id = p_id;
  insert into public.post_media (post_id, position, type, path, thumb_path, width, height, duration_ms, blurhash)
  select p_id, (e.ord - 1)::smallint, e.item->>'type', e.item->>'path', e.item->>'thumb_path',
         (e.item->>'width')::int, (e.item->>'height')::int,
         (e.item->>'duration_ms')::int, e.item->>'blurhash'
  from jsonb_array_elements(coalesce(p_media, '[]'::jsonb)) with ordinality as e(item, ord);
end;
$$;
revoke all on function public.update_post(uuid, text, text, jsonb) from public, anon;
grant execute on function public.update_post(uuid, text, text, jsonb) to authenticated;
