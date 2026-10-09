-- Forgot password tells the user when no account has the email. Callable by anon (the user is signed out).
-- Trade-off: it reveals which emails are registered, like the sign-up "email already exists" answer.
create or replace function public.email_exists(p_email text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from auth.users u where lower(u.email) = lower(trim(p_email))
  );
$$;

revoke all on function public.email_exists(text) from public;
grant execute on function public.email_exists(text) to anon, authenticated;
