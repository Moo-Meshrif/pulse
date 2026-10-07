# Plan: onboarding
Source specs: docs/specs/onboarding/, docs/specs/_theme/
Status: approved

## Summary
- **Screens:** S1, S2 and S3 (spec 1.1 to 1.3). They are three pages of one swipeable onboarding flow on a shared scaffold: top bar, 420-high illustration panel, text block and footer.
- **Goals:**
  - Pixel-match the screenshots in `docs/specs/onboarding/screenshots/` at 390 x 844.
  - Light theme.
  - EN and AR, with LTR and RTL handled as `_theme/rtl.md` specifies.
  - "Seen onboarding" persists, so the flow shows only once.
- **Out of scope:**
  - Sign in (1.4) and Registration (2.1) screens. Only their routes are wired, as placeholders.
  - Dark mode.
  - Every other app screen.
- **Architecture:** not defined here. The project has no conventions yet (only the template `lib/main.dart` and no CLAUDE.md), so **flutter-app-builder sets them**. It chooses folders, state management, DI and routing style. This plan names only the files the specs name.

## Reuse
| Existing | Use |
|---|---|
| `assets/icons/ic_arrow_back.svg`, `ic_arrow_forward.svg` | Back button and Next arrow, recolored with `ColorFilter.mode(..., BlendMode.srcIn)` |
| `assets/icons/logo.svg` | S1 logo mark, clipped with radius 8 |
| Nothing else | No theme, widgets, routing, DI or l10n exist yet |

## Blockers
| # | Item | Blocks phase | Needed from | Status |
|---|---|---|---|---|
| B1 (resolved in Phase 8) | Illustration PNGs (EN and AR, 3 each): delivered at the placeholder paths, 350 x 420 with 2x/3x, background and corners included | None. Panels show only their fill until the files arrive. Blocks final visual sign-off in Phase 8 | User | open; placeholder paths in `assets.md` |
| B2 (resolved) | Font files: all delivered and declared (Sora 600/700, Noto Sans 400-700, Noto Sans Arabic 400-700) | None. Text falls back to the platform font until the files arrive. Blocks final visual sign-off in Phase 8 | User, or user approval for the builder to download them from Google Fonts | open |
| B3 | Arabic copy review: the builder translates the English strings and tags them `@review` | Release, not build | User | open |
| B4 | "Sign in" link pressed state (proposal: platform ripple/opacity only) | None, uses the proposal | User | open |

## Phases

### Phase 0: Prerequisites
**Status:** [x]
- **Goal:** make the project ready for assets, fonts, SVG, persistence and localization. The app must still compile.
- **Depends on:** nothing.
- **Spec refs:** `onboarding/assets.md` (pubspec section), `_theme/icons-and-assets.md`, `_theme/typography.md`, `onboarding/00-overview.md`.
- **Tasks:**
  - [x] Add dependencies: SVG rendering (e.g. `flutter_svg`), `shared_preferences`, and `flutter_localizations` with `intl` for gen-l10n.
  - [x] Register `assets/icons/`, `assets/images/onboarding/en/` and `assets/images/onboarding/ar/` in `pubspec.yaml`. Create the image folders now, empty, with a `.gitkeep`.
  - [x] Create `assets/fonts/` and add the `fonts:` declarations for Sora (600, 700), Noto Sans (400, 500, 600, 700) and Noto Sans Arabic (400, 500, 600, 700). Comment them out, or leave them inert, until B2 lands, so the build doesn't fail on missing files.
  - [x] Set up gen-l10n (`l10n.yaml`, `app_en.arb` as the template, `app_ar.arb`) with supported locales `en` and `ar`. Add the onboarding strings to `app_en.arb` verbatim from `screens/*.md`.
  - [x] Let flutter-app-builder set up the base project structure, replacing the template counter app in `lib/main.dart`.
- **Out of scope:** tokens, widgets, Arabic translations.
- **Done when:**
  - `flutter pub get` and `flutter analyze` are clean.
  - The app launches to an empty placeholder home.
  - The generated localizations compile.
