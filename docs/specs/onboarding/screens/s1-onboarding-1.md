# Onboarding 1 (S1)
Screenshot: ../screenshots/s1-onboarding-1.png  ·  Spec ref 1.1
Purpose / route: first onboarding page; entry of the app for new users (route name: chosen by builder; not a design value).

## Layout tree
```
Scaffold (bg colors/background) > SafeArea
└─ Column
   ├─ TopBar (padding 16 12 0 20): [logo mark 26 + "pulse" Sora 20] ......... ["Skip" 15/600 textSecondary, 44h]
   ├─ Panel (margin 20 20 0, h420, r32, fill primarySoft): illustration 1
   ├─ TextBlock (padding 32 24 0): title (2 lines) / 12 / body (2 lines)
   ├─ Spacer
   └─ Footer (padding 0 24 36): Row[ PageDots (active #1) ........ NextButton "Next →" ]
```

## Elements
| Element | Text | Size | Color token | Font style | Spacing | Notes |
|---|---|---|---|---|---|---|
| Logo mark | - | 26 | primary + white line | - | left 20 | logo.svg, clip r8 |
| Wordmark | "pulse" | - | textPrimary | Sora 20 (700) | gap to mark 8 [user]; letter spacing -0.5; never flipped in RTL | |
| Skip | "Skip" | h44 | textSecondary | Noto Sans 15/600 | right 12 | |
| Panel | - | 350 x 420 (390-40) | primarySoft | - | margin 20/20/0 | radius 32 |
| Title | "Share the moments that move you" | - | textPrimary | onboardingTitle | top 32, side 24 | 2 lines |
| Body | "Post photos and stories from your day, and see what your friends are up to." | - | textSecondary | subtitle (Noto Sans 15/400, lh 1.55) | gap 12 | |
| Dots | - | 24x8 / 8x8 | primary / switchOff | - | gap 6 | 1st active |
| Next | "Next" + arrow 20 | h56, pad 0 28 | primary fill, textOnPrimary | button | right 24, bottom 36 | pill |

## States
Default as shown. Next pressed: fill primaryPressed [user]. Disabled/loading: none.

## Behavior and navigation
- Next -> S2. Skip -> Sign in (1.4). Swipe left (LTR) -> S2; dots follow. No back arrow. [user]
- Persist "seen onboarding" (shared_preferences bool) when the flow ends via Skip, Get started or Sign in [user].

## Data mapping
All static localized strings (EN + AR). Arabic copy: open-questions #2.

## Responsive / a11y
- Frame 390 x 844; panel fixed height 420; if screen is shorter, make content scrollable instead of overflowing [user]. Wider phones: panel width fills (margins 20).
- RTL per `../../_theme/rtl.md`: logo mark + wordmark move to the right unflipped; Skip moves left; Next arrow flips; swipe order reverses; Arabic title letterSpacing 0, line height 1.3; body line height 1.65 [user].
- a11y: dots "Page 1 of 3", Skip label "Skip", tap targets >= 44, text scale 1.5 wraps without clipping [user]. Illustrations excluded from semantics (decorative) [user].

## Acceptance checklist
- [ ] Bg #F3F4F3; panel #E2EEEB, r32, 20 side margins, top gap = header bottom
- [ ] Logo mark rounded (r8) 26px, "pulse" Sora bold dark; Skip grey semibold at right
- [ ] Title Sora 28/700 wraps in 2 lines exactly as "Share the moments that / move you"
- [ ] Body grey, 2 lines, "...and see / what your friends are up to."
- [ ] Dots: long green pill first, two small grey; Next pill green 56h with white arrow
- [ ] Next -> S2; Skip -> Sign in; no back button
