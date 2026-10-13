-- The "Terms & policies" list has five documents: terms, privacy, community guidelines, cookie policy,
-- open-source licenses. Placeholder rows are written by the backend team afterwards.
alter table public.legal_documents
  drop constraint if exists legal_documents_type_values;
alter table public.legal_documents
  add constraint legal_documents_type_values
  check (type in ('terms', 'privacy', 'community', 'cookies', 'licenses'));
