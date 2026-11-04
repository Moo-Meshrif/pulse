# Profile: design tokens (deltas only)

Base: `docs/specs/_theme/` (colors, typography, spacing-radius-shadows). Colors used and already defined: primary, primarySoft, storyRing (avatar ring), background, surface, surfaceMuted, textPrimary, textSecondary, border, divider, switchOff, dashed (radio off, dashed add), danger, like (badge), online (not used). No new colors found [seen]. Px values below were measured on 2x screenshots and scaled to the 390 frame, so they are `[estimated]` unless tagged.

## Tokens that are new or confirmed
| Token | Value | Source |
|---|---|---|
| profile/cover height | 170 | [user] board |
| profile/avatar size | 96, overlaps cover by 48 | [user] board |
| profile/avatar ring | white 4 + primary 2 on S1 (outer ~96+12); S3 ring storyRing 3 | [estimated] |
| profile/name | Sora 22/700 (title style, letterSpacing -0.4) | [user] board |
| profile/stat card | white, radius 20, height ~68, margin 12 | [user] radius, [estimated] height |
| profile/stat number | Sora 18/700 (`stat`), label caption 13 textSecondary | [seen] |
| profile/stat divider | 1 x ~34, `divider` | [estimated] |
| profile/cover buttons | 44 circles, white @ 88%, top = status + 8, side 12 | [user] board |
| profile/follow buttons | height 44, radius 22, gap 8, 15/700 | [user] board |
| profile/chip "Follows you" | radius 11, `divider` fill, 11/700 | [user] board |
| profile/followed-by | 3 avatars 22 overlap -6, 13 text, bold names | [user] board |
| profile/tab | height ~45, label 15/600 (active textPrimary, inactive textSecondary), underline primary 2 under active | [estimated] |
| profile/grid | 3 columns, gap 4, square, radius 10 (theme) | [seen] gap, [user] radius |
| locked/blocked card | white radius 22, icon 56 stroke 1.4, title Sora 18/700 | [user] board |
| settings/group card | white, radius 22, margin 12, inner padding 8-12 | [user] theme |
| settings/row | min height 56, icon tile 36 radius 12 `primarySoft`, icon 18 primary, title `body` 15/500, value `bodySm` textSecondary, chevron 18 | [seen] + theme |
| settings/switch row | title `body`, subtitle `bodyXs` textSecondary, switch right | [seen] |
| switch | 52 x 32, on = primary track, white thumb 24 with primary ring; off = switchOff track | [estimated] |
| radio | 22 circle, off = `dashed` 2 ring, on = primary ring 2 + dot 12 | [estimated] |
| section label | `section` (13/700 UPPERCASE, 0.4), textSecondary, margin 22 top, 24 sides, 8 bottom | [user] theme |
| input (on white card) | `surfaceMuted` fill, border 1, radius 14, height ~50 | [seen] |
| input (on background, S3) | white fill, border 1, radius 14, height ~52 | [seen] |
| outline pill button | border 1, radius full, height ~36, label 14/700 | [estimated] |
| report chip | height 40, radius full, border 1 white; selected = `textPrimary` fill + white text | [estimated] |
| dashed add tile | 84 x 84, radius 14, dashed `dashed` 1.5, plus + "Add" 13/600 | [estimated] |
| accordion row | height 56, title `body`, chevron 18, open answer `bodySm` textSecondary | [estimated] |
| topic card | 2 per row, radius 22, icon tile 36 radius 12, title 15/600, height ~80 | [estimated] |
| danger text button | white card, radius 22, height 56, label button 16/700 `danger` | [seen] |
