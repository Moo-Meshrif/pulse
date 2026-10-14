# Add location (S3)
Screenshot: `../screenshots/s3-add-location.png` (board with 4 panels + 3 notes; not 720 px, sizes below come from the board's own notes unless tagged). Opened from the **Location** row of New post (S1).
Purpose / route: choose the place name saved on the post; `/create/post/location`, pushed page that slides in from the end [user]. It is a **list** (current location, nearby, recent, search), not a map.

## Panels
1. Add location (default) · 2. Searching · 3. No results · 4. Allow location access (first-time permission primer).

## Layout tree (panel 1)
```
Scaffold (background)  [AppSafeArea]
├─ Header 56: back arrow (start) · "Add location" Sora 20/700 · "Remove" 15/700 danger (end, only when a location is set)
├─ Search pill: height 48, white, r24, search icon 20, placeholder "Search places", clear button 28 (when text), focused ring 2 primary
├─ Card (white r22): "Use current location" row (tile primarySoft, crosshair icon; sub = reverse-geocoded "Zamalek, Cairo")
├─ Section "NEARBY" (13/700 uppercase textSecondary, 14 above) + white card r22 with rows
├─ Section "RECENT" + white card r22 with rows (clock tile)
```
Panel 2: search focused; section "RESULTS" + card with rows, matched part of the name **bold**; loader while loading.
Panel 3: pin icon 56 + title "No places found" centered in the space below the search.
Panel 4: centered crosshair icon (large), title "Allow location access" (Sora bold ~22 [estimated]), body "See places near you when you add a location. Pulse only uses it while you're choosing a place." (textSecondary, centered), primary pill "Allow location" (with soft shadow), text button "Not now" (primary).

## Elements
| Element | Text | Size | Token | Notes |
|---|---|---|---|---|
| Header | "Add location" | 56 high | Sora 20/700 | back = `ic_arrow_back` |
| Remove | "Remove" | | danger 15/700 | only when a location is set; clears and returns |
| Search | "Search places" | 48, r24, icon 20 | white / textSecondary | autofocus only when nearby is not available; unfocused when nearby is shown [user] |
| Row | name 15/600, sub 13 textSecondary | >= 62 high | | tile 40 r13: current = `primarySoft`, others = `background`; selected = `ic_check` 20 primary at end |
| Current row | "Use current location", sub = area, city | | | crosshair icon 22 primary |
| Nearby row | e.g. "Cairo Tower" / "Zamalek, Cairo · 0.8 km" | | | `ic_location` pin icon in tile |
| Recent row | e.g. "Alexandria, Egypt" / "City" | | | clock icon in tile |
| Result row | e.g. "Karnak Temple" / "Luxor, Egypt"; "Kardasa, Giza" / "Neighborhood · 14 km" | | | matched prefix bold |
| Section label | "NEARBY", "RECENT", "RESULTS" | | `section` 13/700 | |
| Empty | "No places found" | icon 56 | title ~18/700 [estimated] | |
| Primer | see panel 4 | button h 56 [estimated] | `PrimaryButton` | |

## States
| State | UI |
|---|---|
| Default, permission granted | Current location, NEARBY (up to 10 within ~5 km), RECENT (last 5 picks) |
| Default, permission not asked yet | Panel 4 first (before the system prompt) |
| Not now / denied | Search + RECENT only; no current/nearby |
| Denied forever | Panel 4 button reads "Open settings" |
| Searching | starts at >= 2 chars, 300 ms debounce, cancels stale requests; loader = `PulseLineLoader` width 44; matched part bold |
| No results | panel 3 |
| Offline | search disabled with inline row "Search needs a connection"; recent still works |
| Selected | check on the row that equals the post's current location |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| locTitle | Add location | إضافة موقع |
| locRemove | Remove | إزالة |
| locSearchHint | Search places | ابحث عن أماكن |
| locUseCurrent | Use current location | استخدام الموقع الحالي |
| locNearby / locRecent / locResults | Nearby / Recent / Results | بالقرب منك / الأخيرة / النتائج |
| locNoResults | No places found | لم يتم العثور على أماكن |
| locOffline | Search needs a connection | البحث يحتاج إلى اتصال |
| locPrimerTitle | Allow location access | السماح بالوصول إلى الموقع |
| locPrimerBody | See places near you when you add a location. Pulse only uses it while you're choosing a place. | شاهد الأماكن القريبة منك عند إضافة موقع. يستخدم Pulse موقعك فقط أثناء اختيارك لمكان. |
| locAllow / locNotNow / locOpenSettings | Allow location / Not now / Open settings | السماح بالموقع / ليس الآن / فتح الإعدادات |
| distance | {km} km | {km} كم (km only [user]) |
| place types | City, Town, Neighborhood | مدينة، بلدة، حي |

## Behavior and navigation
- Tap a row -> back to New post with that place; "Remove" -> back with no place; back arrow -> back unchanged.
- **Current location:** one-time position (no tracking) -> reverse geocode to "area, city". **Nearby:** up to 10 places within ~5 km. **Recent:** last 5 picks stored on the device.
- **First open:** panel 4 primer; Allow -> system permission dialog -> panel 1 with nearby; Not now -> search + recent only; denied forever -> button "Open settings".
- Never store the user's exact GPS position on the post [board].

## Data mapping
| UI | Source |
|---|---|
| Saved value | `posts.location` text (<= 80): **display name only**, e.g. "Zamalek, Cairo" (what exists today) |
| Places search / nearby / reverse geocode | places provider (**OSM (Photon/Nominatim) for now** [user]; swappable) called from a Supabase **Edge Function** so the key stays server-side [board] |
| Recent | device storage via a datasource (not widgets) |
| Later (optional) | `location_place_id`, `location_lat`, `location_lng` for a location page showing all posts there |

## Responsive / a11y
`ContentWidth` on wide screens. Rows >= 62 high, Semantics = name + sub (+ "selected"). Back/Remove/Allow >= 44. RTL: back arrow and slide direction mirror, check/chevrons at the end, matched-bold works per script.

## Acceptance checklist
- [ ] Header with back, title and a red "Remove" only when a location is set.
- [ ] White search pill r24 with focused 2 px primary ring and clear button.
- [ ] Current/Nearby/Recent sections in white r22 cards, tiles 40 r13, selected check.
- [ ] Search at 2 chars + 300 ms debounce, matched part bold, loader 44.
- [ ] No-results and offline states.
- [ ] Primer shown first time; Not now keeps search + recent; denied forever shows "Open settings".
