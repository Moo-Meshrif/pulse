# Auth: assets

## Icons (`assets/icons/`, see `_theme/icons-and-assets.md`)
| Use | File | Size | Color | Status |
|---|---|---|---|---|
| Back arrow | ic_arrow_back.svg | 24 (mirrors in RTL) | textPrimary | present |
| Lock (S2 tile) | ic_lock.svg | 32 | primary | present |
| Mail (S4 tile, S9 dialog) | ic_mail.svg | 32 / 24 | primary | present |
| Eye / eye off | ic_eye.svg, ic_eye_off.svg | 22 | textSecondary | present |
| Check (checkbox, chips) | ic_check.svg | 16 | white | present |
| Camera (S6) | ic_camera.svg | 28 | primary | present |
| Plus (S6 badge) | ic_plus.svg | 14 | white | present |
| Key (S11 tile) | ic_key.svg | 32 | primary | present (added by user) |
| Close X (S11) | ic_close.svg | 24 | textPrimary | present |
| Warning triangle (S10) | **ic_warning.svg** | 24 | danger | present (added by user) |
| Wifi off (S13 offline) | ic_wifi_off.svg | 40 | primary | present (added by user) |
| Cloud alert (S13 can't reach) | ic_cloud_alert.svg | 40 | primary | present (added by user) |
| Logo (S1) | logo.svg | 48 tile | own fills | present, not yet registered in pubspec assets if still empty |

Add every path to `lib/core/constants/app_assets.dart` (no string literals in widgets).

## Icons for the shared ConfirmationDialog (non-auth variants shown in `screenshots/confirmation-dialog-component.png`)
`ic_logout.svg` (present), `ic_bookmark.svg` (present), `ic_check.svg` (present), `ic_warning.svg` (present); `ic_trash.svg` (present, added by user; used by the Delete variant, not auth).

## Images
None bundled. Avatars are initials on palette colors; profile photo is user-picked then uploaded.

## Fonts
Sora, Noto Sans, Noto Sans Arabic (already in `assets/fonts/`).

## Packages the implementation will need (not yet in pubspec)
supabase_flutter, pinput (user), image_picker (user), url_launcher (mailto fallback, user), country_picker (all countries, dial codes and localized names; data only, our own sheet UI; user, 2026-10-10), android_intent_plus (open the Android mail inbox, 2026-10-10). Dates use `showDatePicker`. Confirm versions at plan time.
