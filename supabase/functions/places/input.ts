export type Language = "en" | "ar";

export type PlacesRequest =
  | { action: "search"; query: string; near?: Coordinates; language: Language }
  | { action: "nearby"; at: Coordinates; language: Language }
  | { action: "reverse"; at: Coordinates; language: Language };

export interface Coordinates {
  lat: number;
  lng: number;
}

export const MIN_QUERY_CHARS = 2;
export const MAX_QUERY_CHARS = 80;

function coordinates(lat: unknown, lng: unknown): Coordinates | null {
  if (typeof lat !== "number" || typeof lng !== "number") return null;
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return null;
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
  return { lat, lng };
}

/** The body of a POST: `{ action, q?, lat?, lng?, lang? }`. Null when it is not a valid request. */
export function parsePlacesInput(body: unknown): PlacesRequest | null {
  if (typeof body !== "object" || body === null) return null;
  const { action, q, lat, lng, lang } = body as Record<string, unknown>;
  const language: Language = lang === "ar" ? "ar" : "en";
  const at = coordinates(lat, lng);

  if (action === "search") {
    if (typeof q !== "string") return null;
    const query = q.trim();
    if (query.length < MIN_QUERY_CHARS || query.length > MAX_QUERY_CHARS) return null;
    // A search may come with or without a position; a half-given position is a bad request.
    const hasPosition = lat !== undefined || lng !== undefined;
    if (hasPosition && !at) return null;
    return { action, query, near: at ?? undefined, language };
  }
  if (action === "nearby" || action === "reverse") {
    return at ? { action, at, language } : null;
  }
  return null;
}

/** The signed-in user's id from the bearer token. The platform has already verified the signature. */
export function userIdFromAuthorization(header: string | null): string | null {
  const token = header?.replace(/^Bearer\s+/i, "");
  const payload = token?.split(".")[1];
  if (!payload) return null;
  try {
    const json = atob(payload.replace(/-/g, "+").replace(/_/g, "/"));
    const sub = JSON.parse(json)?.sub;
    return typeof sub === "string" && sub.length > 0 ? sub : null;
  } catch {
    return null;
  }
}
