-- Applied to the Supabase project `pulse` (xwldtqsvcpyzktysgmuv) on 2026-10-08 with the Supabase MCP.
-- Kept here for the record; do not re-apply. Source of truth: docs/specs/auth/schema.sql.

-- =====================================================================
-- 6. GRANT HARDENING (applied as migration `pulse_harden_function_grants`)
-- Supabase default privileges give anon EXECUTE on new functions, so `revoke ... from public` is not enough.
-- =====================================================================
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.follow_many(uuid[]) from anon;
revoke execute on function public.is_username_available(text) from anon;
revoke execute on function public.set_user_interests(smallint[]) from anon;
revoke execute on function public.suggested_profiles(text, integer, integer) from anon;
-- get_email_for_username stays callable by anon on purpose (S1 sign in by username).
