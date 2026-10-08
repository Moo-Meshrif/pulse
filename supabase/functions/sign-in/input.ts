// Pure helpers of the sign-in function: input validation, the client IP, hashing and the secret-key check.
// No Deno or network API is used here, so these run (and are tested) anywhere.

export type Identifier =
  | { kind: "email"; value: string }
  | { kind: "username"; value: string };

export interface SignInInput {
  identifier: Identifier;
  password: string;
}

const USERNAME = /^[a-z0-9._]{3,30}$/;
const EMAIL = /^[^\s@]+@[^\s@]+$/;

/**
 * Validates the request body. Returns null for anything that is not `{ identifier, password }`.
 * The identifier is trimmed and lowercased; it is an email when it contains "@", otherwise a username.
 */
export function parseSignInInput(body: unknown): SignInInput | null {
  if (typeof body !== "object" || body === null) return null;
  const { identifier, password } = body as Record<string, unknown>;
  if (typeof identifier !== "string" || typeof password !== "string") return null;

  const raw = identifier.trim();
  if (raw.length < 3 || raw.length > 254) return null;
  if (password.length < 1 || password.length > 128) return null;

  const value = raw.toLowerCase();
  if (raw.includes("@")) {
    return EMAIL.test(value) ? { identifier: { kind: "email", value }, password } : null;
  }
  return USERNAME.test(value) ? { identifier: { kind: "username", value }, password } : null;
}

/**
 * The client IP: the first `x-forwarded-for` entry, or null when it is absent or not an address.
 *
 * How far this can be trusted: the platform's proxy chain writes this header, but a client can send its
 * own `x-forwarded-for` too, and if the platform appends instead of replacing, the client's value is the
 * FIRST entry. So the per-IP throttle is a convenience, not a guarantee: the per-identifier throttle and
 * Auth's own limits are what really bound a brute-force attempt. The deploy checks send a spoofed header to
 * see whether it changes the throttle key; if it does, switch to the entry the platform appended (the last).
 */
export function clientIp(headers: Headers): string | null {
  const first = headers.get("x-forwarded-for")?.split(",")[0]?.trim();
  return first && /^[0-9a-fA-F:.]{2,45}$/.test(first) ? first : null;
}

/** SHA-256 of a UTF-8 string, as 64 lowercase hex characters. */
export async function sha256Hex(text: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
  return Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, "0")).join("");
}

/**
 * The `default` secret key from SUPABASE_SECRET_KEYS (a JSON dictionary). Throws when it is missing or is
 * not a new-style secret key: the function must fail loudly at startup and never fall back to the legacy
 * service-role key. The message never contains the key.
 */
export function readSecretKey(raw: string | undefined): string {
  if (!raw) throw new Error("sign-in: SUPABASE_SECRET_KEYS is not set");
  let keys: unknown;
  try {
    keys = JSON.parse(raw);
  } catch {
    throw new Error("sign-in: SUPABASE_SECRET_KEYS is not valid JSON");
  }
  const value = (keys as Record<string, unknown> | null)?.["default"];
  if (typeof value !== "string" || !value.startsWith("sb_secret_")) {
    throw new Error('sign-in: SUPABASE_SECRET_KEYS has no "default" secret key (sb_secret_...)');
  }
  return value;
}
