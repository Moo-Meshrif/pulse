# Onboarding 3 (S3)
Screenshot: ../screenshots/s3-onboarding-3.png  ·  Spec ref 1.3
Purpose / route: last onboarding page; leads to registration or sign in.

## Layout tree
```
Scaffold (bg background) > SafeArea
└─ Column
   ├─ TopBar (padding 16 12 0 20): [Back 44]            (no Skip, no logo)
   ├─ Panel (margin 20 20 0, h420, r32, fill primarySoft): illustration 3
   ├─ TextBlock (padding 32 24 0): title (1 line) / 12 / body (2 lines)
   ├─ Spacer
   └─ Footer (padding 0 24 36), Column, centered:
       ├─ PageDots (centered, active #3)
       ├─ GetStartedButton (full width, h56)         [gap above/below: unknown]
       └─ SignInLink row (h44): "I already have an account " + "Sign in"
```

## Elements
| Element | Text | Size | Color token | Font style | Spacing | Notes |
|---|---|---|---|---|---|---|
| Back | - | 44x44 | textPrimary | - | leading | ic_arrow_back |
| Panel | - | 350 x 420 | primarySoft | - | 20/20/0 | radius 32 |
| Title | "Stay close with chat" | - | textPrimary | onboardingTitle | top 32 | 1 line |
| Body | "Message friends one on one or in groups. Send photos, shorts and voice notes." | - | textSecondary | subtitle (Noto Sans 15/400, lh 1.55) | gap 12 | 2 lines: "...Send / photos, shorts and voice notes." |
| Dots | - | 24x8 / 8x8 | primary / switchOff | - | gap 6 | 3rd active, centered |
| Get started | "Get started" | h56, w342 | primary fill, textOnPrimary | button | side 24 | pill, no arrow |
| Link | "I already have an account " | h44 | textSecondary | subtitle (15/400) | bottom of footer 36 | |
| Link action | "Sign in" | - | primary | Noto Sans 15 bold `[seen]` | inline | |

## States
Get started pressed: primaryPressed. "Sign in" pressed state: open-questions #3.

## Behavior and navigation
Back -> S2. Get started -> Registration step 1 (2.1 Account). "Sign in" -> 1.4. Swipe right -> S2; no further page. [user]

## Data mapping
Static localized strings; Arabic copy: open-questions #2.

## Responsive / a11y
Same as S1 (RTL: back arrow flips; dots centered; link row mirrors). Footer is a column here, so total footer height is dots + button + link + paddings; layout must not overflow on 844 high frames.

## Acceptance checklist
- [ ] Header shows only the back arrow
- [ ] Dots centered above the button, third is the pill
- [ ] "Get started" full-width pill, no arrow; link row below with bold green "Sign in"
- [ ] Title is one line; body begins higher than on S1/S2 (fixed-top text block)
- [ ] Get started -> 2.1; Sign in -> 1.4; Back -> S2
