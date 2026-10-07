# RTL (Arabic) [user]

Source: "Pulse — Design Spec (Flutter)" §4 RTL plus the user's answer during spec-to-plan. Applies to every feature.

Wrap the app in `Directionality` from the locale. Use `EdgeInsetsDirectional`, `AlignmentDirectional` and `start`/`end` everywhere so the layout mirrors by itself.

## Mirrors
- **Whole layout:**
  - The logo and wordmark move to the right as a unit.
  - Skip, close and other actions move to the left.
  - List chevrons point left.
  - The text-field "@" prefix and trailing icons swap sides.
- **Directional icons only:** back, forward, chevron right and down-right, the Next arrow, and share (paper plane). Use `Icon(..., textDirection)` or `Transform.flip(flipX: isRtl)` on the SVG.
- **Swipe and paging order:**
  - the onboarding PageView
  - story rows
  - horizontal chip rows
  - registration progress, which fills right to left
- **Bottom bar order:** Home ends up on the right and Profile on the left.

## Does NOT mirror
- **The logo mark** (pulse wave), the app icon, and the "pulse" wordmark. The drawing is never flipped, and the wordmark stays in Latin letters. It only changes position.
- **Media:** play, the video progress bar and scrubber, mute, the sound disc and time chips. Media timelines stay left-to-right.
- **Icons with no direction:** heart, comment, bookmark, bell, search, plus, check, close, verified, camera, lock, globe and settings sliders.
- **Forced LTR text:** numbers, phone numbers, the verification code boxes, @usernames, #hashtags and URLs. Set `TextDirection.ltr` on these.

## Arabic type
| Latin style | Arabic replacement |
|---|---|
| Sora 700 (display, titles, logo text, stats) | Noto Sans Arabic 700, same size, **letterSpacing 0** |
| Noto Sans 400-700 (body, labels, buttons) | Noto Sans Arabic, same weight |

- Never use negative letter spacing on Arabic, because it breaks the letter joins.
- Raise line height by about +0.1 for Arabic: 1.5 becomes 1.6, 1.55 becomes 1.65, and 1.2 becomes 1.3 for titles.
- UPPERCASE section headers become plain Arabic headers, since Arabic has no letter case.
