-- Trigger functions are never called through the API. Supabase default privileges gave anon and
-- authenticated EXECUTE on the ones created after pulse_harden_function_grants; take it away.
revoke execute on function public.log_content_deletion() from public, anon, authenticated;
revoke execute on function public.notify_on_comment() from public, anon, authenticated;
revoke execute on function public.notify_on_follow() from public, anon, authenticated;
revoke execute on function public.notify_on_like() from public, anon, authenticated;
revoke execute on function public.notify_on_post() from public, anon, authenticated;
revoke execute on function public.notify_on_tag() from public, anon, authenticated;
revoke execute on function public.posts_touch_from_child() from public, anon, authenticated;
revoke execute on function public.profiles_before_write() from public, anon, authenticated;
revoke execute on function public.profiles_guard_required() from public, anon, authenticated;
