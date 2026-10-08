# PR note: Phase 3c, server-side sign-in

Closes the leak where the anon-callable RPC `get_email_for_username` turned a username into an account email.

## Sign-in flow
1. S1 sends "Email or username" + password to `AuthDatasource.signIn` (same signature as before).
2. The adapter calls the Edge Function `sign-in` (`verify_jwt = false`, POST JSON `{identifier, password}`).
3. The function validates the input, throttles by IP and by identifier (SHA-256 keys, hashed in the function; the database never sees raw values), resolves a username with the service-role-only RPC, and makes the password grant with the project's secret key plus `Sb-Forwarded-For`.
4. Answers: `200` tokens only; `401 invalid_credentials` for an unknown username, unknown email or wrong password (same body and headers, responses padded to 400 ms); `403 email_not_confirmed` + the email, only after a correct password; `429 rate_limited` + `retry_after` and `Retry-After`; `500 server_error` (fails closed if the throttle store is down).
5. The adapter stores the session with `auth.setSession(refresh_token)`. Failures map to `AuthFailure(reason, email?, retryAfter?)`; `email` is set only for `emailNotConfirmed`, `retryAfter` only for the new `tooManyAttempts`.

## Limits (constants at the top of `supabase/functions/sign-in/index.ts`)
- `LIMITS.perIp`: 5 attempts / 60 s (25 per 5 minutes, under Auth's per-IP sign-in limit of about 30 per 5 minutes). `LIMITS.perIdentifier`: 5 attempts / 900 s. `MIN_RESPONSE_MS`: 400.
- To change: edit the constants and redeploy the function (Supabase MCP or dashboard). Nothing else depends on them.

## Database
Migration `supabase/migrations/20261008031908_signin_server_side.sql` (applied): the RPC is `service_role` only; `private.auth_rate_limits` + `public.hit_rate_limit` (service role only). `docs/specs/auth/schema.sql` section 7 mirrors it.

## Verification
- `fvm flutter analyze` clean; `fvm flutter test` green (394).
- Function: `node --test supabase/functions/sign-in/handler_test.ts` (25 tests, faked Supabase).
- Live: `bash supabase/functions/sign-in/check.sh anonymous` and `... accounts` (the second reads the git-ignored `supabase/functions/sign-in/.env.test`; it prints statuses and yes/no only). Results are in `docs/plans/auth-plan.md`, Phase 3c.

## B12 (Auth's per-IP limit and the forwarded IP)
- The Supabase docs list `/auth/v1/token` only as "token refresh": 1800 / hour per IP (burst 30); they give no separate sign-in default. The dashboard's "sign-ups and sign-ins" limit is about 30 per 5 minutes per IP (your number; the project's actual value could not be read). An earlier draft compared against the 1800 / hour figure: wrong for sign-in, corrected.
- Because the old per-IP limit (50 per 5 minutes) was not tighter, it is now 5 / minute (25 per 5 minutes). Per identifier stays 5 / 15 minutes.
- The password grant goes out with `apikey` (secret key) and `Sb-Forwarded-For` (client IP), no `Authorization` (code, unit test, and the header names printed from the real handler). The function's throttle key was confirmed to be the hash of the real client IP.
- Whether Auth rate-limits on the forwarded IP is **not shown**: Auth's log records only the connecting peer (the function's egress IP for sign-ins). Fallback in place: the function's own limits. Auth's own 429 is mapped to the function's `429 rate_limited` + `Retry-After` shape.
- Dashboard (Authentication > Rate Limits): confirm "IP Address Forwarding" is on; read the sign-ups and sign-ins limit and raise it if needed.

## Before release
Delete the two test users (SQL in the plan, "Test accounts") and the local `.env.test`.
