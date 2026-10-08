// Run: node --test supabase/functions/sign-in/   (Node 24+ runs TypeScript directly; Deno runs it too)
import { test } from "node:test";
import assert from "node:assert/strict";
import { createHandler } from "./handler.ts";
import { clientIp, parseSignInInput, readSecretKey, sha256Hex } from "./input.ts";

const URL_BASE = "https://example.supabase.co";
const SECRET = "sb_secret_test_key";
const LIMITS = { perIp: { max: 5, windowSeconds: 60 }, perIdentifier: { max: 5, windowSeconds: 900 } };

interface Call { url: string; headers: Record<string, string>; body: any }

/** A fake Supabase: PostgREST functions and the Auth password grant. */
function fakeBackend(opts: {
  wait?: (key: string, limit: { p_limit: number; p_window_seconds: number }) => number;
  users?: Record<string, { email: string; password: string; confirmed?: boolean }>;
  authOverride?: () => { status: number; body: unknown; headers?: Record<string, string> };
  rpcFails?: boolean;
} = {}) {
  const calls: Call[] = [];
  const users = opts.users ?? {
    dip: { email: "dip@example.com", password: "Secret123", confirmed: true },
  };
  const byEmail = Object.fromEntries(Object.values(users).map((u) => [u.email, u]));
  const fetchImpl = (async (input: string, init: RequestInit) => {
    const headers = init.headers as Record<string, string>;
    const body = JSON.parse(String(init.body));
    calls.push({ url: String(input), headers, body });
    const json = (status: number, payload: unknown, h: Record<string, string> = {}) =>
      new Response(JSON.stringify(payload), { status, headers: h });
    if (String(input).endsWith("/rpc/hit_rate_limit")) {
      if (opts.rpcFails) return json(500, { message: "boom" });
      return json(200, opts.wait?.(body.p_key, body) ?? 0);
    }
    if (String(input).endsWith("/rpc/get_email_for_username")) {
      return json(200, users[body.p_username]?.email ?? null);
    }
    if (String(input).includes("/auth/v1/token")) {
      if (opts.authOverride) {
        const o = opts.authOverride();
        return json(o.status, o.body, o.headers);
      }
      const user = byEmail[body.email];
      if (!user || user.password !== body.password) {
        return json(400, { code: 400, error_code: "invalid_credentials", msg: "Invalid login credentials" });
      }
      if (user.confirmed === false) {
        return json(400, { code: 400, error_code: "email_not_confirmed", msg: "Email not confirmed" });
      }
      return json(200, {
        access_token: "access.jwt.token", refresh_token: "refresh-token", expires_in: 3600,
        expires_at: 1790000000, token_type: "bearer",
        user: { id: "u1", email: user.email },
      });
    }
    throw new Error(`unexpected call ${input}`);
  }) as unknown as typeof fetch;
  return { fetchImpl, calls };
}

function setup(opts: Parameters<typeof fakeBackend>[0] = {}, minResponseMs = 400) {
  const backend = fakeBackend(opts);
  const slept: number[] = [];
  let clock = 0;
  const handler = createHandler({
    supabaseUrl: URL_BASE, secretKey: SECRET, limits: LIMITS, minResponseMs,
    fetchImpl: backend.fetchImpl,
    sleep: async (ms) => { slept.push(ms); clock += ms; },
    now: () => clock,
  });
  const post = (body: unknown, headers: Record<string, string> = {}, method = "POST") =>
    handler(new Request(`${URL_BASE}/functions/v1/sign-in`, {
      method, headers: { "Content-Type": "application/json", ...headers },
      body: method === "POST" ? (typeof body === "string" ? body : JSON.stringify(body)) : undefined,
    }));
  return { ...backend, slept, post };
}

const dump = async (r: Response) => ({
  status: r.status, body: await r.text(), headers: Object.fromEntries(r.headers.entries()),
});
const tokenCalls = (calls: Call[]) => calls.filter((c) => c.url.includes("/auth/v1/token"));
const rpcCalls = (calls: Call[], name: string) => calls.filter((c) => c.url.endsWith(`/rpc/${name}`));

// ---------------------------------------------------------------------------------------------------
test("only POST is accepted", async () => {
  const { post, calls } = setup();
  const response = await post({}, {}, "GET");
  assert.equal(response.status, 405);
  assert.equal(calls.length, 0);
});

