# Tagged people sheet (S10)
Screenshot: `../screenshots/s10-card-details-board.png` (board 2, panel 3). Opened from "N others" in the card headline, or a long-press on the person badge on the media.
Purpose / route: list everyone tagged in a post with Follow / Following; bottom sheet, no route [user].

## Layout tree
```
Sheet (Post options shell: surface, top r28, padding 10 16 34, grabber 40 x 5, scrim 40%)
├─ Title row: "Tagged people" (Sora 18/700) ........ close circle 40 (`ic_close`)
└─ Rows (gap 8, min 62): avatar 44 + name 15/700 + @username 13 textSecondary ........ trailing pill
     pill: "Following" (outlined: 1 px border, text textPrimary 13/600, h 36, r18) · "Follow" (primary fill, white) · "Requested" (outlined, textSecondary)
```
Tap a row (not the pill) opens the profile. Rows come in tag order. People who removed their tag are not listed.

## Own row
The tagged user's own row shows the pill **"Remove"** (outlined, `danger` text) instead of Follow; it opens the confirm dialog of `s11-remove-tag.md` [user, board `s11-remove-tag-board.png`].

## States
| State | UI |
|---|---|
| Loading | `PulseLineLoader` width 44 |
| Error | notice "Couldn't load people. Retry" |
| Follow tap | optimistic; Follow -> Following (or Requested for a private account); rolls back with a notice on failure; uses the follow use cases (no follow datasource import) |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| taggedPeopleTitle | Tagged people | الأشخاص الموسومون |
| followStates | Follow / Following / Requested | متابعة / تتم متابعته / تم الطلب |
| taggedRemove | Remove | إزالة |

## Data mapping
`rpc('post_tagged_people', {p_post})` -> id, username, full_name, avatar_url, follow_state (`none | pending | following | me`). Follow / unfollow: the follow feature's `ToggleFollowUseCase`.

## Responsive / a11y
Sheet capped at the shared max width; rows >= 56; semantics "{name}, following" etc.; close 44. RTL: pills at the start side, list mirrors.

## Acceptance checklist
- [ ] Title + close, rows with avatar, name, @username, pill (Following outlined / Follow green).
- [ ] Own row shows Remove (danger) and opens the confirm.
- [ ] Follow updates in place and rolls back on error.
