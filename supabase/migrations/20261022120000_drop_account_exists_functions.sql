-- Sign in, forgot password and sign up no longer tell the user whether an email or username has an
-- account, so the lookups that did are dropped (email_exists came from 20261009140000_email_exists.sql).
drop function if exists public.username_exists(text);
drop function if exists public.email_exists(text);
