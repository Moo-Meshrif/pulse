# Onboarding 2 (S2)
Screenshot: ../screenshots/s2-onboarding-2.png  ·  Spec ref 1.2
Purpose / route: second onboarding page.

## Layout tree
```
Scaffold (bg background) > SafeArea
└─ Column
   ├─ TopBar (padding 16 12 0 20): [Back 44 ic_arrow_back] ......... ["Skip"]
   ├─ Panel (margin 20 20 0, h420, r32, fill textPrimary #161A19): illustration 2
   ├─ TextBlock (padding 32 24 0): title (2 lines) / 12 / body (2 lines)
   ├─ Spacer
   └─ Footer (padding 0 24 36): Row[ PageDots (active #2) ........ NextButton ]
```

## Elements
| Element | Text | Size | Color token | Font style | Spacing | Notes |
|---|---|---|---|---|---|---|
| Back | - | 44x44, icon 24 [user] | textPrimary | - | left 20 side | ic_arrow_back |
| Skip | "Skip" | h44 | textSecondary | Noto Sans 15/600 | right 12 | |
| Panel | - | 350 x 420 | textPrimary | - | 20/20/0 | radius 32 |
| Title | "Swipe through short videos" | - | textPrimary | onboardingTitle | top 32 | 2 lines: "Swipe through short / videos" |
| Body | "Quick, full-screen clips from creators you follow and new ones picked for you." | - | textSecondary | subtitle (Noto Sans 15/400, lh 1.55) | gap 12 | 2 lines |
| Dots | - | 24x8 / 8x8 | primary / switchOff | - | gap 6 | 2nd active |
| Next | "Next" + arrow | h56 pad 0 28 | primary | button | right 24, bottom 36 | |

## States
Same as S1.

## Behavior and navigation
Back -> S1. Next -> S3. Skip -> Sign in (1.4). Swipe both ways; dots follow. [user]

## Data mapping
Static localized strings; Arabic copy: open-questions #2.

## Responsive / a11y
Same as S1 (RTL: back arrow moves right and flips; Skip moves left). Dark panel contrast: panel is a fixed dark fill even in light theme [seen].

## Acceptance checklist
- [ ] Back arrow (not logo) at leading edge; Skip still at trailing edge
- [ ] Panel is near-black #161A19, same size/radius as S1
- [ ] Title wraps "Swipe through short / videos"; body 2 lines
- [ ] Second dot is the long pill
- [ ] Back -> S1; Next -> S3; Skip -> Sign in
