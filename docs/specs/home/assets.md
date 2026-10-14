# Home: assets

All icons exist in `assets/icons/` (24 viewBox, recolor with srcIn) [seen in repo]: `ic_search`, `ic_bell`, `ic_plus`, `ic_more_horizontal`, `ic_heart`, `ic_heart_filled`, `ic_comment`, `ic_share`, `ic_bookmark` (**no filled variant yet**: needed for saved state, Q3), `ic_volume` (mute toggle; muted variant Q3), `ic_play`, `ic_cloud_alert`, `ic_wifi_off`, `ic_inbox` (empty tile) [user], `logo.svg`.
Video: `video_flux` package (not in pubspec yet) for feed videos, stories and shorts [user].
`PulseLineLoader` already exists in `lib/core/widgets/loading_overlay/` (home reuses it).
Animations: `assets/animations/pulse_loader_light.json` (used) and `pulse_loader_dark.json` (unused, light only) exist; `lottie` is already in pubspec. `skeletonizer` is **not** in pubspec yet (add in the plan).
Images: network images (`BoxFit.cover`) with blurhash placeholders; screenshot illustrations are placeholders. Avatars: photo or initials on stable-hash colors. Fonts: Sora, Noto Sans, Noto Sans Arabic (existing).
Paths go in `lib/core/constants/app_assets.dart`.

**Added by user (Q3), present in `assets/icons/`:** `ic_bookmark_filled`, `ic_link`, `ic_user_minus`, `ic_volume_off`, `ic_comment_off`. Everything else S1/S2 needs already existed.
