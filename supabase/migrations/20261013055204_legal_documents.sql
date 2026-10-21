-- =====================================================================
-- LEGAL DOCUMENTS (Terms, Privacy Policy)
-- HTML written by the backend team, one row per type + language. Read before sign-up, so `anon` may
-- call the RPC; the table itself is not exposed. Missing language falls back to English.
-- =====================================================================
create table if not exists public.legal_documents (
  type        text not null,
  locale      text not null,
  title       text not null,
  html        text not null,
  updated_at  timestamptz not null default now(),

  primary key (type, locale),
  constraint legal_documents_type_values check (type in ('terms', 'privacy')),
  constraint legal_documents_locale_values check (locale in ('en', 'ar'))
);

alter table public.legal_documents enable row level security;
revoke all on public.legal_documents from anon, authenticated;

create or replace function public.legal_document(p_type text, p_locale text)
returns table (title text, html text, locale text)
language sql
stable
security definer
set search_path = public
as $$
  select d.title, d.html, d.locale
  from public.legal_documents d
  where d.type = p_type
    and d.locale in (case when p_locale = 'ar' then 'ar' else 'en' end, 'en')
  order by (d.locale = p_locale) desc
  limit 1;
$$;

revoke all on function public.legal_document(text, text) from public;
grant execute on function public.legal_document(text, text) to anon, authenticated;

-- Placeholder rows so the screens work before the real HTML is loaded; replace from the dashboard.
insert into public.legal_documents (type, locale, title, html) values
  ('terms',   'en', 'Terms',          '<p>Coming soon.</p>'),
  ('privacy', 'en', 'Privacy Policy', '<p>Coming soon.</p>')
on conflict (type, locale) do nothing;
