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
| Q12 | Cross-feature widgets | - | **superseded** [user, 2026-10-14]: PostCard, options flow and their plain types stay in `features/post/presentation` as public exports (see `02-components.md`) |
| Q13 | Where `PostActionsCubit` logic lives | - | **answered** [user]: a **datasource in `lib/core`** (name: `PostActionsDatasource`: like, save, hide, report, comments toggle, delete) plus **use cases in `lib/core`**; each feature (home now, profile/saved later) calls those use cases from its own small Cubit. Supersedes the 'feed use cases in post' split for these actions. Exact core folder set in the plan. **Superseded [user, 2026-10-14]**: post-only actions (like, save, hide, comments toggle, delete) live in `features/post`; report, change audience, mute and file cleanup are shared in `lib/shared/content` (see `00-data-layer.md` > Shared code update) |
| Q-V1 | Privacy settings link | - | **answered** [user]: "Coming soon" + code TODO until Settings > Privacy is specced |
| Q-V2 | Only me notice | - | **answered** [user]: "Only you can see this post" / "It's saved to your profile, hidden from everyone" |
| Q-V3 | Button label / share by link | - | **answered** [user]: S1 keeps "Share post"; S2 Copy link + Share are "Coming soon" + code TODO until post deep links exist |
| Q-V4 | Default visibility | - | **answered** [user + board]: Public every time unless "Use for future posts" saved another default; private account -> Followers |
| Q14 | Share button label | - | **answered** [user, 2026-10-15]: stays "Share post" (board 1 panel 7 shows "Post") |
| Q15 | Allow comments row | - | **answered** [user]: stays as the 5th row of S1 |
| Q16 | Tag in photo (S7) | - | **answered** [user]: spec and build in full |
| Q17 | Mood columns | - | **answered** [user]: `mood_kind` + `mood_key` + `mood_text` |
| Q18 | Emoji | - | **answered** [user]: native emoji characters, no assets |
| Q19 | Suggested people | - | **answered** [user]: people you follow, newest follow first |
| Q20 | Activity suggestions | - | **superseded** [user, 2026-10-15]: activities (tab, S9, suggestions) are deferred; the source will be an API or a database, decided later (TODO). Table and RPC removed from the SQL |
| Q21 | Remove own tag | - | **answered** [user, board `s11-remove-tag-board.png`]: S2 row, own photo label, S10 row; profile Tagged tab = profile spec follow-up |
| Q22 | Tag notification | - | **answered** [user]: row only (type `tag`); UI with Activity |
| Q23 | Allow tags | - | **answered** [user]: column + enforcement now (default everyone); Settings toggle later |
| Q24 | Schema SQL | - | **answered** [user]: `schema-post-tags-mood.sql` written; not validated/applied |
| Q25 | S7 pick list | - | **answered** [user]: only people already chosen in S6 |
| Q26 | Activity headline | - | **answered**: board format "is 📺 watching {text}" [seen] |
| Q27 | Blocked accounts in tag search | - | **answered** [user]: skipped for now, TODO in the SQL until blocking exists |
| Q28 | Arabic wording | - | **answered** [user, 2026-10-15]: no gendered verbs; feelings are nouns (سعادة، حماس، امتنان، تعب…), activities verbal nouns ("📺 مشاهدة الديربي"), headline "نور عادل · 😊 سعادة · مع عمر خالد و٢ آخرين". Everything else stays `x-review` |
| Q30 | Entry to S7 | - | **answered** [user]: a "Tag in photo" button on S6 (photos only, needs >= 1 person chosen); button placement/size estimated |
| Q29 | Estimated sizes | - | **answered** [user, board 3.16]: S7 thumbs 56 r12 etc., S6 counter/empty/button; see `01-design-tokens.md` (only S9 row sizes remain estimated, deferred) |
| Q-S1 | Share sheet scope | - | **answered** [user, 2026-10-21]: composer, notice, shared card and unavailable embed built; Send in chat hidden until Chat exists; Copy link / WhatsApp / More = "Coming soon" (T7) until the user provides the deep link |
| Q-S2 | Share icon visibility | - | **answered** [user]: shown for Public and Followers posts; for Followers only on your own post (Add to story only) [assumption for others' Followers posts: hidden, confirm] |
| Q-S3 | Notice per audience, notification | - | **answered** [user]: one line per audience; author notified (type share, grouped per post) |
| Q-S4 | Share card taps | - | **answered** [user, "as Facebook"]: share "···" = share options (own: edit without media, audience, delete); embedded card opens the original |
| Q-S5 | Add to story | - | **answered** [user]: built now, board s13; viewer sticker tap opens the post's comments route |
| Q-S6 | New package `palette_generator` (background from media colors) | approve / use another way | pending, ask in the phase |
| Q-S7 | Audience chip default and View target | - | [estimated]: default = account default audience; View scrolls Home to top. Confirm |
| Q-S8 | Edit post on a share | - | **answered** [user, 2026-10-21]: S5 without media, original read-only; Tag people, Feeling and Location kept |
| Q-S9 | Palette tool icon | - | **answered** [user]: `assets/icons/ic_palette.svg` added (register in `app_assets.dart`) |
| Q-S10 | Title icon `ic_share_forward` | - | **answered** [user]: added to `assets/icons` (register it) |
| Q-S11 | Followers posts | - | **answered** [user]: Public = anyone can share; Followers = only people who can see it, via chat later (hidden icon until chat exists, except own post's Add to story) |

