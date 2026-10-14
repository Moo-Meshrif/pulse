# Post feature: overview

Platform: Flutter, phone, 390 x 844 frame, **light only**, LTR + RTL, EN + AR [user]. Screenshots 720 px wide (1.846x); dp = px / 1.846 [estimated] unless tagged otherwise.
Theme: reuse `../_theme/` and `lib/core/theme/`; deltas in `01-design-tokens.md`. RTL: `../_theme/rtl.md`.
Data layer: `00-data-layer.md` (short spec, no UI). Consumers: `home` (feed, post options), `control-page` (Create sheet routes here).
Video: `video_flux` [user]. Backend: Supabase now, REST later; schema `../home/schema.sql` + `../home/schema-post-options.sql` (applied; the visibility and shared-actions schemas are `schema-post-visibility.sql` and `schema-shared-content-actions.sql`, applied 2026-10-14).

## Screens
| ID | Name | File | Screenshot | Route |
|---|---|---|---|---|
| S1 | New post | screens/s1-new-post.md | screenshots/s1-new-post.png | `/create/post` (full screen, pushed on the root Navigator, nav hidden) |

| S3 | Add location (list picker opened from New post > Location) | screens/s3-add-location.md | screenshots/s3-add-location.png | `/create/post/location` |
| S4 | Post visibility picker (from the S1 chip and S2 "Change who can see") | screens/s4-visibility.md | screenshots/s4-visibility.png | sheet |
| S2 | Post options sheet + report flow (opened from a post's "···") | screens/s2-post-options.md | screenshots/s2-post-options.png | sheet |

Public post widgets (post card, options flow, visibility sheet): specced in `02-components.md`, built in `features/post/presentation/` and exported for other features [user, 2026-10-14].

Not specced yet: media picker, tag people, feeling/activity, settings > privacy, post detail, comments, edit caption (opened from Home S2), saved posts.

## Navigation map
```
Control page Create sheet --Post--> /create/post (S1)
"···" on a post --> S2 (any feature that shows a PostCard)
S1 Location row --> S3 (returns a place name or none)
S1 X (or system back) --> discard confirm if there is content, else close
S1 Share post ok --> close, notice "Post shared" (Home feed refreshes)
```
Files: `00-data-layer.md` · `01-design-tokens.md` · `02-components.md` · `screens/s1-new-post.md` · `screens/s2-post-options.md` · `screens/s3-add-location.md` · `open-questions.md` · `progress.md`
