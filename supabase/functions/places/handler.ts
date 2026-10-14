import { parsePlacesInput, userIdFromAuthorization } from "./input.ts";
import type { PlacesRequest } from "./input.ts";
import { ProviderError } from "./photon.ts";
import type { Place, PlacesProvider } from "./provider.ts";

export interface HandlerConfig {
  provider: PlacesProvider;
  /** Per signed-in user. Kept in memory, so it counts per running instance. */
  rateLimit: { max: number; windowSeconds: number };
  cache: { ttlSeconds: number; maxEntries: number };
  now?: () => number;
}

const MAX_BODY_CHARS = 1024;
const COORDINATE_DECIMALS = 3; // about 110 m: neighbours share cached answers

const headers = (extra: Record<string, string> = {}) => ({
  "Content-Type": "application/json",
  ...extra,
});

function json(status: number, body: unknown, extra: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), { status, headers: headers(extra) });
}

const round = (n: number) => n.toFixed(COORDINATE_DECIMALS);

function cacheKey(request: PlacesRequest): string {
  switch (request.action) {
    case "search": {
      const near = request.near ? `${round(request.near.lat)},${round(request.near.lng)}` : "-";
      return `search|${request.language}|${near}|${request.query.toLowerCase()}`;
    }
    default:
      return `${request.action}|${request.language}|${round(request.at.lat)},${round(request.at.lng)}`;
  }
}

/**
 * The places endpoint: POST { action: "search" | "nearby" | "reverse", q?, lat?, lng?, lang? } ->
 * { places: [{ name, subtitle, kind, distanceKm? }] }. Needs a signed-in user (verify_jwt). Nothing about
 * a person or a position is logged or stored; answers are cached by rounded position and text.
 */
export function createHandler(config: HandlerConfig): (req: Request) => Promise<Response> {
  const now = config.now ?? (() => Date.now());
  const hits = new Map<string, number[]>();
  const cache = new Map<string, { expires: number; places: Place[] }>();

  /** Seconds to wait, or 0 when the call is allowed. */
  function wait(userId: string): number {
    const windowMs = config.rateLimit.windowSeconds * 1000;
    const recent = (hits.get(userId) ?? []).filter((t) => now() - t < windowMs);
    if (recent.length >= config.rateLimit.max) {
      hits.set(userId, recent);
      return Math.max(1, Math.ceil((recent[0] + windowMs - now()) / 1000));
    }
    recent.push(now());
    hits.set(userId, recent);
    return 0;
  }

  function remember(key: string, places: Place[]) {
    if (cache.size >= config.cache.maxEntries) {
      const oldest = cache.keys().next().value;
      if (oldest !== undefined) cache.delete(oldest);
    }
    cache.set(key, { expires: now() + config.cache.ttlSeconds * 1000, places });
  }

  async function lookup(request: PlacesRequest): Promise<Place[]> {
    switch (request.action) {
      case "search":
        return await config.provider.search(request.query, request.near, request.language);
      case "nearby":
        return await config.provider.nearby(request.at, request.language);
      case "reverse": {
        const place = await config.provider.reverse(request.at, request.language);
        return place ? [place] : [];
      }
    }
  }

  return async (req) => {
    if (req.method !== "POST") return json(405, { code: "method_not_allowed" }, { Allow: "POST" });
    const userId = userIdFromAuthorization(req.headers.get("Authorization"));
    if (!userId) return json(401, { code: "unauthorized" });

    const text = await req.text();
    let body: unknown;
    try {
      body = text.length > MAX_BODY_CHARS ? null : JSON.parse(text);
    } catch {
      body = null;
    }
    const request = parsePlacesInput(body);
    if (!request) return json(400, { code: "bad_request" });

    const key = cacheKey(request);
    const cached = cache.get(key);
    if (cached && cached.expires > now()) return json(200, { places: cached.places });

    const retryAfter = wait(userId);
    if (retryAfter > 0) {
      return json(429, { code: "rate_limited" }, { "Retry-After": String(retryAfter) });
    }
    try {
      const places = await lookup(request);
      remember(key, places);
      return json(200, { places });
    } catch (error) {
      if (!(error instanceof ProviderError)) console.error("places: unexpected error");
      return json(502, { code: "provider_unavailable" });
    }
  };
}
