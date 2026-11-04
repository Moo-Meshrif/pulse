create or replace function public.legal_updated_dates(p_locale text)
returns table (type text, updated_at timestamptz)
language sql stable security definer set search_path = ''
as $$
  select distinct on (d.type) d.type, d.updated_at
  from public.legal_documents d
  where d.locale in (case when p_locale = 'ar' then 'ar' else 'en' end, 'en')
  order by d.type, (d.locale = p_locale) desc;
$$;
revoke all on function public.legal_updated_dates(text) from public;
grant execute on function public.legal_updated_dates(text) to authenticated;
