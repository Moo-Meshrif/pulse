# Post feature: open questions
| # | Question | Options | Status |
|---|---|---|---|
| Q1 | Visibility | - | **answered** [user, board `screenshots/s4-visibility.png`]: built now; Public / Followers / Close friends / Only me; picker S4; change later from S2; migration as on the board (not written yet) |
| Q2 | `create_post` comments | - | **answered** [user]: add `p_comments_enabled boolean default true` to `create_post` in `../home/schema-post-options.sql` (SQL written in section 8 of that file, applied; `create_post` later gained `p_visibility`) |
| Q3 | Location row | - | **answered** [user]: location picked in S3 (`screens/s3-add-location.md`); stored as a display name in `posts.location` (<= 80), no coordinates |
| Q4 | Estimated sizes | - | **answered**: all confirmed [user] |
| Q5 | Discard confirm | - | **answered** [user]: only when there is content |
| Q6 | Upload progress | - | **answered** [user]: the shared `PrimaryButton`'s `loading` flag (no per-file progress) |
| Q11 | Location picker design | - | **answered** [user]: board `screenshots/s3-add-location.png` (a list, not a map) |
| Q-L1 | Places provider | - | **answered** [user]: **OSM for now** (Photon/Nominatim) behind the Edge Function; provider stays swappable. Note: OSM public endpoints have usage limits and weak POI/Arabic data; plan must set a User-Agent, caching and rate limiting, or a self-hosted/paid Photon later |
| Q-L2 | Icons to provide in `assets/icons/`: `ic_clock`, `ic_crosshair`, `ic_crosshair_thin` (large, primer), `ic_location_thin` (large pin 56) | user supplies | **done** [user]: all four are in `assets/icons` (verified) |
| Q-L3 | Search autofocus | - | **answered** [user]: autofocus only when nearby is not available (no permission / not now); no autofocus when nearby is shown |
| Q-L4 | Packages: location | - | **answered** [user: follow earlier features]: `permission_handler` already in; add only `geolocator` (one-time position); reverse geocode through the `places` Edge Function; no new geocoding package |
| Q-L5 | Units + recent | - | **answered** [user]: km only (AR: كم); recent = last 5 on device via a datasource |
| Q-L6 | Optional later columns `location_place_id/lat/lng` and location page | defer | deferred |
| Q7 | Compression | - | **answered** [user: follow earlier features]: same as avatar upload in `PhotoPickerService` (max side + `imageQuality` from image_picker); no video transcode, only the 10 min / 50 MB checks. Exact post values (e.g. 2048 px / 85) set in the plan |
| Q8 | Picker | - | **answered** [user: follow earlier features]: `image_picker` via the existing core `MediaPickerService` (story); extend it for multi-pick (up to 10), no `photo_manager`; camera capture reuses the story `camera` package/services only if the plan needs it |
| Q9 | `CreatePostUseCase` + `NewPostEntity` | - | **done**: added to `00-data-layer.md` |
| Q10 | Arabic review | review | `x-review` |
| Q12 | Cross-feature widgets | - | **answered** [user]: no convention exception; shared widgets go in `lib/core/widgets/` (PostCard, options sheet as pure UI with `PostCardData` + callbacks) |
| Q13 | Where `PostActionsCubit` logic lives | - | **answered** [user]: a **datasource in `lib/core`** (name: `PostActionsDatasource`: like, save, hide, report, comments toggle, delete) plus **use cases in `lib/core`**; each feature (home now, profile/saved later) calls those use cases from its own small Cubit. Supersedes the 'feed use cases in post' split for these actions. Exact core folder set in the plan. **Superseded [user, 2026-10-14]**: post-only actions (like, save, hide, comments toggle, delete) live in `features/post`; report, change audience, mute and file cleanup are shared in `lib/shared/content` (see `00-data-layer.md` > Shared code update) |
| Q-V1 | Privacy settings link | - | **answered** [user]: "Coming soon" + code TODO until Settings > Privacy is specced |
| Q-V2 | Only me notice | - | **answered** [user]: "Only you can see this post" / "It's saved to your profile, hidden from everyone" |
| Q-V3 | Button label / share by link | - | **answered** [user]: S1 keeps "Share post"; S2 Copy link + Share are "Coming soon" + code TODO until post deep links exist |
| Q-V4 | Default visibility | - | **answered** [user + board]: Public every time unless "Use for future posts" saved another default; private account -> Followers |
