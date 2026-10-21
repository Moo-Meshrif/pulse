# Post feature: overview

Platform: Flutter, phone, 390 x 844 frame, **light only**, LTR + RTL, EN + AR [user]. Screenshots 720 px wide (1.846x); dp = px / 1.846 [estimated] unless tagged otherwise.
Theme: reuse `../_theme/` and `lib/core/theme/`; deltas in `01-design-tokens.md`. RTL: `../_theme/rtl.md`.
Data layer: `00-data-layer.md` (short spec, no UI). Consumers: `home` (feed, post options), `control-page` (Create sheet routes here).
Video: `video_flux` [user]. Backend: Supabase now, REST later; schema `../home/schema.sql` + `../home/schema-post-options.sql` (applied; the visibility and shared-actions schemas are `schema-post-visibility.sql` and `schema-shared-content-actions.sql`, applied 2026-10-14).

## Screens
| ID | Name | File | Screenshot | Route |
|---|---|---|---|---|
| S1 | New post | screens/s1-new-post.md | screenshots/s1-new-post.png | `/create/post` (full screen, pushed on the root Navigator, nav hidden) |
| S5 | Edit post (S1 opened on an existing post, from S2 "Edit post") | screens/s5-edit-post.md | none (S1 layout) | `/edit/post` |
| S3 | Add location (list picker opened from New post > Location) | screens/s3-add-location.md | screenshots/s3-add-location.png | `/create/post/location` |
| S4 | Post visibility picker (from the S1 chip and S2 "Change who can see") | screens/s4-visibility.md | screenshots/s4-visibility.png | sheet |
| S6 | Tag people | screens/s6-tag-people.md | screenshots/s6-tag-feeling-board.png (panels 1-2) | `/create/post/tag-people` |
| S7 | Tag in photo | screens/s7-tag-in-photo.md | screenshots/s6-tag-feeling-board.png (panel 3) | `/create/post/tag-in-photo` |
| S8 | Feeling / activity | screens/s8-feeling-activity.md | screenshots/s6-tag-feeling-board.png (panels 4-5) | `/create/post/feeling` |
| S9 | Activity: what (**deferred, TODO**) | screens/s9-activity-what.md | screenshots/s6-tag-feeling-board.png (panel 6) | `/create/post/feeling/activity` |
| S10 | Tagged people sheet | screens/s10-tagged-people.md | screenshots/s10-card-details-board.png (panel 3) | sheet |
| S11 | Remove your tag | screens/s11-remove-tag.md | screenshots/s11-remove-tag-board.png | dialog |
| S12 | Share sheet (send icon, S2 Share) | screens/s12-share-sheet.md | screenshots/s12-share-board.png | sheet |
| S13 | Add post to story: sticker card | screens/s13-add-to-story.md | screenshots/s13-add-to-story-board.png | story editor / viewer |
| S2 | Post options sheet + report flow (opened from a post's "···") | screens/s2-post-options.md | screenshots/s2-post-options.png | sheet |

Public post widgets (post card, options flow, visibility sheet): specced in `02-components.md`, built in `features/post/presentation/` and exported for other features [user, 2026-10-14].

Not specced yet: media picker, settings > privacy (incl. "Allow tags" toggle), post detail, comments, saved posts, profile Tagged tab. Card details (headline, meta, tag badge and labels, comments-off) are in `02-components.md` (board `screenshots/s10-card-details-board.png`).

## Navigation map
```
Send icon on a card / S2 Share --> S12 (Public; own Followers posts: Add to story only) --> Share now --> notice + View (Home top)
S12 Add to story --> story editor with the post sticker (S13) --> Share --> story posted; viewers tap the sticker --> View post --> the post's comments route
Control page Create sheet --Post--> /create/post (S1)
"···" on a post --> S2 (any feature that shows a PostCard)
S1 Location row --> S3 (returns a place name or none)
S1 Tag people row --> S6 --> ("Tag in photo" button, photos only) S7 --> back to S6 --> Done --> S1; S1 Feeling row --> S8 --> S9 (activity) --> back to S1
Card "N others" / badge long-press --> S10; own label / S2 row / S10 row --> S11 confirm
S1 X (or system back) --> discard confirm if there is content, else close
S1 Share post ok --> close, notice "Post shared" (Home feed refreshes)
S2 Edit post (own post) --> /edit/post (S5); Save ok --> close, notice "Post updated" (Home feed reloads)
```
Schema: `schema-post-tags-mood.sql`, `schema-post-share.sql` (not applied). Files: `00-data-layer.md` · `01-design-tokens.md` · `02-components.md` · `screens/s1-new-post.md` · `screens/s2-post-options.md` · `screens/s3-add-location.md` · `open-questions.md` · `progress.md`
