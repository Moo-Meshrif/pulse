// Run: node --test supabase/functions/places/   (Node 24+ runs TypeScript directly; Deno runs it too)
import { test } from "node:test";
import assert from "node:assert/strict";
import { createHandler } from "./handler.ts";
import { parsePlacesInput, userIdFromAuthorization } from "./input.ts";
import { createPhotonProvider, ProviderError, toArea, toPlace } from "./photon.ts";
import type { Place, PlacesProvider } from "./provider.ts";

const b64 = (value: unknown) => Buffer.from(JSON.stringify(value)).toString("base64url");
const token = (sub: string) => `Bearer ${b64({ alg: "none" })}.${b64({ sub })}.sig`;

function request(body: unknown, user = "u1", method = "POST"): Request {
  return new Request("https://example.test/places", {
    method,
    headers: { Authorization: token(user), "Content-Type": "application/json" },
    body: method === "POST" ? JSON.stringify(body) : undefined,
  });
}

const CAIRO: Place = { name: "Zamalek", subtitle: "Cairo, Egypt", kind: "neighborhood" };

function fakeProvider(overrides: Partial<PlacesProvider> = {}) {
  const calls: string[] = [];
  const provider: PlacesProvider = {
    async search(query) {
      calls.push(`search:${query}`);
      return [CAIRO];
    },
    async nearby() {
      calls.push("nearby");
      return [CAIRO];
    },
    async reverse() {
      calls.push("reverse");
      return CAIRO;
    },
    ...overrides,
  };
  return { provider, calls };
}

function handlerWith(provider: PlacesProvider, now = () => 1_000_000, max = 30) {
  return createHandler({
    provider,
    rateLimit: { max, windowSeconds: 60 },
    cache: { ttlSeconds: 300, maxEntries: 2 },
    now,
  });
}

test("input: a search needs 2 to 80 characters and a whole position when one is given", () => {
  assert.equal(parsePlacesInput({ action: "search", q: "a" }), null);
  assert.equal(parsePlacesInput({ action: "search", q: "x".repeat(81) }), null);
  assert.equal(parsePlacesInput({ action: "search", q: "ca", lat: 30 }), null);
  assert.deepEqual(parsePlacesInput({ action: "search", q: " cairo " }), {
    action: "search",
    query: "cairo",
    near: undefined,
    language: "en",
  });
  assert.equal(parsePlacesInput({ action: "nearby", lat: 91, lng: 0 }), null);
  assert.equal(parsePlacesInput({ action: "nearby", lat: "1", lng: 0 }), null);
  assert.equal(parsePlacesInput({ action: "teleport" }), null);
  assert.equal(parsePlacesInput({ action: "reverse", lat: 1, lng: 2, lang: "ar" })?.language, "ar");
});

test("input: the user id comes from the token, and a missing token is nobody", () => {
  assert.equal(userIdFromAuthorization(token("u1")), "u1");
  assert.equal(userIdFromAuthorization(null), null);
  assert.equal(userIdFromAuthorization("Bearer nonsense"), null);
});

test("each action calls the provider once and answers with its places", async () => {
  const { provider, calls } = fakeProvider();
  const handle = handlerWith(provider);
  for (const body of [
    { action: "search", q: "zam" },
    { action: "nearby", lat: 30.06, lng: 31.22 },
    { action: "reverse", lat: 30.06, lng: 31.22 },
  ]) {
    const response = await handle(request(body));
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { places: [CAIRO] });
  }
  assert.deepEqual(calls, ["search:zam", "nearby", "reverse"]);
});

test("bad input, no token and a wrong method are refused before the provider", async () => {
  const { provider, calls } = fakeProvider();
  const handle = handlerWith(provider);
  assert.equal((await handle(request({ action: "search", q: "a" }))).status, 400);
  assert.equal((await handle(request("not an object"))).status, 400);
  assert.equal((await handle(new Request("https://example.test/places", { method: "POST", body: "{}" }))).status, 401);
  assert.equal((await handle(request(null, "u1", "GET"))).status, 405);
  assert.deepEqual(calls, []);
});

test("the same question is answered from the cache, positions rounded to about 110 m", async () => {
  const { provider, calls } = fakeProvider();
  const handle = handlerWith(provider);
  await handle(request({ action: "nearby", lat: 30.0601, lng: 31.2201 }));
  await handle(request({ action: "nearby", lat: 30.0604, lng: 31.2204 }));
  assert.deepEqual(calls, ["nearby"]);
  await handle(request({ action: "nearby", lat: 30.2, lng: 31.2 }));
  assert.deepEqual(calls, ["nearby", "nearby"]);
});