- **Verify:** run the app; run `flutter analyze`.

### Phase 1: Theme and tokens
**Status:** [x]
- **Goal:** create the kit files from the specs and a light `ThemeData`.
- **Depends on:** Phase 0.
- **Spec refs:** `_theme/theme-overview.md`, `_theme/colors.md`, `_theme/typography.md`, `_theme/spacing-radius-shadows.md`, `_theme/rtl.md` (Arabic type), `onboarding/01-design-tokens.md`, `onboarding/assets.md`.
- **Tasks:**
  - [x] `lib/core/theme/app_colors.dart`: every token in `colors.md`, including the overlays and the 7 avatar colors.
  - [x] `app_text_styles.dart`: every style in `typography.md`, including the new `subtitle` (Noto Sans 15/400/1.55). Arabic variants follow `rtl.md`: Noto Sans Arabic, same size and weight, letterSpacing 0, line height +0.1 (onboardingTitle 1.3, subtitle 1.65).
  - [x] `app_dimens.dart`: the spacing scale, radii, shadows ("Onboarding cards" 0 12 30 #161A19 10-14%), and the onboarding values from `01-design-tokens.md` (panel 420/32/margin 20, dots 24x8 and 8x8 with gap 6, button 56/28, Next padding 28, gaps 8/8/24/8).
  - [x] `app_assets.dart`: icon paths, plus locale-aware illustration paths (e.g. `onboarding1(locale)`) using the placeholder paths in `assets.md`. Keep them in one place, because the user will edit them.
  - [x] Light `ThemeData`: scaffold background `background`, and tokens exposed through a `ThemeExtension` so a dark set can be added later.
- **Out of scope:** dark tokens, widgets.
- **Done when:**
  - Every token in the `_theme` tables exists in code with the exact value. Spot-check primary #2E6B63, switchOff #C9D3D0, onboardingTitle Sora 28/700/-0.6/1.2, subtitle 15/400/1.55.
  - Arabic style variants have letterSpacing 0.
- **Verify:** `flutter analyze`; review the values against the spec tables.

### Phase 2: Shared components
**Status:** [x]
- **Goal:** build the six onboarding components and a direction-aware icon helper.
- **Depends on:** Phase 1.
- **Spec refs:** `onboarding/02-components.md`, `onboarding/01-design-tokens.md`, `_theme/rtl.md` (Mirrors / Does NOT mirror), `_theme/icons-and-assets.md`.
- **Tasks:**
  - [x] Directional SVG icon helper: flips only directional icons in RTL (`Transform.flip(flipX: isRtl)`) and never flips the logo mark.
  - [x] `OnboardingTopBar`, with padding 16/12/0/20 (directional) and three variants:
    - logo mark 26 (logo.svg clipped r8) + 8 + "pulse" Sora 20/700/-0.5, with Skip
    - back 44 (icon 24) with Skip
    - back only

    Skip is 15/600 `textSecondary` with a 44 hit height.
  - [x] `OnboardingPanel`: margin 20/20/0, height 420, radius 32, clipped, fill from a parameter. It shows the PNG with `BoxFit.cover` and falls back to the bare fill when the asset is missing (B1). It is excluded from semantics.
  - [x] `OnboardingTextBlock`: padding 32/24/0, title `onboardingTitle` `textPrimary`, gap 12, body `subtitle` `textSecondary`, start-aligned.
  - [x] `PageDots`: 3 dots, gap 6. Active is 24x8 `primary`, the others 8x8 `switchOff`, all radius 4. Width and color animate over 250 ms ease-in-out. Semantics: "Page N of 3".
  - [x] `PrimaryButton`: height 56, radius 28, `primary` fill, `primaryPressed` when pressed, label `button` in `textOnPrimary`.
    - Next variant: padding 0 28, label + 8 + `ic_arrow_forward` 20, white, flips in RTL.
    - Full-width variant: label only.
  - [x] `SignInLink`: centered 44-high row, "I already have an account " (`subtitle`, `textSecondary`) + "Sign in" (bold, `primary`). The whole row is the hit area. Pressed state per B4's proposal.
- **Out of scope:** page logic, navigation, persistence.
- **Done when:** each component renders in isolation with the exact spec values, in LTR and RTL. In RTL the logo mark is not flipped and the arrows are.
- **Verify:** a temporary preview screen or hot-reload check against the screenshots, in both directions.

### Phase 3: Onboarding shell (shared scaffold + PageView)
**Status:** [x]
- **Goal:** one onboarding screen hosting a 3-page `PageView`, with a top bar and footer driven by the current page.
- **Depends on:** Phase 2.
- **Spec refs:** `onboarding/00-overview.md` (Structure, Navigation map), `screens/s1-onboarding-1.md` (Responsive), `_theme/theme-overview.md` (SafeArea).
- **Tasks:**
  - [x] Screen: `background` color, wrapped in `SafeArea`. Column of top bar, PageView (panel + text block per page), spacer, footer with padding 0/24/36.
  - [x] Page index state (state solution per flutter-app-builder). The dots follow swipes, and swipe order reverses in RTL.
  - [x] Footer layouts:
    - pages 1-2: dots at start, Next at end
    - page 3: dots centered, 24, Get started full width, 8, SignInLink
  - [x] Top bar variant per page: S1 logo + Skip, S2 back + Skip, S3 back only.
  - [x] Page slide animates over 250 ms ease-in-out on Next and Back. Back on S2 and S3 goes to the previous page.
  - [x] Content scrolls instead of overflowing on screens shorter than 844.
  - [x] Page content (fill, image path, title and body keys) comes from one data list, not three copies of the layout.
- **Out of scope:** final per-screen pixel checks (Phases 4-6), routes out of onboarding, persistence.
- **Done when:**
  - All three pages swipe, Next and Back move between pages, and the dots animate.
  - No overflow at 390 x 844 or on a 360 x 640 screen.
- **Verify:** run on a 390 x 844 device or emulator; swipe and tap through.

### Phase 4: Screen S1 (Onboarding 1)
**Status:** [x]
- **Goal:** S1 matches `screenshots/s1-onboarding-1.png`.
- **Depends on:** Phase 3. B1 and B2 are needed for full visual sign-off only.
- **Spec refs:** `screens/s1-onboarding-1.md`.
- **Tasks:**
  - [x] Panel fill `primarySoft`, illustration `onboarding1(locale)`.
  - [x] Title "Share the moments that move you", body "Post photos and stories from your day, and see what your friends are up to.", both from l10n keys.
  - [x] No back button. System back exits the app.
- **Out of scope:** Skip navigation target (Phase 7).
- **Done when** (S1 acceptance checklist):
  - [x] Background #F3F4F3. Panel #E2EEEB, r32, 20 side margins.
  - [x] Logo mark rounded (r8) at 26, "pulse" in Sora bold dark. Skip at the right, grey semibold.
  - [x] Title wraps in 2 lines exactly: "Share the moments that / move you".
  - [x] Body is grey on 2 lines: "...and see / what your friends are up to."
  - [x] Dots: long green pill first, then two small grey dots. Next is a green pill, 56 high, with a white arrow.
  - [x] Next goes to S2. There is no back button.
- **Verify:** compare side by side with the screenshot at 390 x 844.
- **Result:** compared with real Sora/Noto Sans loaded in a throwaway golden test (illustration PNG missing, so the panel shows only its fill). Positions match the screenshot within 1 dp. Fixed along the way: panel top margin (20, was 0), text styles now `inherit: false` (Material's ambient letter spacing was widening the body), Skip padding 10.

### Phase 5: Screen S2 (Onboarding 2)
**Status:** [x]
- **Goal:** S2 matches `screenshots/s2-onboarding-2.png`.
- **Depends on:** Phase 3.
- **Spec refs:** `screens/s2-onboarding-2.md`.
- **Tasks:**
  - [x] Panel fill `textPrimary` (dark), illustration `onboarding2(locale)`.
  - [x] Title "Swipe through short videos", body "Quick, full-screen clips from creators you follow and new ones picked for you."
- **Out of scope:** Skip navigation target (Phase 7).
- **Done when** (S2 acceptance checklist):
  - [x] The back arrow, not the logo, sits at the leading edge. Skip stays at the trailing edge.
  - [x] The panel is near-black #161A19, with the same size and radius as S1.
  - [x] Title wraps "Swipe through short / videos". Body is 2 lines.
  - [x] The second dot is the long pill.
  - [x] Back goes to S1 and Next goes to S3.
- **Verify:** compare with the screenshot at 390 x 844.
- **Result:** compared with real fonts in a throwaway golden test (illustration PNG missing: the panel shows only its #161A19 fill). Panel, title lines (285 + 94 dp) and body lines (333 + 206 dp) match; positions within 1 dp. Fixed: with the back arrow the top bar's leading padding is 8, not 20 (the arrow sat 11 dp too far in).

### Phase 6: Screen S3 (Onboarding 3)
**Status:** [x]
- **Goal:** S3 matches `screenshots/s3-onboarding-3.png`.
- **Depends on:** Phase 3.
- **Spec refs:** `screens/s3-onboarding-3.md`.
- **Tasks:**
  - [x] Panel fill `primarySoft`, illustration `onboarding3(locale)`.
  - [x] Title "Stay close with chat", body "Message friends one on one or in groups. Send photos, shorts and voice notes."
  - [x] Footer: centered dots, Get started, SignInLink.
- **Out of scope:** the Get started and Sign in targets (Phase 7).
- **Done when** (S3 acceptance checklist):
  - [x] The header shows only the back arrow.
  - [x] Dots are centered above the button, and the third is the pill.
  - [x] "Get started" is a full-width pill with no arrow. The link row below it has a bold green "Sign in".
  - [x] The title is one line, and the body starts higher than on S1 and S2.
  - [x] Back goes to S2.
- **Verify:** compare with the screenshot at 390 x 844.
- **Result:** compared with real fonts in a throwaway golden test (illustration PNG missing: the panel shows only its fill). Title (1 line), body lines, button width (342), link text and horizontal positions match; vertical positions within ~1 dp after a footer fix: the screenshot's last-page footer is not the specced 24 / 8 / 36 but dots-to-button 20, button-to-link 15, bottom padding 27 (measured, [seen]; please confirm).

### Phase 7: Integration (navigation, persistence, l10n, start-up)
**Status:** [x]
- **Goal:** wire the flow into the app.
- **Depends on:** Phases 4-6. B3 is needed for release only.
- **Spec refs:** `onboarding/00-overview.md` (Navigation map), `onboarding/open-questions.md` (Resolved), `_theme/rtl.md`.
- **Tasks:**
  - [x] Placeholder routes for Sign in (1.4) and Registration step 1 (2.1). They are outside this feature, so routes only.
  - [x] Navigation:
    - Skip on S1 and S2 goes to 1.4.
    - Get started goes to 2.1.
    - "Sign in" goes to 1.4.
  - [x] Persistence: set a `shared_preferences` bool when the flow ends via Skip, Get started or Sign in. On start-up, skip onboarding if it is set.
  - [x] `app_ar.arb`: translate every onboarding string into Arabic, tagging each with `@review` metadata for the user (B3).
  - [x] App locale drives `Directionality` (en is LTR, ar is RTL). Arabic text styles from Phase 1 apply when the locale is `ar`.
- **Out of scope:** language-switch UI (Settings 4.7).
- **Done when:**
  - Every navigation edge in the map works.
  - A relaunch after finishing onboarding skips it.
  - Switching the device language to Arabic shows the Arabic strings in RTL.
- **Verify:** run the app; clear app data to re-test first launch; switch the device locale.
- **Result:** verified with a throwaway widget test (deleted), not on a device: first launch shows onboarding; Skip (S1 and S2), Get started and Sign in each save the flag and go to `/sign-in` or `/register`; a relaunch with the flag starts at `/sign-in`; an Arabic device locale shows the Arabic strings in RTL; an unsupported locale (fr) falls back to English LTR. Bug found and fixed: Flutter's default fallback for an unsupported language was Arabic (first supported locale), so `App` now resolves to English.

### Phase 8: Polish (RTL, accessibility, animation, sizes)
**Status:** [x]
- **Goal:** meet the RTL and accessibility rules and finish visual sign-off.
- **Depends on:** Phase 7. B1 and B2 must be resolved for final sign-off.
- **Spec refs:** `_theme/rtl.md`, `screens/*.md` (Responsive / a11y), `onboarding/02-components.md`.
- **Tasks:**
  - [x] RTL audit:
    - The logo mark and wordmark move to the right unflipped, and the wordmark stays Latin.
    - Skip moves left. The back and Next arrows flip.
    - Dots and swipe order reverse.
    - Arabic titles use letterSpacing 0 and line height 1.3. Body line height is 1.65.
  - [x] Accessibility:
    - Labels are "Back", "Skip" and "Page N of 3".
    - Illustrations are excluded from semantics.
    - All tap targets are at least 44.
    - Text scale 1.5 wraps without clipping.
  - [x] Animations: dots and page slide are 250 ms ease-in-out.
  - [x] Drop in the real PNGs and fonts (B1, B2), uncomment the font declarations, and re-run the three screenshot comparisons.
- **Out of scope:** dark mode.
- **Progress:** done. RTL audit, accessibility and animations verified with widget tests (not run on a device, no screen reader used). With the delivered illustration PNGs and all fonts declared, the three English screens match the screenshots (panel art, wrapping, positions within about 1 dp), and the three Arabic screens render with joined Arabic letters in Noto Sans Arabic, mirrored layout and mirrored art. Both checks used a throwaway golden test (deleted) that loaded the repo's font files. Bugs found and fixed during this phase, both only with the system "reduce motion" setting on: Next did nothing (a zero-duration `animateToPage` does not move the page) and the footer's `AnimatedSize` threw an assertion. `test/core/theme/fonts_test.dart` guards that the font families and weights stay declared.

### Phase 9: Tests (end)
**Status:** [x]
- **Goal:** automated coverage of the flow, as the user chose: one test phase at the end.
- **Depends on:** Phase 8.
- **Spec refs:** all `screens/*.md` acceptance checklists, `onboarding/00-overview.md`, `_theme/rtl.md`.
- **Tasks:**
  - [x] Replace the template `test/widget_test.dart`.
  - [x] Widget tests:
    - The S1/S2/S3 top-bar variants.
    - The active dot index per page.
    - Next, Back and swipe change pages.
    - S3 shows Get started and SignInLink, and S1/S2 do not.
    - Skip, Get started and Sign in fire the correct routes.
    - The "seen" flag is written, and start-up skips onboarding when it is set.
    - RTL: the arrows are flipped and the logo is not. The Arabic title style has letterSpacing 0.
    - Text scale 1.5 causes no overflow.
- **Out of scope:** golden/screenshot tests (not requested).
- **Done when:** `flutter test` is green.
- **Verify:** `flutter test`.
- **Result:** 36 tests, all green, in `test/features/onboarding/` (datasource, view, app-level flow) with shared helpers in `test/helpers/pump_app.dart`. Mutation spot-check: breaking the arrow flip, the Skip target and the Arabic letter spacing each made tests fail. No golden tests (not requested); the real-asset screenshot comparison is Phase 8.


## Verification
| Phase | Check |
|---|---|
| 0 | `flutter pub get`, `flutter analyze` clean; app launches |
| 1 | Token values reviewed against the `_theme` tables |
| 2 | Components previewed in LTR and RTL |
| 3 | Swipe, Next and Back work; no overflow at 390x844 and 360x640 |
| 4-6 | Side by side with `docs/specs/onboarding/screenshots/s{1,2,3}-onboarding-{1,2,3}.png` at 390x844; acceptance checklist ticked |
| 7 | All navigation edges; relaunch skips onboarding; Arabic locale shows RTL |
| 8 | Full checklists with real assets and fonts in EN and AR; a11y pass |
| 9 | `flutter test` green |
