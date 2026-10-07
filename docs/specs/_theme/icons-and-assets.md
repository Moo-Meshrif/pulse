# Icons and assets

## Icons [user]
- Folder: `assets/icons/` (SVG, 24 viewBox, outline, stroke ~1.8-2.4, round caps/joins). Files are `ic_<name>.svg`; active tab uses `ic_<name>_filled.svg`.
- Recolor with `ColorFilter.mode(color, BlendMode.srcIn)`. Source files are drawn in #161A19.
- Sizes: bottom bar 22 (+26), actions 23-24, list icons 18-19, chevrons 18.
- Present: ic_arrow_back, ic_arrow_forward, ic_bell, ic_block, ic_bookmark, ic_camera, ic_chat(+_filled), ic_check, ic_chevron_down, ic_chevron_right, ic_close, ic_comment, ic_document, ic_edit, ic_eye, ic_eye_off, ic_flag, ic_globe, ic_heart(+_filled), ic_help, ic_home(+_filled), ic_image, ic_laptop, ic_location, ic_lock, ic_logout, ic_mail, ic_more_horizontal, ic_music, ic_phone, ic_play, ic_plus, ic_profile(+_filled), ic_search, ic_settings, ic_share, ic_shorts(+_filled), ic_smile, ic_tag_person, ic_upload, ic_verified, ic_video_camera, ic_volume, logo.svg.
- `assets/icons/logo.svg`: 28x28 viewBox, square (no corner radius), #2E6B63 fill + white pulse line. Not registered in `pubspec.yaml` yet (`flutter: assets:` is empty).

## Fonts
Sora, Noto Sans, Noto Sans Arabic (see typography.md). Bundled in `assets/fonts/` [user]; files not yet added to the repo.

## Placeholders [user]
Photos/videos/story images are flat illustrations to be replaced by network images (`BoxFit.cover`). Avatars are initials on avatar colors.
