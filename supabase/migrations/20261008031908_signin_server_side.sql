-- Server-side sign-in (plan Phase 3c): the email must never reach a client unless the password was right.
-- STATUS: APPLIED 2026-10-08 to the Supabase project `pulse` (xwldtqsvcpyzktysgmuv) with the Supabase MCP as
-- migration `signin_server_side` (version 20261008031908). Kept here for the record; do not re-apply.
-- Source of truth: docs/specs/auth/schema.sql.
--
-- 1. get_email_for_username becomes service_role only (it was callable by anon: a username -> email leak).
--    The function itself (security definer, search_path = '', lower/trim) is not redefined.
-- 2. A rate-limit store the `sign-in` Edge Function uses before any lookup. The function hashes the IP and
--    the identifier (SHA-256 hex, in the function) and passes only the hex: the database never sees a raw
--    value, and hit_rate_limit refuses a key that is not a 64-character lowercase hex string.

-- ---------------------------------------------------------------------------------------------------
-- 1. get_email_for_username: service_role only
-- ---------------------------------------------------------------------------------------------------
revoke all on function public.get_email_for_username(text) from public, anon, authenticated;
grant execute on function public.get_email_for_username(text) to service_role;

-- ---------------------------------------------------------------------------------------------------
-- 2. Rate-limit store
-- ---------------------------------------------------------------------------------------------------
-- `private` is not an API schema: it is not exposed, and anon / authenticated get no access to it.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists private.auth_rate_limits (
  key           text primary key,
  window_start  timestamptz not null,
  hits          int not null,
  constraint auth_rate_limits_key_is_a_hash check (key ~ '^[0-9a-f]{64}$'),
  constraint auth_rate_limits_hits_positive check (hits > 0)
);

comment on table private.auth_rate_limits is
  'Throttle counters of the sign-in function. key = SHA-256 hex of "ip:<ip>" or "id:<identifier>", computed in the function: no raw IP, email or username is stored.';

-- RLS on with no policies: nothing but a security definer function (and the table owner) can touch it.
alter table private.auth_rate_limits enable row level security;
revoke all on private.auth_rate_limits from public, anon, authenticated;

-- Seconds to wait, or 0 when the call is allowed. A fixed window per key: the first hit opens it, later hits
-- count, and the window resets once it has expired. The upsert is atomic, so concurrent calls cannot undercount.
create or replace function public.hit_rate_limit(
  p_key            text,
  p_limit          int,
  p_window_seconds int
)
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_now    timestamptz := clock_timestamp();
  v_start  timestamptz;
  v_hits   int;
begin
  if p_key is null or p_key !~ '^[0-9a-f]{64}$' then
    raise exception 'p_key must be a SHA-256 hex string' using errcode = '22023';
  end if;
  if p_limit is null or p_limit < 1 or p_window_seconds is null or p_window_seconds < 1 then
    raise exception 'p_limit and p_window_seconds must be positive' using errcode = '22023';
  end if;

  insert into private.auth_rate_limits as r (key, window_start, hits)
  values (p_key, v_now, 1)
  on conflict (key) do update
    set window_start = case
          when r.window_start + make_interval(secs => p_window_seconds) <= v_now then v_now
          else r.window_start
        end,
        hits = case
          when r.window_start + make_interval(secs => p_window_seconds) <= v_now then 1
          else r.hits + 1
        end
  returning r.window_start, r.hits into v_start, v_hits;

  -- Housekeeping, about once in a hundred calls: forget windows that ended more than a day ago
  -- (the longest window used is 15 minutes).
  if random() < 0.01 then
    delete from private.auth_rate_limits where window_start < v_now - interval '1 day';
  end if;

  if v_hits > p_limit then
    return greatest(
      1,
      ceil(extract(epoch from (v_start + make_interval(secs => p_window_seconds) - v_now)))::int
    );
  end if;
  return 0;
end;
$$;

revoke all on function public.hit_rate_limit(text, int, int) from public, anon, authenticated;
grant execute on function public.hit_rate_limit(text, int, int) to service_role;
