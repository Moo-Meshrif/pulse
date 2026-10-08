# Auth: design tokens (deltas only)

Everything else comes from `../_theme/` and `lib/core/theme/`. Token names below are the existing ones (`colors/primary`, `colors/danger`, `typography/display`...).

## New / differs
| Token | Value | Tag | Notes |
|---|---|---|---|
| colors/dangerSoft | #FBE4E5 | [new] [user] | Leave dialog icon circle fill (danger @ ~12% on white) |
| blur/dialogBackdrop | sigma 12 (x and y) over `scrim` #161A19 @ 40% | [new] [user] | `BackdropFilter` under both dialogs; hides the body |
| dialog/padding | 28 vertical, 24 horizontal; title `titleSm`; body `bodySm` | [seen, shared dialog sheet] | |
| radius/dialog | 28 (= `AppRadius.bottomSheetTop`) | [user] | Dialog card radius |
| shadow/dialog | 0 12 30 #161A19 @ 12% (= `AppShadows.onboardingCards`) | [user] | |
| input vertical padding | 15 (horizontal 16), **no fixed height** | [new] [user] | Gives ~52 dp with 15/22 text |
| radius/logoTile | 14 | [new] [estimated] | Logo tile 48 x 48 |
| tile/icon | 72 x 72, radius 22, `primarySoft`, icon 32 `primary` | [user] | S2 / S4 tile |
| tile/iconDialog | 56 circle, icon 24 | [user] | S9 `primarySoft`, S10 `dangerSoft` |
| progress/segment | height 4, gap 4, full radius, filled `primary`, empty `switchOff` | [user] | 6 segments |
| strength/segment | height 4, gap 6, full radius, empty `switchOff` | [user] | 4 segments |
| strength colors | 1 Weak `danger`, 2 Fair `warning`, 3 Good `primary`, 4 Strong `primary` | [user] | Word style `caption` 13/600 `textSecondary` |
| otp/box | ~50 x 60, gap 8, radius 14, white, digit Sora 24/700 | [estimated] | Filled border `primary` 1.5; focused empty `textPrimary` 2; idle `border` 1; error `danger` 1.5 [user] |
| chip/interest | height 44, h-padding 18, gap 10 x 12, label 15/700 | [user] | Selected `primary` fill, `textOnPrimary`, check 16 + gap 6 |
| chip/gender | height 40, h-padding 18, gap 10, label 15/700 | [user] | Same states |
| chip/segmentedDark | selected fill `textPrimary`, white label 15/700, unselected white + 1px `border` | [seen] | S8 tabs, height ~40 [estimated] |
| avatar/upload | circle 88, dashed 1.5 `dashed`, camera 28 `primary`, badge 28 `primary` + white plus 14 at bottom-end | [estimated] | S6 |
| avatar/list | circle 48, initials 15/700 white, colors from avatar palette | [estimated] | S8 |
| checkbox | 24 square, radius 6; checked `primary` + white `ic_check` 16; unchecked white + 1px `border` | [user] | S3 |
| divider row | lines 1px `divider`, text `bodySm` 14/400 `textSecondary`, gap 12 | [estimated] | "or continue with" |
| input states | focus border `primary` 1.5; error border `danger` 1.5 + message below `caption` 12 `danger` | [user] | |
| button states | disabled = `primary` @ 40% opacity; loading = white 20 px spinner replaces label, taps ignored | [user] | all primary buttons here |
| outline pill button | white, 1px `border`, label 16/700 `textPrimary`, v-padding 15, **no fixed height** | [user] | Google, Apple, Back to sign in (S2) |
| soft pill button | fill `background` (#F3F4F3), label 16/700 `textPrimary`, height 48 | [estimated] | S9 "Back to sign in", S10 "Keep going" |
| danger pill button | fill `danger`, label white 16/700, height 48 | [seen] | S10 "Leave" |

## Reused as-is
`display` (Sora 30/700, -0.6, 1.2) for every screen title [user]; `subtitle` (15/400, 1.55, `textSecondary`) under titles [user]; `label` 13/600 for field labels [estimated, check]; `PrimaryButton` (56 high, pill); form side padding 24; `fieldGap` 14; `labelGap` 6; avatar palette from `colors.md`.
Avatar colors seen: SK #5E4B7A, OH #6B5B2E, LT #8A3B4E, MR #2E6B63, YF #7A4E3A, DN #4F6B4A [seen, match palette]; assignment rule unknown (see open-questions).

## Text scale hints
Required asterisk: `danger`, same style as label. "(optional)" after Gender: label weight 400 `textSecondary` [seen]. Terms/Privacy links: 14/700 `primary`, underlined [user]. Helper text: `caption` 13/400 `textSecondary` [estimated].
