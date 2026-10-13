# Control page: design tokens (deltas only)
Reuse `../_theme/*`. Values [user] from `../home/source-tokens.md` section 1 unless marked.

## Colors
| Token | Value | Status |
|---|---|---|
| glassFill | #FFFFFF @ 55% (0x8CFFFFFF) | [new] |
| glassFillFlat | #FFFFFF @ 92% | [new] low-tier fallback constant, **not wired** (no detection now) [user] |
| glassBorder | #FFFFFF @ 80% (0xCCFFFFFF) | [new] |
| glassHighlightTop / Bottom | #FFFFFF @ 95% / 35%, 1 px | [new] optional |
| navBubble | #FFFFFF @ 85% | [new] |
| navBubbleRing | #161A19 @ 8%, 1 px all around | [new, added after the device check: on a plain page the bubble and the glass have no contrast and the circle's edge disappeared] |
| iconInactive | #3D4644 | exists |
| like (badge/dot) | #E0323C | exists |
| scrim | #161A19 @ 40% | exists |
Shadows: bar `0 12 32` #161A19 @ 16%; bubble `0 0 8` #161A19 @ 12%, no offset, fading out inside the 12 dp gap to the bar's edge [user: replaces the original `0 3 10` @ 12%, which left the top edge bare; being tested on a device]. Its edge is also the 1 px ring.

## Dimensions (`NavDimens`; scaled with AppScale except tap targets)
| Token | Value |
|---|---|
| position | start 16, end 16, bottom 18 + viewPadding.bottom |
| height / radius / padding | 68 / 34 / 6 |
| blur | `BackdropFilter` sigma 22 (blur only on Flutter) |
| item | flex 1, height 56, gap 4, tap target >= 56 x 56 |
| icon / plus icon | 22 stroke 1.8 / 26 stroke 1.9 |
| bubble | 44 circle |
| content clearance | 104 + viewPadding.bottom |
| count badge | min 18 x 18, r9, `like`, text 10/700 white, h-padding 4, border 2 white @ 90%, top 9, start 50% + 3 of the item (RTL: 50% − 3 from the end); "99+" above 99 |
| header dot (Home bell, in home spec) | 9, `like`, border 2 `background` |

## Motion
Bubble slides to the new item 220 ms `Curves.easeOutCubic`; icon cross-fades to filled 150 ms. Nav hide/show slide 200 ms [user]. Pressed item 90% opacity [user]. Haptic `selectionClick` on tab change and "+" (not on re-tap of the active tab) [user].

## Create sheet (S1) [user]
Scrim `scrim`, tap closes. Sheet `surface`, top radius 28, padding 10 16 34 16 [user, Q2], shadow `0 -10 40` @ 18%, grabber 40 x 5 r3 `border`. Title "Create" Sora 20/700 ls -0.3 (`titleSm`). Close 44 circle `background` fill, X 18 stroke 2.4, at the end. Option row: padding 16, r20, `background`, gap 14, chevron 18 `textSecondary`; icon tile 48 r16 `primarySoft`, icon 24 `primary`; title 16/700, subtitle 13/400 `textSecondary`, gap 2; rows gap 10.
