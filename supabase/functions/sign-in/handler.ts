import { clientIp, parseSignInInput, sha256Hex } from "./input.ts";
import type { Identifier } from "./input.ts";

export interface Limit {
  max: number;
  windowSeconds: number;
}

export interface HandlerConfig {
  supabaseUrl: string;
  /** The `default` secret key. Used for the throttle and username lookups and for the password grant. */
  secretKey: string;
  limits: { perIp: Limit; perIdentifier: Limit };
  /** Every non-429 response is held back to at least this long, so "unknown user" and "wrong password" match. */
  minResponseMs: number;
  fetchImpl?: typeof fetch;
  sleep?: (ms: number) => Promise<void>;
  now?: () => number;
}

const MAX_BODY_CHARS = 4096;
const UPSTREAM_TIMEOUT_MS = 8000;
const FALLBACK_RETRY_AFTER_SECONDS = 60;

const BASE_HEADERS = { "Content-Type": "application/json", "Cache-Control": "no-store" };

/**
 * The sign-in endpoint: POST { identifier, password } -> tokens only.
 * Flow: validate -> throttle (before any lookup) -> resolve a username -> password grant -> answer.
 * Nothing that identifies a person is logged (no password, email, username or IP).
 */
export function createHandler(config: HandlerConfig): (req: Request) => Promise<Response> {
  const call = config.fetchImpl ?? fetch;
  const sleep = config.sleep ?? ((ms: number) => new Promise<void>((r) => setTimeout(r, ms)));
  const now = config.now ?? (() => Date.now());

  async function rest(path: string, body: unknown): Promise<unknown> {
    const response = await call(`${config.supabaseUrl}/rest/v1/rpc/${path}`, {
      method: "POST",
      headers: { apikey: config.secretKey, "Content-Type": "application/json" },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(UPSTREAM_TIMEOUT_MS),
    });
    if (!response.ok) throw new Error(`rpc ${path} failed: ${response.status}`);
    return await response.json();
  }

  /** Seconds to wait, or 0 when the call is allowed. The key is a hash: the database never sees a raw value. */
  async function hit(key: string, limit: Limit): Promise<number> {
    const wait = await rest("hit_rate_limit", {
      p_key: key,
      p_limit: limit.max,
      p_window_seconds: limit.windowSeconds,
    });
    if (typeof wait !== "number" || !Number.isInteger(wait) || wait < 0) {
      throw new Error("hit_rate_limit returned an unexpected value");
    }
    return wait;
  }

  async function emailFor(identifier: Identifier): Promise<string | null> {
    if (identifier.kind === "email") return identifier.value;
    const email = await rest("get_email_for_username", { p_username: identifier.value });
    return typeof email === "string" && email.length > 0 ? email : null;
  }

  return async (req: Request): Promise<Response> => {
    const started = now();

    /** Pads to the minimum duration (never a 429), then builds the response. */
    async function answer(status: number, body: unknown, headers: Record<string, string> = {}, pad = true) {
      if (pad) {
        const wait = config.minResponseMs - (now() - started);
        if (wait > 0) await sleep(wait);
      }
      return new Response(JSON.stringify(body), { status, headers: { ...BASE_HEADERS, ...headers } });
    }
    const tooMany = (seconds: number) =>
      answer(429, { code: "rate_limited", retry_after: seconds }, { "Retry-After": String(seconds) }, false);
    const invalid = () => answer(401, { code: "invalid_credentials" });

    try {
      if (req.method !== "POST") return await answer(405, { code: "method_not_allowed" }, { Allow: "POST" });

      const text = await req.text();
      if (text.length > MAX_BODY_CHARS) return await answer(400, { code: "bad_request" });
      let json: unknown;
      try {
        json = JSON.parse(text);
      } catch {
        return await answer(400, { code: "bad_request" });
      }
      const input = parseSignInInput(json);
      if (!input) return await answer(400, { code: "bad_request" });

      // Throttle before any lookup. The IP first: a blocked IP must not also use up the identifier's allowance.
      const ip = clientIp(req.headers);
      const ipWait = await hit(await sha256Hex(`ip:${ip ?? "unknown"}`), config.limits.perIp);
      if (ipWait > 0) return await tooMany(ipWait);
      const idWait = await hit(await sha256Hex(`id:${input.identifier.value}`), config.limits.perIdentifier);
      if (idWait > 0) return await tooMany(idWait);

      // A username that matches nobody never reaches Auth: it gets the same answer as a wrong password.
      const email = await emailFor(input.identifier);
      if (email === null) return await invalid();

      const upstream = await call(`${config.supabaseUrl}/auth/v1/token?grant_type=password`, {
        method: "POST",
        headers: {
          apikey: config.secretKey,
          "Content-Type": "application/json",
          // Lets Auth rate-limit by the real client IP (needs the secret key and the project setting).
          ...(ip ? { "Sb-Forwarded-For": ip } : {}),
        },
        body: JSON.stringify({ email, password: input.password }),
        signal: AbortSignal.timeout(UPSTREAM_TIMEOUT_MS),
      });
      const result = (await upstream.json().catch(() => ({}))) as Record<string, unknown>;

      if (upstream.ok) {
        const { access_token, refresh_token, expires_in, expires_at, token_type } = result;
        if (typeof access_token !== "string" || typeof refresh_token !== "string") {
          throw new Error("auth answered 200 without tokens");
        }
        // Tokens only: no user object, no email.
        return await answer(200, { access_token, refresh_token, expires_in, expires_at, token_type });
      }
      // Auth's own limit (a 429, or its error code on any status) takes the same shape as ours, so the app
      // only ever sees one rate-limit answer. Auth's Retry-After is used when it sends one.
      if (upstream.status === 429 || result["error_code"] === "over_request_rate_limit") {
        const seconds = Number(upstream.headers.get("retry-after")) || FALLBACK_RETRY_AFTER_SECONDS;
        return await tooMany(Math.ceil(seconds));
      }
      switch (result["error_code"]) {
        case "invalid_credentials":
          return await invalid();
        case "email_not_confirmed":
          // Auth reports this only after it accepted the password (checked with an unverified test user),
          // so the caller has proved they own the account and may be told the email (S1 opens S4 with it).
          return await answer(403, { code: "email_not_confirmed", email });
        default:
          throw new Error(`auth answered ${upstream.status} ${String(result["error_code"] ?? "")}`);
      }
    } catch (error) {
      // The message holds a status or an error code, never a credential or an identifier.
      console.error("sign-in: unexpected failure:", error instanceof Error ? error.message : "unknown");
      return await answer(500, { code: "server_error" });
    }
  };
}
