// Edge Function `places`: search, nearby and reverse geocoding for the post's Add location screen
// (docs/specs/post/screens/s3-add-location.md). Deploys with verify_jwt = true: only signed-in users call it.
// The provider is OSM through Photon today; another provider only has to implement `PlacesProvider`.

import { createHandler } from "./handler.ts";
import { createPhotonProvider } from "./photon.ts";

// ---- Limits: change them here ---------------------------------------------------------------------
const RATE_LIMIT = { max: 30, windowSeconds: 60 };
const CACHE = { ttlSeconds: 5 * 60, maxEntries: 500 };
// OSM's usage policy asks for an identifying User-Agent; set PLACES_USER_AGENT to one with a contact.
const DEFAULT_USER_AGENT = "PulseApp/1.0 (places edge function)";
// ----------------------------------------------------------------------------------------------------

const provider = createPhotonProvider({
  userAgent: Deno.env.get("PLACES_USER_AGENT") ?? DEFAULT_USER_AGENT,
});

Deno.serve(createHandler({ provider, rateLimit: RATE_LIMIT, cache: CACHE }));
