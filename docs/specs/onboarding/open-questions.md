# Onboarding: open questions

## Resolved [user]
- Body text uses the `subtitle` style (15/400/1.55).
- Illustration text is baked into the PNGs, with separate EN and AR images. The paths are placeholders that the user will edit.
- Until the PNGs and fonts arrive, panels show only their fill color, and the swap is tracked.
- Fonts are bundled in `assets/fonts/`. Noto Sans Arabic weights are 400, 500, 600 and 700.
- Dark mode is out of scope; the app is light only.
- Skip, back, swipe, persistence and the pressed color follow 00-overview.
- RTL follows `../_theme/rtl.md`. The logo mark and media don't mirror, and Arabic titles use letterSpacing 0 with line height +0.1.
- Animation is 250 ms ease-in-out for the dots and the page slide.
- Gaps: logo mark to wordmark 8, Next label to arrow 8. Last-page footer (measured from the S3 screenshot, +-1 dp, [seen]): dots to Get started 20, Get started to the Sign in row 15, footer bottom padding 27 (your spec's 36 matches S1 and S2 but not S3: please confirm).
- The wordmark letter spacing is -0.5.
- "Seen onboarding" is a bool in shared_preferences, set when the flow ends via Skip, Get started or Sign in. Later launches skip onboarding.
- Accessibility:
  - dots are announced as "Page N of 3"
  - back is labeled "Back" and Skip "Skip"
  - text scaling up to 1.5 wraps without clipping
  - the minimum tap target is 44
- System back on S1 exits the app, and the screens are one PageView with shared footer state.
- Kit files (`app_colors.dart`, `app_text_styles.dart`, `app_dimens.dart`, `app_assets.dart`) are created by flutter-app-builder from these specs.
- Localization covers English and Arabic.
- Small items: back icon 24 in a 44 button; content scrolls below 844 high; PNG uses BoxFit.cover; the whole 44 row is the Sign in hit area; illustrations are excluded from semantics.

## Resolved in Phase 8
- All fonts delivered and declared (Sora 600/700, Noto Sans 400-700, Noto Sans Arabic 400-700).
- Illustration PNGs delivered (350 x 420 with 2x/3x variants, panel background and corners included, Arabic set mirrored).

## Still open
1. Arabic copy: the user asked for EN + AR localization without supplying Arabic text. The builder translates the English strings in the specs into Arabic and tags every AR string `@review` in `app_ar.arb`. The user must approve them before release.
2. "Sign in" link pressed state (proposal: no visual change beyond the platform ripple/opacity).
