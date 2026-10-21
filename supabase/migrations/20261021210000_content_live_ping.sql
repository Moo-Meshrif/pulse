-- Pulse · Live ping (content-changes-plan Phase 6).
-- Lets the app hear that a post or story row changed (Realtime respects the select policies, so a person
-- only hears about rows they may see). The app reads nothing from the message: it only runs its normal
-- change check. A missed message loses nothing, the saved point catches up.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    if not exists (select 1 from pg_publication_tables
                   where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'posts') then
      alter publication supabase_realtime add table public.posts;
    end if;
    if not exists (select 1 from pg_publication_tables
                   where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'stories') then
      alter publication supabase_realtime add table public.stories;
    end if;
  end if;
end $$;
