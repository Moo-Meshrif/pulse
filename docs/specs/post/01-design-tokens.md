# Post feature: design tokens (deltas only)
Reuse `../_theme/*` and `../home/01-design-tokens.md`. Values measured from `screenshots/s1-new-post.png` (dp = px / 1.846); **all sizes below confirmed by the user** (Q4) except those still tagged otherwise.

## Colors (all existing)
background #F3F4F3 (page), surface (cards), primary #2E6B63 (Share button, Add tile, switch on), primarySoft #E2EEEB (option icon tiles), textPrimary, textSecondary (placeholder, counter, option value), border / divider (chip border, dashed Add border), danger #C42B34 (counter at limit), switchOff #C9D3D0, mediaChip #161A19 @ 55% (duration chip, remove button). Disabled Share = primary at reduced opacity [estimated 40%, same as auth].

## Typography
| Use | Style | Status |
|---|---|---|
| Screen title "New post" | `title`/`titleSm` Sora 700 (screenshot ~22) | [user] 22/700 |
| Author name | `name` 15/700 (shot ~16) | [user] |
| Visibility chip label | 12/600 | [differs] board S4 (was 13/700) |
| Input text and placeholder | Noto Sans 17-18/400, placeholder textSecondary | [user] 17/400 |
| Counter "0/2000" | `caption` 12/400 textSecondary | [user] |
| Section "ADD TO YOUR POST" | `section` 13/700 UPPERCASE ls 0.4 textSecondary | existing |
| Option row title | `body` 15-16/500 | [user] 16/500 |
| Option row value ("2 added", "Kolkata") | 14/400 textSecondary | [user] |
| Allow comments | same as option title | [user] |
| Share post | `button` 16/700 white | existing |
| Duration chip "0:18" | 12/600 white | [user] |

