// Edge Function `sign-in`: username-or-email + password -> tokens (docs/plans/auth-plan.md, Phase 3c).
// Deployed with verify_jwt = false: it is called before anyone is signed in.
//
// Why it exists: resolving a username to an email in the client leaked every account's email. Here the
// lookup, the throttle and the password check all happen on the server, and the email is returned only
// after a correct password (the unverified-email answer).

import { createHandler } from "./handler.ts";
import { readSecretKey } from "./input.ts";

// ---- Limits: change them here ---------------------------------------------------------------------
const LIMITS = {
  /** Per client IP: 5 attempts per minute (25 per 5 minutes, under Auth's own per-IP limit of about 30). */
  perIp: { max: 5, windowSeconds: 60 },
  /** Per identifier (email or username): 5 attempts per 15 minutes. */
  perIdentifier: { max: 5, windowSeconds: 15 * 60 },
};
/** Every non-429 answer takes at least this long, so a missing user and a wrong password look the same. */
const MIN_RESPONSE_MS = 400;
// ----------------------------------------------------------------------------------------------------

const supabaseUrl = Deno.env.get("SUPABASE_URL");
if (!supabaseUrl) throw new Error("sign-in: SUPABASE_URL is not set");

// Fails at startup when the secret key is missing: no fallback to the legacy service-role key.
const secretKey = readSecretKey(Deno.env.get("SUPABASE_SECRET_KEYS"));

Deno.serve(createHandler({ supabaseUrl, secretKey, limits: LIMITS, minResponseMs: MIN_RESPONSE_MS }));
