-- The only public tables still on Supabase's default grants. RPCs reach them (security definer),
-- so the API needs no access; this matches what a rebuilt schema gets after Supabase stops
-- granting new public tables by default (2026-10-30).
revoke all on public.post_tags, public.tag_removals from anon, authenticated;
