# Story feature: open questions
| # | Question | Options | Status |
|---|---|---|---|
| Q1 | Rail title + labels | - | **answered** [user]: remove "Trending"; the rail title follows the board (**"Stories"** [my reading of "remove trending", correct me]); labels = **username** (truncated). Home specs edited |
| Q2 | Create sheet Story row | - | **answered** [user]: no, stories start from the rail only |
| Q3 | Story likes / replies | - | **answered** [user]: `story_likes` added in `schema-story-extras.sql`; replies deferred to Chat |
| Q4 | Viewers list RPC | - | **answered**: `story_viewers` + `author_stories` + `set_story_like` in `schema-story-extras.sql` (spec-level, not applied) |
| Q5 | Camera/microphone permission and error screens | - | **answered** [user]: board supplied -> `screens/s5-camera-permissions.md` (shared by story, short, profile photo) |
| Q6 | "···" menu in the viewer | - | **answered** [user]: board panels 7-10 -> `screens/s6-viewer-menus.md` |
| Q7 | Audience of "Your story" pill | - | **answered** [user]: "Followers" (Public for public accounts) |
| Q8 | Failed upload ring color | - | **answered** [user], superseded by token file: failed ring = `warningInk` `#B26F12` (exists in AppColors), label "Retry" |
| Q9 | Overlays | - | **answered** [user]: JSON `stories.overlays` (type, text, x, y fractions, scale, rotation, color), rendered in the viewer; no re-encode |
| Q10 | Icons | - | **answered**: `ic_download`, `ic_flash`, `ic_camera_flip`, `ic_text`, `ic_user`, `ic_profile`, `ic_globe`, `ic_lock` verified in `assets/icons`. "Who can see this" uses `ic_audience` (exists) |
| Q11 | Packages | - | **answered** [user, plan]: `camera` + `permission_handler` + `video_flux` + `gal` + `image_picker` (existing) |
| Q12 | Arabic copy | review | `x-review` |
| Q13 | Save story to device and Delete confirm copy [estimated] | confirm | pending |
| Q14 | story_mutes + story reports | - | **answered**: written in `schema-story-extras.sql` section 4 (`story_mutes`, `set_story_mute`, `reports.story_id`, `report_story`); `story_rail` must skip muted authors (plan). **Update 2026-10-14**: `set_story_mute` and `report_story` are replaced by the shared `set_mute(p_user, p_muted, p_scope: 'stories')` and `report_content(p_kind: 'story', …)` (`20261019120000_shared_content_actions.sql`, applied 2026-10-14); `story_mutes` and `reports.story_id` stay |
| Q15 | Dark colors | - | **answered** [user]: sheet/dialog surface `#1F2423` (estimated), background `#161A19`, amber `#F2B45A` |
| Q16 | Permissions board file | - | **answered**: copied from the session image cache to `screenshots/camera-permissions-board.png` |
| Q17 | Viewers data | - | **answered** [user]: `story_viewers` RPC (liked + total); token file query superseded |
| Q18 | "Who can see this" | - | **answered** [user, board v3]: picker built (Followers / Close friends / Hide story from + list screens), audience saved on the story; see `screens/s7-who-can-see.md` |
| Q19 | Viewer count chip | - | **answered** [user]: as in token file (eye 18 + count, bottom-start, swipe up) |
| Q20 | Mute table | - | **answered** [user]: separate `story_mutes` |

## Decisions from /spec-to-plan (2026-10-13) [user]
| # | Decision |
|---|---|
| P1 | Backend: plan Phase 0 writes the three migrations (home schema, post options, story extras) into `supabase/migrations`, user reviews, then they are applied. `story_rail` re-created to also skip `story_mutes`; `story_viewers` gets a cursor `p_before` (viewed_at), page 30 |
| P2 | Until Home is built, a temporary minimal rail in the Home placeholder opens the story screens (replaced by Home's real rail) |
| P3 | Upload progress: streamed upload to the storage REST endpoint with the existing `http` package, counting bytes sent |
| P4 | Save to device: photos burned in with overlays; videos burned in too (native overlay, see `docs/plans/story-video-burn-in-plan.md`; not yet run on a device) |
| P5 | Copy link hidden for now (no story link format yet) |
| P6 | Report sheet is shared (core), built now; story "sent" step = title "Thanks for letting us know" + body "We'll review this story." [estimated] + Done; post adds its Mute/Unfollow rows later |
| P7 | Reply Send shows a "coming soon" notice until Chat exists |
| P8 | Location sticker tool hidden until post's Add location (post S3) exists |
