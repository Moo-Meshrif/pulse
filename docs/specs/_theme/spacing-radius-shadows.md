# Spacing, radius, shadows [user]

## Spacing scale (dp)
4, 8, 12, 14, 16, 20, 24, 32

| Use | Value |
|---|---|
| Screen header side padding | 16 (8 on the back-arrow side) |
| Card outer margin | 12 |
| Card inner padding | 12-16 |
| Form side padding (auth/registration) | 24 |
| Field gap | 14 |
| Label -> input gap | 6 |
| Section header margin | 22 top, 24 sides, 8 bottom |

## Radius
| Element | Radius |
|---|---|
| Input | 14 |
| Post media / thumbnails | 16 (profile grid 10, create thumbs 14) |
| Settings icon tile | 12 (36x36) |
| Card / list group | 22 |
| Bottom sheet top | 28 |
| Onboarding panel | 32 |
| Pills, chips, buttons, switches | fully rounded (height / 2) |

## Shadows
| Element | Shadow |
|---|---|
| Bottom bar | 0 12 32 #161A19 16% + inner top highlight white 95% (`AppShadows.navBar`) |
| Active tab circle | 0 0 8 #161A19 12%, equal on all sides and fading out inside the 12 dp gap to the bar's edge (`AppShadows.navActiveTab`), white 85% fill, inner highlight and a 1 px #161A19 8% ring (the original 0 3 10 12% was replaced after the device check; being tested) |
| Bottom sheet | 0 -10 40 #161A19 18% (`AppShadows.bottomSheet`) |
| Onboarding cards | 0 12 30 #161A19 10-14% |
| Selected segment | 0 1 3 #161A19 12% |
| Story location sticker | 0 6 16 black 25% (`AppShadows.sticker`) |
| Story text overlay | 0 2 12 black 35% (`AppShadows.textOverlay`) |

## Story dimensions
Scaled getters in `app_dimens.dart` (tap targets fixed): `StoryDimens` (rail, bars, header, reply bar, sticker, viewers sheet), `StoryCameraDimens` (camera, recording, edit tools, bottom actions), `StorySheetDimens` (options sheet, paused chip, delete dialog), `StoryPermissionDimens`. Alphas: `StoryOpacity`. Durations and limits: `StoryTiming`, `StoryMotion`; gesture thresholds: `StoryGestures`. Values: `docs/specs/story/source-tokens.md`.

## Breakpoints
`[unknown]` (design is phone 390 wide only).
