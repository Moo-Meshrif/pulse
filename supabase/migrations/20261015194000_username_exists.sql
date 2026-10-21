-- Matches the live migration of the same version. 20261015195226_drop_account_exists_functions drops it again.
create or replace function public.username_exists(p_username text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.username = lower(trim(p_username))::extensions.citext
  );
$$;

revoke all on function public.username_exists(text) from public;
grant execute on function public.username_exists(text) to anon, authenticated;
