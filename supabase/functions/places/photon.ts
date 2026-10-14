import type { Coordinates, Language } from "./input.ts";
import type { Place, PlaceKind, PlacesProvider } from "./provider.ts";

const BASE_URL = "https://photon.komoot.io";
const TIMEOUT_MS = 8000;
const RESULT_LIMIT = 10;
/** Nearby asks for more than it shows: several of them share a name and are dropped. */
const NEARBY_FETCH_LIMIT = 30;
/** Photon's reverse lookup returns houses and streets; these keys leave real places (cafes, hotels, parks). */
const NEARBY_OSM_KEYS = ["tourism", "amenity", "leisure"];
const NEARBY_RADIUS_KM = 5;
const EARTH_RADIUS_KM = 6371;

interface PhotonProperties {
  name?: string;
  street?: string;
  district?: string;
  locality?: string;
  city?: string;
  county?: string;
  state?: string;
  country?: string;
  type?: string;
  osm_key?: string;
  osm_value?: string;
}

interface PhotonFeature {
  properties?: PhotonProperties;
  geometry?: { coordinates?: [number, number] };
}

export class ProviderError extends Error {}

const AREA_TYPES = new Set(["district", "locality", "suburb", "neighbourhood", "quarter"]);
const TOWN_VALUES = new Set(["town", "village", "hamlet"]);

function kindOf(p: PhotonProperties): PlaceKind {
  if (p.type === "city" || p.osm_value === "city") return "city";
  if (p.type === "town" || TOWN_VALUES.has(p.osm_value ?? "")) return "town";
  if (AREA_TYPES.has(p.type ?? "") || AREA_TYPES.has(p.osm_value ?? "")) return "neighborhood";
  return "poi";
}

/** Distinct, non-empty parts in order, none equal to [name]. */
function parts(name: string, values: (string | undefined)[]): string {
  const seen = new Set<string>([name.toLowerCase()]);
  const out: string[] = [];
  for (const value of values) {
    const text = value?.trim();
    if (!text || seen.has(text.toLowerCase())) continue;
    seen.add(text.toLowerCase());
    out.push(text);
  }
  return out.join(", ");
}

export function distanceKm(a: Coordinates, b: Coordinates): number {
  const rad = (deg: number) => (deg * Math.PI) / 180;
  const dLat = rad(b.lat - a.lat);
  const dLng = rad(b.lng - a.lng);
  const h = Math.sin(dLat / 2) ** 2 +
    Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_RADIUS_KM * Math.asin(Math.sqrt(h));
}

export function toPlace(
  feature: PhotonFeature,
  from?: Coordinates,
  options: { onlyNamed?: boolean } = {},
): Place | null {
  const p = feature.properties;
  const name = (options.onlyNamed ? p?.name : (p?.name ?? p?.street))?.trim();
  if (!p || !name) return null;
  const place: Place = {
    name,
    subtitle: parts(name, [p.district ?? p.locality, p.city ?? p.county, p.state ?? p.country]),
    kind: kindOf(p),
  };
  const coords = feature.geometry?.coordinates;
  if (from && coords) {
    const km = distanceKm(from, { lat: coords[1], lng: coords[0] });
    place.distanceKm = Math.round(km * 10) / 10;
  }
  return place;
}

/** "Zamalek" in "Cairo, Egypt": the area first, the city and country as the subtitle. */
export function toArea(feature: PhotonFeature): Place | null {
  const p = feature.properties;
  if (!p) return null;
  const name = (p.district ?? p.locality ?? p.city ?? p.county ?? p.name)?.trim();
  if (!name) return null;
  return {
    name,
    subtitle: parts(name, [p.city ?? p.county, p.state ?? p.country]),
    kind: kindOf({ ...p, type: p.district || p.locality ? "district" : p.type }),
  };
}

/** Photon (OSM) over its public API. It lists English names; for Arabic the local names are used. */
export function createPhotonProvider(options: {
  userAgent: string;
  fetchImpl?: typeof fetch;
  baseUrl?: string;
}): PlacesProvider {
  const call = options.fetchImpl ?? fetch;
  const base = options.baseUrl ?? BASE_URL;

  async function features(path: string, params: [string, string][], language: Language) {
    const url = new URL(path, base);
    for (const [key, value] of params) url.searchParams.append(key, value);
    if (language === "en") url.searchParams.set("lang", "en");
    let response: Response;
    try {
      response = await call(url, {
        headers: { "User-Agent": options.userAgent, Accept: "application/json" },
        signal: AbortSignal.timeout(TIMEOUT_MS),
      });
    } catch {
      throw new ProviderError("provider unreachable");
    }
    if (!response.ok) throw new ProviderError(`provider answered ${response.status}`);
    const body = await response.json();
    return (Array.isArray(body?.features) ? body.features : []) as PhotonFeature[];
  }

  return {
    async search(query, near, language) {
      const params: [string, string][] = [["q", query], ["limit", String(RESULT_LIMIT)]];
      if (near) params.push(["lat", String(near.lat)], ["lon", String(near.lng)]);
      const found = await features("/api/", params, language);
      return found.map((f) => toPlace(f, near)).filter((p): p is Place => p !== null);
    },

    async nearby(at, language) {
      const found = await features("/reverse", [
        ["lat", String(at.lat)],
        ["lon", String(at.lng)],
        ["radius", String(NEARBY_RADIUS_KM)],
        ["limit", String(NEARBY_FETCH_LIMIT)],
        ...NEARBY_OSM_KEYS.map((key): [string, string] => ["osm_tag", key]),
      ], language);
      const seen = new Set<string>();
      return found
        .map((f) => toPlace(f, at, { onlyNamed: true }))
        .filter((p): p is Place => p !== null)
        .sort((a, b) => (a.distanceKm ?? 0) - (b.distanceKm ?? 0))
        .filter((p) => {
          const key = `${p.name}|${p.subtitle}`.toLowerCase();
          return seen.has(key) ? false : (seen.add(key), true);
        })
        .slice(0, RESULT_LIMIT);
    },

    async reverse(at, language) {
      const found = await features("/reverse", [
        ["lat", String(at.lat)],
        ["lon", String(at.lng)],
        ["limit", "1"],
      ], language);
      return found.length === 0 ? null : toArea(found[0]);
    },
  };
}