## Dimensions [user]
| Token | Value |
|---|---|
| page padding | 12 horizontal around cards; title row padding 20 start, 20 end |
| title row height | ~56 (title y-center 38 dp) |
| composer card | r22, padding 14 |
| avatar | 44 |
| visibility chip | height 28, r14, padding 10, choice icon 16 + label + `ic_chevron_down` 14; default: 1 px `border`, fill `background`; narrowed: `primarySoft` fill, 1.5 `primary` border, primary ink [S4 board] |
| input | min height ~96 (3 lines), grows with text |
| media thumb | 104 x 104, r16, gap 8 |
| remove button | 28 circle `mediaChip`, X 14 white, top-end inset 6 |
| duration chip | bottom-start inset 6, r12, padding 4 8 |
| add tile | 104 x 104, r16, dashed 2 `border` (#9DBDB7-ish, colour [user]), fill #F8F9F8, "+" 24 primary + "Add" 13/700 primary |
| counter | bottom-end of the card |
| section label margin | 20 start, 12 top, 8 bottom |
| options card | r22, rows 54 high, padding 10 12; icon tile 34, r10, `primarySoft`, icon 18 primary; gap 14; chevron 18 |
| switch | 52 x 32, on = primary, thumb white (use Material `Switch` themed) |
| share button | full width minus 20 each side, height 56, radius pill, bottom 16 + inset |

## Behavior tokens [user]
Caption max 2000 (screenshot). DB limit is 2200: UI is stricter on purpose. Media max 10 items, video up to 10 min, 50 MB per file [user].

Image resize presets [user, 2026-10-14]: one enum, switched by a code flag (no user setting).
| Preset | Longest side | Quality |
|---|---|---|
| standard (default, Instagram-like) | 1080 px | 80 |
| high | 1440 px | 85 |
| max | 2048 px | 85 |

## Post card and options sheet (shared with Home) [user, from `../home/source-tokens.md` section 2.3]
| Token | Value |
|---|---|
| card | `surface`, r22, padding 12 12 6 12, no shadow |
| author row | gap 10; avatar 40; ring 2 `surface` gap + 2 `storyRing` (#9DBDB7) |
| caption margin | 10 2 10 2 (caption only: 10 2 4 2) |
| media | radius 16, aspect clamped 4:5 .. 1.91:1 |
| action bar | height 44, padding-top 4, gap 4; like/comment min 44, r22, icon 24; share 44 icon 23; save 44 icon 22 |
| chips | counter / mute / duration on `mediaChip` #161A19 @ 55%, 12/600 white |
| dots | 6 x 6, gap 4 |
| double-tap heart | 80 white @90%, pop then fade 600 ms |
| Options sheet | see `screens/s2-post-options.md` (shell: surface, top r28, padding 10 16 34, grabber 40 x 5) |

## Add location (S3) [user, from the board's layout note]
| Token | Value |
|---|---|
| header | 56: back, title Sora 20/700, "Remove" 15/700 `danger` |
| search pill | h 48, white, r24, icon 20, clear button 28, focused ring 2 `primary` |
| section label | 13/700 UPPERCASE `textSecondary`, 14 above; rows in white card r22 |
| row | >= 62 high; icon tile 40 r13 (current = `primarySoft`, others = `background`); name 15/600, sub 13 `textSecondary`; selected = `ic_check` 20 `primary` |
| empty icon | 56 |
| loader | `PulseLineLoader` width 44 |
Primer (panel 4): large crosshair icon, title Sora bold, body textSecondary centered, `PrimaryButton` + text button "Not now" [sizes estimated].

## Visibility picker (S4) [seen, board Tokens note]
| Token | Value |
|---|---|
| sheet | Post options shell (white, r28), title Sora 18/700, close circle 40 |
| group | `background`, r18; row min 64, padding 10 16, gap 14 |
| tile | 40 r12, selected `primarySoft`, else white; icon 20 |
| title / sub | 15/700 / 12 `textSecondary` |
| radio | 24; on `primary` + white check; off 2 px #9AA6A2 (`dashed`) |
| disabled | text/icon #9AA6A2, radio border `divider` |
| private note | `warningSoft` fill, `warningText`, r16 |
| toggle | 48 x 28 (S1's comments switch is 52 x 32) |
| Done / Save | 52 primary pill |
| card meta icon | 12 (users / star / lock) for non-public posts |

## Tags, mood and comments-off (boards of 2026-10-15) [seen, board Tokens notes]
Pages (S6-S9) follow Add location: header 56 + back 44 + title Sora 20/700, search 48 r24 white, lists white r22, rows 64, avatar 44.
| Token | Value |
|---|---|
| Done pill | h 36, r18, `primary`, white 14/700 (S6, S7) |
| Remove (S8 header) | 15/700 `danger` |
| selected chip (S6) | h 36, r18, `primarySoft`; avatar 28; name 13/700 `primary`; × 22 white circle |
| counter (S6) | 12 `textSecondary` |
| check (S6) | 24; on = `primary` + white check; off = 2 px #9AA6A2 circle; disabled row = 50% opacity + `ic_block` 12 |
| feeling tile (S8) | h 52, r16, white, emoji 22, word 15/600; selected = `primarySoft` + 1.5 inset `primary` |
| segmented (S8) | h 44, r22, `divider` fill, white thumb |
| activity row (S8) | white card r22, rows 64, emoji tile 44, chevron 18 |
| headline (card) | 14 / h 1.35, max 2 lines; names 700 `textPrimary`; connectors 400 `textSecondary` |
| feeling emoji + label | same 14, `textSecondary` after "is feeling" |
| meta (card) | 12 `textSecondary`, gap 5, "·" separators; location pin 12 + text 600 `primary` |
| audience icon | 12: globe Public, users Followers, star Close friends, lock Only me |
| tag badge | 32 circle, #161A19 @ 55%, `ic_user` 16 white, bottom-start |
| tag label | h 30, r10, #161A19 @ 82%, 13/700 white, 7 px pointer |
| own tag label | white card r12, shadow 0 8 24 @ 25%, name row 34 (avatar 22), action row 38 13/700 `danger` + `ic_user_minus` 16 |
| comments-off icon | `ic_comment_off` 24 at 45%, still a 44 target |
| comments-off line | `ic_comment_off` 14 + 12 `textSecondary`, padding 2 4 6 |
| post page bar | 14/600 `textSecondary` on `surface`, top border `divider`, padding 14 16 34 |
| remove-tag dialog | icon 44 stroke 1.5 `danger`, title Sora 20/700, body 14 `textSecondary`, Remove 52 `danger` pill, Cancel 44 link |
| tagged line (S2) | `ic_user` 16 `primary` + 13 `textSecondary`; "Remove me" row = `primarySoft` fill, icon `primary` |
[user, Q29] S7: thumbs 56 r12, selected = 2 `primary` ring offset 2, count badge 20 `primary` + 11/700 white; info card r18 padding 10 16, `ic_user` 18 `primary`, text 14; hint 14 `textSecondary` padding 0 24. S6: counter 12 `textSecondary`, `danger` at 20 (rows drop to 50%); empty state = existing `AppEmpty` + `ic_search` (no `CompactStateView` / `ic_not_found` in the project); "Tag in photo" button outlined 48, pinned bottom, photos only.
[estimated] S9 (deferred): row 56 / emoji tile 32.
