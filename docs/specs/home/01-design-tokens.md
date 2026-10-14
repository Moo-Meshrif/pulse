# Home: design tokens (deltas only)

Existing theme is reused (`../_theme/*`). Only new / differing tokens. Exact values from `source-tokens.md` [user] unless marked.

## Colors
| Token | Value | Status | Source |
|---|---|---|---|
| storyRing (= source "avatarRing") | #9DBDB7 | exists in colors.md, **reuse; do not add `avatarRing`** | [user] |
| glassFill | #FFFFFF @ 55% (0x8CFFFFFF) | [new] control page | [user] |
| glassBorder | #FFFFFF @ 80% (0xCCFFFFFF) | [new] control page | [user] |
| mediaChip | #161A19 @ 55% (0x8C161A19) | [new] counter / mute / duration chips | [user] |
| seenRing | `border` #D5DAD8 | reuse | [estimated, confirmed user] |
Reused: primary #2E6B63, background #F3F4F3, surface #FFFFFF, textPrimary #161A19, textSecondary #5B6461, iconInactive #3D4644, border #D5DAD8, primarySoft #E2EEEB, like #E0323C, scrim.

## Typography (existing styles; names per typography.md)
| Use | Style | Status |
|---|---|---|
| Wordmark "pulse" | `logo` Sora 24/700 ls -0.5 | reuse |
| ~~Section "Stories"~~ | removed [user, 2026-10-15]: the rail has no title | - |
| Story label | `caption` 12/400 textSecondary | reuse |
| Post name | `name` 15/700 | reuse |
| Meta "{city} · {time}" | `caption` 12/400 textSecondary | reuse |
| Caption | `bodySm` 14/400 h1.45 | reuse |
| "more" / "less" | 14/600 textSecondary | [new] weight variant [user] |
| Counts | `label` 13/600 | reuse |
| Empty title | Sora 18/700 (`stat`) | reuse |
| Empty body | 14 textSecondary | reuse |
| Status / footer text | 13/400 textSecondary ("You're all caught up", "Couldn't load more") ; Retry 13/600 primary | [user] |
| Media chips | 12/600 white | [user] |

Post card, media, action bar, chips and heart tokens moved to `../post/01-design-tokens.md` (post feature owns them) [user]; the rows below are kept for the list only.

## Dimensions (`FeedDimens`, scaled with AppScale except tap targets) [user]
| Token | Value |
|---|---|
| header padding | 8 16 8 16 (+ status bar inset) [user, 2026-10-15: top 20 -> 8, the logo row sat too far below the status bar] |
| logo tile | 28, radius 9 |
| header action button | 44 circle, icon 24, gap 4 |
| bell dot | 9, #E0323C, border 2 `background`; top 9, end 10 inside the 44 button |
| story row padding | 4 16 12 16, item gap 14 (`storyGap`) |
| story avatar / ring | 64 / 2.5 `primary` (unseen), inner padding 3; label gap 6, width 64, 1 line |
| "Your story" | 64 circle, `primarySoft` fill, dashed 2 `primary`, plus icon 24 stroke 2 |
| list padding | 4 12 0 12, card gap 12 |
| card | `surface`, radius 22, padding 12 12 6 12, no shadow |
| author row | gap 10; avatar 40 + ring (2 `surface` gap + 2 `storyRing`) |
| caption margin | 10 2 10 2 (caption only, no media: 10 2 4 2) |
| media | width = card inner (342 at 390), radius 16, aspect from item 0 clamped 4:5 … 1.91:1 |
| action bar | padding-top 4, gap 4, height 44 |
| like / comment | min 44 x 44, padding 0 8, radius 22, icon 24 stroke 1.8, count 13/600, gap 6 |
| share / save | 44 circle, icons 23 / 22 |
| page dots | 6 x 6, gap 4, active `primary`, inactive `border` |
| counter chip | top-end, 12/600 white on mediaChip, radius 10, padding 4 8 [user] |
| mute toggle / duration chip | 32 circle bottom-end, mediaChip, icon 16 white; duration chip bottom-start same style [user] |
| double-tap heart | 80 white @ 90%, pop 0.6 → 1.1 → 1 (~200 ms) then fade 600 ms, likes only [user] |
| bottom clearance | 104 + viewPadding.bottom |

## Loading (board `screenshots/page-loading.png`) [user]
| Where | Widget | Size | Notes |
|---|---|---|---|
| First load (feed) | Skeletonizer shimmer | feed-shaped | blocks #E6E9E7, highlight #F1F3F2, 1.4 s, 200 ms cross-fade |
| Sub-page first load (no label) | PulseLoader | 88 wide, stroke 2.6 | centered in content |
| Pull to refresh | PulseLoader | 56 wide, stroke 2.2 | in a 64 band under the header; content keeps its place |
| Load more | PulseLoader | 44 wide, stroke 2 | in a 72 band above the nav |
| Blocking save | PulseLoader + label | 140 wide, stroke 3 | frosted overlay: `background` @ 72%, blur 20; label Sora 17/600, 18 below ("Saving…"); not used by Home |
Colors: shimmer #E6E9E7 / #F1F3F2 are [new] (skeleton tokens); line color `primary`. The 120-wide first-load loader and "Loading your feed…" text from the token file are **superseded** by the shimmer skeleton.

## Motion
Like pop 1 → 1.2 → 1, 180 ms [user]. Header: floating + snap [user]. (Nav bubble motion belongs to the control page.)
