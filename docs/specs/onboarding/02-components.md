# Onboarding: components

## OnboardingTopBar
- Padding `16 12 0 20` (top, right, bottom=0, left) [user] for the logo variant. With the back arrow the left padding is 8: the 44 box starts at x=8 and the icon sits at x=18, as in the S2/S3 screenshots and the spec rule "8 on the back-arrow side" [seen].
- S1: logo mark (26) + gap + wordmark "pulse" (Sora 20, textPrimary) on the leading side; "Skip" on the trailing side [user, seen].
- S2: back arrow button 44x44 (`ic_arrow_back`, textPrimary) leading; "Skip" trailing.
- S3: back arrow only; no Skip.
- Logo mark: `assets/icons/logo.svg` clipped with radius 8 [user]. Gap mark-to-wordmark 8; wordmark letter spacing -0.5 [user, accepted default]. In RTL the mark + wordmark move to the right as a unit; the mark is never flipped and the wordmark stays Latin (`../_theme/rtl.md`) [user].
- The back arrow and the Next arrow flip in RTL [user].
- Skip: 44 high, horizontal padding 10 (same as the registration Skip, `padding 0 10`); this puts its text's right edge at 368 dp, matching the S1 screenshot (367) [seen].

## OnboardingPanel
Container margin `20 20 0` (CSS shorthand: top 20, left/right 20, bottom 0), height 420, radius 32, fill per screen, clipped. Contents = exported illustration asset (see assets.md) [user]. Cards inside use shadow "Onboarding cards" (baked into the asset if exported).

## OnboardingTextBlock
Padding `32 24 0`. Title (onboardingTitle), 12 gap, body (`subtitle`: Noto Sans 15/400, lh 1.55, textSecondary). Left aligned (start). Title wraps to 2 lines (S1, S2) or 1 line (S3); block top is fixed, so S3 body sits higher [seen].

## PageDots
3 dots, gap 6. Active: 24x8 primary; others 8x8 switchOff; radius 4. Active width/position animates on page change; 250 ms ease-in-out, same as the page slide [user, accepted default].
Position: S1/S2 leading side of footer row; S3 centered above the button.

## PrimaryButton (Next / Get started)
Height 56, radius 28, fill primary (pressed primaryPressed), label `button` style (Noto Sans 16/700) textOnPrimary. Next: padding 0 28, label + `ic_arrow_forward` 20 (white, gap 8 [user, accepted default]). Get started: full width, label only.

## SignInLink (S3)
One 44-high, centered row: "I already have an account " (`subtitle` 15/400, textSecondary [seen]) + "Sign in" (bold, primary [seen]). On the last page the footer gaps follow the S3 screenshot [seen, +-1 dp], replacing the earlier unconfirmed defaults (24 / 8 / bottom 36): dots -> Get started 20, Get started -> this row 15, footer bottom padding 27. Tap target: the "Sign in" span, with the whole 44 row as its hit area [user].
