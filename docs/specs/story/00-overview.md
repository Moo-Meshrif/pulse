# Story feature: overview

Platform: Flutter, phone, 390 x 844 frame, **light app theme** (story screens are full-bleed dark/media), LTR + RTL, EN + AR [user]. Source: `screenshots/stories-board.png` (board with 6 panels + 3 token notes). Data layer: `00-data-layer.md`. Video via `video_flux` [user]. Backend: Supabase now; schema `../home/schema.sql` (stories, story_views, `story_rail`) + `schema-story-extras.sql` (overlays, story_likes, `author_stories`, `set_story_like`, `story_viewers`; spec-level, not applied).
Theme: reuse `../_theme/`; deltas in `01-design-tokens.md`. 24-hour stories: photos and videos up to 60 s [board].
Ownership [user]: the story feature owns the **viewer** and **create** screens and their routes; the rail UI is home's (`../home`). Home opens these routes from the rail.

## Screens
| ID | Name | File | Panels | Route |
|---|---|---|---|---|
| S1 | Story viewer (others' stories) + your own story with viewers sheet | screens/s1-story-viewer.md | 1, 2 | `/story/:authorId` full screen |
| S2 | Create: camera and recording | screens/s2-create-camera.md | 3, 4 | `/create/story` |
| S3 | Create: edit and share | screens/s3-create-edit.md | 5 | `/create/story/edit` |
| S4 | Posting state on the Home rail | screens/s4-posting-rail.md | 6 | on `/home` |

## Navigation map
```
Home rail: story avatar --> /story/:authorId (S1, starts at the first unseen story)
Home rail: "Your story" (+) --> /create/story (S2) ; own story item --> /story/:me (S1 + viewers)
Create sheet: no Story row [user]; stories start from the rail only
S2 shutter (tap = photo, hold = video) --> S3 edit --Share--> pop to Home; upload in the background; rail shows S4
S2 gallery thumbnail --> photo/video picker --> S3
S1 swipe down / X --> close; swipe left on the last story of a person --> next person; after the last person --> close
```
Full-screen routes are pushed on the root Navigator: the control-page nav is hidden [control-page].

## Files
`01-design-tokens.md` · `screens/*` · `00-data-layer.md` · `assets.md` · `open-questions.md` · `progress.md`

## Added 2026-10-13
| ID | Name | File | Board |
|---|---|---|---|
| S5 | Camera and microphone permissions (shared with short, profile photo) | screens/s5-camera-permissions.md | camera-permissions board (image) |
| S6 | Viewer options, report, delete | screens/s6-viewer-menus.md | `stories-board-v2.png` panels 7-10 |
Board v2: `screenshots/stories-board-v2.png` (10 panels) supersedes the 6-panel board for S1/S6.