test("bad input is a 400 and touches nothing", async () => {
  const { post, calls } = setup();
  const bad: unknown[] = [
    "not json", {}, { identifier: "a@b.co" }, { password: "x" }, { identifier: 5, password: "x" },
    { identifier: "ab", password: "x" }, { identifier: "x".repeat(255), password: "x" },
    { identifier: "has space", password: "x" }, { identifier: "UPPER!!", password: "x" },
    { identifier: "a@", password: "x" }, { identifier: "dip", password: "" },
    { identifier: "dip", password: "p".repeat(129) }, { identifier: "dip".padEnd(5000, "x"), password: "x" },
  ];
  for (const body of bad) {
    const response = await post(body);
    assert.equal(response.status, 400, JSON.stringify(body).slice(0, 40));
    assert.deepEqual(JSON.parse(await response.text()), { code: "bad_request" });
  }
  assert.equal(calls.length, 0);
});

test("email + password returns the tokens and nothing else", async () => {
  const { post } = setup();
  const response = await post({ identifier: "  Dip@Example.com ", password: "Secret123" });
  assert.equal(response.status, 200);
  const body = JSON.parse(await response.text());
  assert.deepEqual(Object.keys(body).sort(), ["access_token", "expires_at", "expires_in", "refresh_token", "token_type"]);
  assert.equal(body.access_token, "access.jwt.token");
});

test("username + password: the email is resolved on the server, then the grant runs", async () => {
  const { post, calls } = setup();
  const response = await post({ identifier: " Dip ", password: "Secret123" });
  assert.equal(response.status, 200);
  assert.deepEqual(rpcCalls(calls, "get_email_for_username")[0].body, { p_username: "dip" });
  assert.equal(tokenCalls(calls)[0].body.email, "dip@example.com");
  assert.ok(!(await response.text()).includes("dip@example.com"));
});

test("the password grant uses the secret key and forwards the client IP", async () => {
  const { post, calls } = setup();
  await post({ identifier: "dip", password: "Secret123" }, { "x-forwarded-for": "203.0.113.7, 10.0.0.1" });
  const grant = tokenCalls(calls)[0];
  assert.equal(grant.headers["apikey"], SECRET);
  assert.equal(grant.headers["Sb-Forwarded-For"], "203.0.113.7");
  assert.equal(grant.headers["Authorization"], undefined);
});

test("without a usable IP no Sb-Forwarded-For header is sent", async () => {
  const { post, calls } = setup();
  await post({ identifier: "dip", password: "Secret123" });
  assert.equal(tokenCalls(calls)[0].headers["Sb-Forwarded-For"], undefined);
  await post({ identifier: "dip", password: "Secret123" }, { "x-forwarded-for": "not an ip" });
  assert.equal(tokenCalls(calls)[1].headers["Sb-Forwarded-For"], undefined);
});

test("unknown username, unknown email and wrong password are indistinguishable", async () => {
  const unknownUser = setup();
  const a = await dump(await unknownUser.post({ identifier: "nobody.here", password: "x" }));
  const unknownEmail = setup();
  const b = await dump(await unknownEmail.post({ identifier: "nobody@example.com", password: "x" }));
  const wrongPassword = setup();
  const c = await dump(await wrongPassword.post({ identifier: "dip", password: "wrong" }));
  const wrongPasswordByEmail = setup();
  const d = await dump(await wrongPasswordByEmail.post({ identifier: "dip@example.com", password: "wrong" }));

  assert.equal(a.status, 401);
  assert.equal(a.body, '{"code":"invalid_credentials"}');
  for (const other of [b, c, d]) assert.deepEqual(other, a); // same status, body and headers
  // A username that matches nobody never reaches Auth.
  assert.equal(tokenCalls(unknownUser.calls).length, 0);
});

test("an unverified email is a 403 with the email, only after the password was accepted", async () => {
  const users = { sam: { email: "sam@example.com", password: "Secret123", confirmed: false } };
  const right = setup({ users });
  const ok = await right.post({ identifier: "sam", password: "Secret123" });
  assert.equal(ok.status, 403);
  assert.deepEqual(JSON.parse(await ok.text()), { code: "email_not_confirmed", email: "sam@example.com" });

  // A wrong password for the same unverified account is the generic 401 and shows no email.
  const wrong = setup({ users });
  const bad = await dump(await wrong.post({ identifier: "sam", password: "nope" }));
  assert.equal(bad.status, 401);
  assert.ok(!bad.body.includes("sam@example.com"));
});