test("a cached answer expires", async () => {
  const { provider, calls } = fakeProvider();
  let time = 1_000_000;
  const handle = handlerWith(provider, () => time);
  await handle(request({ action: "search", q: "zam" }));
  time += 301_000;
  await handle(request({ action: "search", q: "zam" }));
  assert.equal(calls.length, 2);
});

test("a user over the limit gets 429 with Retry-After; another user does not", async () => {
  const { provider } = fakeProvider();
  const handle = handlerWith(provider, () => 1_000_000, 2);
  assert.equal((await handle(request({ action: "search", q: "aa" }))).status, 200);
  assert.equal((await handle(request({ action: "search", q: "bb" }))).status, 200);
  const limited = await handle(request({ action: "search", q: "cc" }));
  assert.equal(limited.status, 429);
  assert.equal(limited.headers.get("Retry-After"), "60");
  assert.equal((await handle(request({ action: "search", q: "cc" }, "u2"))).status, 200);
});

test("a provider that fails is a 502 and is not cached", async () => {
  let fails = true;
  const { provider, calls } = fakeProvider({
    async search() {
      if (fails) throw new ProviderError("down");
      return [CAIRO];
    },
  });
  const handle = handlerWith(provider);
  assert.equal((await handle(request({ action: "search", q: "zam" }))).status, 502);
  fails = false;
  assert.equal((await handle(request({ action: "search", q: "zam" }))).status, 200);
  assert.deepEqual(calls, []);
});

test("photon: a feature becomes a place with a subtitle and kilometres", () => {
  const place = toPlace(
    {
      properties: { name: "Zamalek", district: "Zamalek", city: "Cairo", country: "Egypt", type: "district" },
      geometry: { coordinates: [31.22, 30.06] },
    },
    { lat: 30.06, lng: 31.2 },
  );
  assert.equal(place?.name, "Zamalek");
  assert.equal(place?.subtitle, "Cairo, Egypt");
  assert.equal(place?.kind, "neighborhood");
  assert.equal(place?.distanceKm, 1.9);
  assert.equal(toPlace({ properties: { city: "Cairo" } }), null);
});

test("photon: reverse gives the area first and the city after it", () => {
  const area = toArea({ properties: { name: "Street 9", district: "Maadi", city: "Cairo", state: "Cairo Governorate" } });
  assert.deepEqual(area, { name: "Maadi", subtitle: "Cairo, Cairo Governorate", kind: "neighborhood" });
});

test("photon: nearby asks for 5 km of cafes, hotels and parks, drops unnamed and repeated places", async () => {
  const urls: string[] = [];
  const agents: string[] = [];
  const feature = (name: string, lng: number) => ({
    properties: { name, city: "Cairo" },
    geometry: { coordinates: [lng, 30] },
  });
  const unnamed = { properties: { street: "Some Street", city: "Cairo" }, geometry: { coordinates: [31.002, 30] } };
  const provider = createPhotonProvider({
    userAgent: "Test/1.0",
    fetchImpl: (async (url: URL, init: RequestInit) => {
      urls.push(String(url));
      agents.push((init.headers as Record<string, string>)["User-Agent"]);
      return new Response(JSON.stringify({ features: [feature("Far", 31.05), unnamed, feature("Near", 31.001), feature("Near", 31.0011)] }));
    }) as typeof fetch,
  });
  const places = await provider.nearby({ lat: 30, lng: 31 }, "en");
  assert.deepEqual(places.map((p) => p.name), ["Near", "Far"]);
  assert.match(urls[0], /\/reverse\?/);
  assert.match(urls[0], /radius=5/);
  assert.match(urls[0], /limit=30/);
  assert.match(urls[0], /osm_tag=tourism&osm_tag=amenity&osm_tag=leisure/);
  assert.match(urls[0], /lang=en/);
  assert.deepEqual(agents, ["Test/1.0"]);
});

test("photon: Arabic asks without a language so local names come back; a bad status is a ProviderError", async () => {
  const urls: string[] = [];
  let status = 200;
  const provider = createPhotonProvider({
    userAgent: "Test/1.0",
    fetchImpl: (async (url: URL) => {
      urls.push(String(url));
      return new Response(JSON.stringify({ features: [] }), { status });
    }) as typeof fetch,
  });
  await provider.search("زمالك", undefined, "ar");
  assert.doesNotMatch(urls[0], /lang=/);
  status = 503;
  await assert.rejects(() => provider.search("zam", undefined, "en"), ProviderError);
});
