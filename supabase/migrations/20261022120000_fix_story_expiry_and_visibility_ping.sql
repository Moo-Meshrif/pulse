-- Pulse · Fixes after content-changes
-- 1. author_stories: an expired story is hidden for everyone, including its author.
-- 2. A post whose audience narrows (for example to Only me) is no longer readable by the people who lost it,
--    so Realtime row changes never reach them. A broadcast ping tells them to run their normal check, which
--    answers 'remove' for that post. The message carries no content.

drop function public.author_stories(uuid);
create function public.author_stories(p_author uuid)
returns table (
  id             uuid,
  type           text,
  path           text,
  thumb_path     text,
  width          integer,
  height         integer,
  duration_ms    integer,
  blurhash       text,
  overlays       jsonb,
  created_at     timestamptz,
  expires_at     timestamptz,
  seen_by_me     boolean,
  liked_by_me    boolean,
  view_count     integer,
  audience       text,
  sticker        jsonb,
  shared_post    jsonb
)
language sql
stable
set search_path = ''
as $$
  select s.id, s.type, s.path, s.thumb_path, s.width, s.height, s.duration_ms, s.blurhash,
         s.overlays, s.created_at, s.expires_at,
         exists (select 1 from public.story_views v where v.story_id = s.id and v.viewer_id = auth.uid()),
         exists (select 1 from public.story_likes l where l.story_id = s.id and l.user_id = auth.uid()),
         case when s.author_id = auth.uid()
              then (select count(*)::int from public.story_views v where v.story_id = s.id)
              else null end,
         s.audience,
         s.sticker,
         case when s.shared_post_id is not null then public.post_embed(s.shared_post_id) end
  from public.stories s
  where s.author_id = p_author
    and s.expires_at > now()
  order by s.created_at asc;
$$;
revoke all on function public.author_stories(uuid) from public, anon;
grant execute on function public.author_stories(uuid) to authenticated;

create or replace function public.posts_visibility_ping()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform realtime.send('{}'::jsonb, 'post_narrowed', 'content-changes', false);
  return null;
end;
$$;
revoke all on function public.posts_visibility_ping() from public, anon, authenticated;

drop trigger if exists posts_visibility_ping on public.posts;
create trigger posts_visibility_ping
  after update of visibility on public.posts
  for each row when (old.visibility is distinct from new.visibility)
  execute function public.posts_visibility_ping();