test("every response except a 429 is padded to the minimum time", async () => {
  const { post, slept } = setup();
  await post({ identifier: "dip", password: "Secret123" });
  await post({ identifier: "nobody", password: "x" });
  await post({ nope: true });
  assert.deepEqual(slept, [400, 400, 400]);
});

test("a response already slower than the minimum is not delayed further", async () => {
  const { post, slept } = setup({}, 0);
  await post({ identifier: "dip", password: "Secret123" });
  assert.deepEqual(slept, []);
});

test("throttle keys are SHA-256 hashes: no raw IP or identifier reaches the database", async () => {
  const { post, calls } = setup();
  await post({ identifier: "Dip@Example.com", password: "Secret123" }, { "x-forwarded-for": "203.0.113.7" });
  const hits = rpcCalls(calls, "hit_rate_limit").map((c) => c.body);
  assert.equal(hits.length, 2);
  assert.equal(hits[0].p_key, await sha256Hex("ip:203.0.113.7"));
  assert.equal(hits[1].p_key, await sha256Hex("id:dip@example.com"));
  for (const hit of hits) {
    assert.match(hit.p_key, /^[0-9a-f]{64}$/);
    assert.ok(!JSON.stringify(hit).includes("203.0.113.7") && !JSON.stringify(hit).includes("dip@"));
  }
  assert.deepEqual([hits[0].p_limit, hits[0].p_window_seconds], [5, 60]);
  assert.deepEqual([hits[1].p_limit, hits[1].p_window_seconds], [5, 900]);
});

test("a missing IP is throttled under one shared 'unknown' key", async () => {
  const { post, calls } = setup();
  await post({ identifier: "dip", password: "Secret123" });
  assert.equal(rpcCalls(calls, "hit_rate_limit")[0].body.p_key, await sha256Hex("ip:unknown"));
});

test("over the per-IP limit: 429 + Retry-After before any lookup, and the identifier is not charged", async () => {
  const { post, calls, slept } = setup({ wait: (_k, _l) => 42 });
  const response = await post({ identifier: "dip", password: "Secret123" });
  assert.equal(response.status, 429);
  assert.equal(response.headers.get("retry-after"), "42");
  assert.deepEqual(JSON.parse(await response.text()), { code: "rate_limited", retry_after: 42 });
  assert.equal(rpcCalls(calls, "hit_rate_limit").length, 1); // only the IP key
  assert.equal(rpcCalls(calls, "get_email_for_username").length, 0);
  assert.equal(tokenCalls(calls).length, 0);
  assert.deepEqual(slept, []); // a 429 is not padded
});

test("over the per-identifier limit: 429, no lookup, no Auth call", async () => {
  const idKey = await sha256Hex("id:dip");
  const { post, calls } = setup({ wait: (key) => (key === idKey ? 120 : 0) });
  const response = await post({ identifier: "dip", password: "Secret123" });
  assert.equal(response.status, 429);
  assert.equal(response.headers.get("retry-after"), "120");
  assert.equal(rpcCalls(calls, "get_email_for_username").length, 0);
  assert.equal(tokenCalls(calls).length, 0);
});

test("the 6th attempt for an identifier in the window gets a 429 (counter faked in the test)", async () => {
  const counts = new Map<string, number>();
  const { post } = setup({
    wait: (key, l) => {
      const n = (counts.get(key) ?? 0) + 1;
      counts.set(key, n);
      return n > l.p_limit ? 900 : 0;
    },
  });
  const statuses: number[] = [];
  for (let i = 0; i < 6; i++) {
    // A different IP each time, so only the identifier limit can trip.
    statuses.push((await post({ identifier: "dip", password: "wrong" }, { "x-forwarded-for": `198.51.100.${i + 1}` })).status);
  }
  assert.deepEqual(statuses, [401, 401, 401, 401, 401, 429]);
});

test("a failing throttle store fails closed: a 500, never an unthrottled sign-in", async () => {
  const { post, calls } = setup({ rpcFails: true });
  const response = await post({ identifier: "dip", password: "Secret123" });
  assert.equal(response.status, 500);
  assert.deepEqual(JSON.parse(await response.text()), { code: "server_error" });
  assert.equal(tokenCalls(calls).length, 0);
});

test("Auth's own 429 is passed on as a 429", async () => {
  const { post } = setup({
    authOverride: () => ({ status: 429, body: { error_code: "over_request_rate_limit" }, headers: { "retry-after": "30" } }),
  });
  const response = await post({ identifier: "dip", password: "Secret123" });
  assert.equal(response.status, 429);
  assert.equal(response.headers.get("retry-after"), "30");
});

