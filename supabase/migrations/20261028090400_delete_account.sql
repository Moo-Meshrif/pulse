-- =====================================================================
-- Migration: supabase/migrations/20261028090400_delete_account.sql
-- Plan: docs/plans/profile-plan.md (Phase 2), spec docs/specs/profile/screens/s2-settings.md (Delete account)
-- Adds: delete_my_account()
-- The app asks for the password first (it signs in again before calling this); the server only knows the session.
-- Deleting the auth user removes the profile and, by cascade, everything the person owns. Their files in Storage
-- (avatar, cover, post and story media, problem report screenshots) are removed here: every bucket keeps a
-- person's files under a folder named with their id.
-- =====================================================================
create or replace function public.delete_my_account()
returns void
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
  -- Storage refuses plain deletes of its rows unless the transaction says it is on purpose.
  perform set_config('storage.allow_delete_query', 'true', true);
  delete from storage.objects
   where bucket_id in ('avatars', 'covers', 'post-media', 'problem-reports')
     and (storage.foldername(name))[1] = v_uid::text;
  delete from auth.users where id = v_uid;
end;
$$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
