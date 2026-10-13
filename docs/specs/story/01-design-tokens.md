# Story feature: design tokens (deltas only)
**Exact values: `source-tokens.md` (user token file, 2026-10-13) wins over any value below.** Differences found: gallery thumb 44 (not 48); failed upload ring = `warningInk` `#B26F12`, not the error token (supersedes Q8); viewer count chip bottom-start; permission pill `#1B201F` @ 86% (not amber); sheet rows `#2A302F`; success green `#5FD39A`.
Values from the board's token notes [user] unless tagged. Reuse `../_theme/*`.

## Viewer
| Token | Value |
|---|---|
| top shade | black 45% -> 0 over 170 |
| bottom shade | 0 -> black 55% over 200 |
| progress | top 54 + safe area, 3 high, gap 4, track white @35%, fill white @100%; one segment per story of this person |
| header | 48: avatar 36 + 2 white ring, name 15/700 white, time 13 white @80%, "···" and close 44 at the end |
| reply pill | 48, border 1.5 white @70%, text 15 white, like icon 28, send icon 26; keyboard pushes the pill up and pauses the story |
| location sticker | white, radius 12, `primary` text 15/800 UPPERCASE with pin, -4° tilt |
| timings | image 5 s; video = its length (max 60 s) |
| gestures | tap right = next, left = previous, hold = pause (UI fades out), swipe down = close, swipe left = next person, swipe up (own story) = viewers sheet |
| viewers sheet | white sheet, grabber, header "24 viewers" with `ic_eye` + delete (red-tint circle) + save (circle) buttons, rows: avatar, name 15/700, @username 13, red outline heart if they liked it; newest first |

## Camera / edit
| Token | Value |
|---|---|
| shutter | 80: ring 5 white + 64 white dot |
| recording | ring 92, stroke 5, `like` red fills over 60 s; shutter becomes a red stop square 40 r12; timer chip at top (red pill, dot + "0:21") |
| round controls | 48 circle on white @18% (flip camera), gallery thumbnail 48 rounded square |
| tool buttons | 44 circle on black @35%, stacked at the end (Aa text, location sticker, mute (video), save) |
| text overlay | Sora 30/700 white, soft shadow |
| Share pill | 52 high, white, "Share" + chevron; "Your story" pill white @18% with avatar (who will see it) |
| rail upload ring (S4) | 64, stroke 3, `primary` on `border`; failure = `warningInk` `#B26F12` full ring, label "Retry" [source-tokens] |

Colors on dark: white and white @ alpha only; `like` for hearts/recording. Amber `#F2B45A` only in S5 [user]. Dark surfaces: camera context bg `#161A19`, sheet/dialog `#1F2423` [user].