test("Auth's 429 without a Retry-After header falls back to 60 seconds, in the same shape", async () => {
  const { post } = setup({ authOverride: () => ({ status: 429, body: { error_code: "over_request_rate_limit" } }) });
  const response = await dump(await post({ identifier: "dip@example.com", password: "Secret123" }));
  assert.equal(response.status, 429);
  assert.deepEqual(JSON.parse(response.body), { code: "rate_limited", retry_after: 60 });
  assert.equal(response.headers["retry-after"], "60");
});

test("Auth's over_request_rate_limit code is a 429 rate_limited whatever status carried it", async () => {
  const { post } = setup({
    authOverride: () => ({ status: 400, body: { error_code: "over_request_rate_limit" }, headers: { "retry-after": "12" } }),
  });
  const response = await dump(await post({ identifier: "dip@example.com", password: "Secret123" }));
  assert.equal(response.status, 429);
  assert.deepEqual(JSON.parse(response.body), { code: "rate_limited", retry_after: 12 });
  assert.equal(response.headers["retry-after"], "12");
});

test("an unexpected Auth answer is a 500 with no detail, and nothing identifying is logged", async () => {
  const logged: string[] = [];
  const original = console.error;
  console.error = (...args: unknown[]) => { logged.push(args.map(String).join(" ")); };
  try {
    const { post } = setup({ authOverride: () => ({ status: 500, body: { error_code: "unexpected_failure" } }) });
    const response = await post(
      { identifier: "dip@example.com", password: "Secret123" },
      { "x-forwarded-for": "203.0.113.7" },
    );
    assert.equal(response.status, 500);
    assert.equal(await response.text(), '{"code":"server_error"}');
  } finally {
    console.error = original;
  }
  assert.ok(logged.length > 0);
  const everything = logged.join("\n");
  for (const secret of ["Secret123", "dip@example.com", "203.0.113.7", SECRET]) {
    assert.ok(!everything.includes(secret), `the log must not contain ${secret}`);
  }
});

test("a 200 without tokens is a 500, not a success", async () => {
  const { post } = setup({ authOverride: () => ({ status: 200, body: { user: {} } }) });
  assert.equal((await post({ identifier: "dip@example.com", password: "x" })).status, 500);
});

// ---- helpers ---------------------------------------------------------------------------------------
test("parseSignInInput normalizes and classifies the identifier", () => {
  assert.deepEqual(parseSignInInput({ identifier: " Dip.Roy ", password: "p" }), {
    identifier: { kind: "username", value: "dip.roy" }, password: "p",
  });
  assert.deepEqual(parseSignInInput({ identifier: "A@B.co", password: "p" })?.identifier, { kind: "email", value: "a@b.co" });
  assert.equal(parseSignInInput({ identifier: "a@b", password: "p" })?.identifier.kind, "email");
  assert.equal(parseSignInInput({ identifier: "ab", password: "p" }), null);
  assert.equal(parseSignInInput({ identifier: "x".repeat(31), password: "p" }), null); // username too long
  assert.equal(parseSignInInput(null), null);
});

test("clientIp takes the first x-forwarded-for entry and rejects non-addresses", () => {
  const ip = (value?: string) => clientIp(new Headers(value ? { "x-forwarded-for": value } : {}));
  assert.equal(ip("203.0.113.7, 10.0.0.1"), "203.0.113.7");
  assert.equal(ip("2001:db8::1"), "2001:db8::1");
  assert.equal(ip(" 198.51.100.4 "), "198.51.100.4");
  assert.equal(ip(), null);
  assert.equal(ip("garbage value"), null);
  assert.equal(ip("a".repeat(60)), null);
});

test("sha256Hex matches a known vector", async () => {
  assert.equal(await sha256Hex("abc"), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
});

test("readSecretKey fails loudly and never falls back to the legacy key", () => {
  assert.equal(readSecretKey('{"default":"sb_secret_abc"}'), "sb_secret_abc");
  for (const bad of [undefined, "", "not json", "{}", '{"default":""}', '{"default":"eyJlegacy.jwt.key"}', '{"other":"sb_secret_x"}', "null"]) {
    assert.throws(() => readSecretKey(bad), /sign-in:/);
  }
  assert.throws(() => readSecretKey('{"default":"eyJlegacy"}'), (e: Error) => !e.message.includes("eyJlegacy"));
});
