import type { Coordinates, Language } from "./input.ts";

export type PlaceKind = "city" | "town" | "neighborhood" | "poi";

export interface Place {
  name: string;
  subtitle: string;
  kind: PlaceKind;
  /** Kilometres from the position the request gave, when it gave one. */
  distanceKm?: number;
}

/** Where places come from. Another provider implements this and `index.ts` passes it in. */
export interface PlacesProvider {
  search(query: string, near: Coordinates | undefined, language: Language): Promise<Place[]>;
  /** Up to 10 places within about 5 km of [at], nearest first. */
  nearby(at: Coordinates, language: Language): Promise<Place[]>;
  /** The area and city [at] is in, as one place; null when nothing is known there. */
  reverse(at: Coordinates, language: Language): Promise<Place | null>;
}
