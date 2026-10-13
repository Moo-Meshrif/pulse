# Plan: control-page
Source specs: docs/specs/control/, docs/specs/_theme/ (and `docs/specs/home/source-tokens.md` section 1, the raw token source)
Status: approved
Mode: one-by-one
Tests: cubit + widget tests in each phase (mirror `lib/` under `test/`, helpers in `test/helpers/pump_app.dart`)

## Summary
- **Screens:** S0 glass nav bar + shell (`/home`, tabs Home, Shorts, Chat, Profile, plus a Create button), S1 Create sheet.
- **Goal:** replace the `/home` placeholder with the main shell: 4 tabs that keep their state, each with its own Navigator; a floating iOS-style glass nav bar; back and re-tap behavior; the nav hides under the keyboard and on full-screen routes; a hardcoded chat badge; the Create sheet that routes to Post and Short.
- **Out of scope** (00-overview > Scope): the tab pages themselves (Home, Shorts, Chat, Profile show placeholders until their features exist), New post (post feature), New short (shorts feature, later), the real chat unread count, low-tier device detection.
- **Build order** (progress.md): control-page first, then story, post, home.

## Reuse
- Colors already in `AppColors` (`lib/core/theme/app_colors.dart`, documented in `_theme/colors.md` > Overlays & glass): `glassFill` (#FFFFFF 55%), `glassBorder` (#FFFFFF 80%), `glassActive` (#FFFFFF 85%) = the spec's `navBubble`; also `primary`, `primarySoft`, `iconInactive`, `like`, `scrim`, `surface`, `background`, `border`, `textPrimary`, `textSecondary`. Do not add duplicates.
- `AppRadius.bottomSheetTop` (28), `AppRadius.pill`, `AppSpacing`, `AppScale` scaling, `ContentWidth` (`AppBreakpoints.maxContentWidth` 840), `AppSafeArea` (`bottomSpace`), `AppSvgIcon`, `AppText`, `context.text.titleSm`, `context.appColors`, `context.l10n`.
- Icons already in `AppAssets`: `home`/`homeFilled`, `shorts`/`shortsFilled`, `plus`, `chat`/`chatFilled`, `profile`/`profileFilled`, `close`, `chevronRight`. New files to register: `ic_create_post.svg`, `ic_create_short.svg` (present in `assets/icons/`, folder already in `pubspec.yaml`).
- `PlaceholderScreen` (`lib/core/router/placeholder_screen.dart`) for the tab roots and the create routes.
- Bottom-sheet pattern of `PhotoSourceSheet` (`showModalBottomSheet`, `scrim` barrier, top radius 28, `AppSafeArea` inside).
- `AppRouter.onGenerateRoute` (all routes), `AppRoutes`, `AppNavigator`; the root navigator key from DI; `SessionGuard` and `RecoveryLinkHandler` already act on the root Navigator.
- Recovery check: the auth feature's `IsRecoveryPendingUseCase` (the splash uses it, `SplashCubit`).
- `BaseCubit` + `run`, `BlocProvider(create: (_) => getIt<…>())`, injectable.

## Blockers
| Item | Blocks phase | Needed from | Status |
|---|---|---|---|
| Q10 Arabic strings (nav semantics, Create sheet) are drafts | none (ship with drafts tagged `x-review`) | user review | open, no code marker |
| Q3 tab registration API / tab index mapping | none: the builder decides per `.claude/conventions/` (features never imported for data; tab roots are screens) | builder | decided in Phase 4 |

No phase is blocked.

## Code TODOs
| Id | What is pending | Code it sits in | Phase |
|---|---|---|---|
| T1 | Home tab shows a placeholder until the home feature exists (home is built after story and post) | the Home tab root of the shell | 4 |
| T2 | Shorts tab placeholder until the shorts feature is specced | the Shorts tab root | 4 |
| T3 | Chat tab placeholder until the chat feature exists | the Chat tab root | 4 |
| T4 | Profile tab placeholder until the profile screens are specced | the Profile tab root | 4 |
| T5 | Chat unread badge hardcoded to 4; the chat feature must supply the real count | the shell state that feeds the badge | 4 |
| T6 | Re-tap on the Home root must also refresh the feed; only scroll-to-top exists until the home feature lands | the re-tap handling of the shell | 4 |
| T7 | `/create/post` shows a placeholder until the post feature's New post screen is built | the Post route | 5 |
| T8 | `/create/short` shows a placeholder until the shorts feature exists | the Short route | 5 |
| T9 | Flat low-tier fallback fill (#FFFFFF 92%) kept as a constant, not used: no device detection now | the nav bar's glass layer | 3 |
| T10 | Arabic copy review (Q10) | ARB files | no code marker |

Existing markers this plan resolves: `TODO(reset-link)` and `TODO(auth-plan)` on the `/home` route in `lib/core/router/app_router.dart` (Phase 4 removes both; the Home placeholder moves to T1).

## Phases

### Phase 0: Prerequisites
**Status:** [x]
**Goal:** register the new assets and route names so later phases only add widgets.
**Depends on:** nothing.
**Spec refs:** `assets.md`; `00-overview.md` > Navigation map; `screens/s1-create-sheet.md` > Behavior.
**Tasks:**
- [x] Add `ic_create_post.svg` and `ic_create_short.svg` to `AppAssets`.
- [x] Add route names for `/create/post` and `/create/short` to `AppRoutes` (resolved in Phase 5).
- [x] `fvm flutter analyze` clean.
**Out of scope:** widgets, routes resolution.
**Done when:** analyzer passes; both icons render through `AppSvgIcon` (quick check).
**Verify:** `fvm flutter analyze`.

### Phase 1: Theme and tokens
**Status:** [x]
**Goal:** every nav and sheet value from `01-design-tokens.md` exists as a token, scaled like the rest of the theme.
**Depends on:** Phase 0.
**Spec refs:** `01-design-tokens.md` (Colors, Dimensions, Motion, Create sheet); `_theme/colors.md` > Overlays & glass; `_theme/spacing-radius-shadows.md` (Bottom bar shadow); `_theme/theme-overview.md`.
**Tasks:**
- [x] Reuse `glassFill`, `glassBorder`, `glassActive`; add only what is missing: flat fallback fill #FFFFFF 92% (T9), inner highlight top #FFFFFF 95% and bottom #FFFFFF 35% (1 px).
- [x] Shadows: bar `0 12 32` #161A19 16%; bubble `0 3 10` #161A19 12%; sheet `0 -10 40` 18%.
- [x] Nav dimensions (scaled with AppScale except tap targets): side insets 16/16, bottom 18 (+ `viewPadding.bottom`), height 68, radius 34, padding 6, item height 56, item gap 4, bubble 44, icon 22, plus 26, blur sigma 22, content clearance 104 (+ `viewPadding.bottom`), badge min 18, badge radius 9, badge border 2 (#FFFFFF 90%), badge padding 4, badge anchor top 9 / start 50% + 3.
- [x] Motion: bubble 220 ms `Curves.easeOutCubic`, icon cross-fade 150 ms, nav hide/show 200 ms, pressed opacity 90%.
- [x] Create sheet: padding 10 16 34 16, grabber 40 x 5 r3 `border`, close 44 with X 18, row padding 16 r20 on `background`, row gap 10, content gap 14, icon tile 48 r16 `primarySoft`, icon 24, chevron 18, title 16/700, subtitle 13/400 `textSecondary` (gap 2), title `titleSm`. Check `context.text` already has 16/700 and 13/400 styles; add only what is missing (all `AppTextStyles` stay `inherit: false`).
- [x] Badge text style 10/700 white (check the existing `badge` style in `_theme/typography.md` first).
- [x] If a sheet shadow or token is added to the theme, document it in `docs/specs/_theme/` (colors / spacing-radius-shadows).
**Out of scope:** widgets.
**Done when:** every value above is reachable from code by token name; no raw hex or magic numbers needed in later phases; analyzer clean.
**Verify:** `fvm flutter analyze`; review the token diff against `01-design-tokens.md`.

### Phase 2: Shared bottom-sheet shell
**Status:** [x]
**Goal:** one bottom-sheet shell in `lib/core/widgets/` used by the Create sheet now and the post options sheet later (two features, so it is shared).
**Depends on:** Phase 1.
**Spec refs:** `02-components.md` (Reuse line); `01-design-tokens.md` > Create sheet; `screens/s1-create-sheet.md` > Layout tree, Responsive / a11y; `docs/specs/post/screens/s2-post-options.md` > Layout tree (same shell, padding 34).
**Tasks:**
- [x] Sheet shell: `surface`, top radius 28, shadow, grabber 40 x 5, padding 10 16 34 16, `scrim` barrier (tap closes), drag down closes, system back closes; content wrapped in `AppSafeArea` with `bottomSpace` = the sheet's bottom padding.
- [x] Optional title row: title (`titleSm`) at the start and a 44 close circle (`background` fill, X 18) at the end; close has a Semantics label ("Close", new l10n key with the Arabic draft from the spec).
- [x] Capped at the shared max width and centered on wide screens (`ContentWidth`).
- [x] RTL: close at the end (left in AR).
- [x] Add it to the `widgets.dart` barrel.
- [x] Tests: opens with title and close; scrim tap, close button and back dismiss it; RTL puts close on the left.
**Out of scope:** the Create sheet content; migrating `PhotoSourceSheet` or `CountryCodeSheet` (not specced).
**Done when:** the shell matches the sheet part of `screenshots/s1-create-sheet.png` with placeholder content; tests pass.
**Verify:** widget tests; temporary visual check against `screenshots/s1-create-sheet.png`.

### Phase 3: S0 glass nav bar (widget)
**Status:** [x]
**Goal:** the floating glass nav bar as a self-contained widget driven by inputs (selected tab, badge count, callbacks), no shell logic yet.
**Depends on:** Phase 1.
**Spec refs:** `screens/s0-glass-nav.md` (Layout tree, Elements, States, Strings, Responsive / a11y, Acceptance); `02-components.md` C2-C5; `01-design-tokens.md`; `_theme/rtl.md` (bottom bar order).
**Tasks:**
- [x] Pill (glass layer lives inside the nav bar, not shared [user]; same `BackdropFilter` pattern as `app_dialog_shell.dart` / `overlay_parts.dart`, clipped to the pill): `BackdropFilter` blur 22 + `glassFill` + 1 px `glassBorder` + bar shadow + inner top/bottom highlight; radius 34, height 68, padding 6.
- [x] 5 items, flex 1, height 56, gap 4: Home, Shorts, Create (+), Chat, Profile; no visible labels.
- [x] Inactive icons 22 `iconInactive`; active = filled variant in `primary`; Create = `plus` 26 in `iconInactive`, never selected and never shows the bubble.
- [x] Bubble 44 `glassActive` with its shadow behind the active item; slides 220 ms `easeOutCubic`; icon cross-fade 150 ms. Reduce motion: instant move, no cross-fade.
- [x] Pressed item: 90% opacity, no ripple. Haptic `selectionClick` on tab change and on "+", not on re-tapping the active tab.
- [x] Count badge on Chat: min 18 x 18, r9, `like`, 10/700 white, padding 4, border 2 white 90%, anchored top 9 and start 50% + 3 of the item (RTL: 50% - 3 from the end); hidden at 0, "99+" above 99.
- [x] Semantics: label + selected state per item (`navHome`, `navShorts`, `navCreate`, `navChat`, `navProfile`), badge announces `navUnread` ("{count} unread"). Add the l10n keys (EN + AR drafts tagged `x-review`).
- [x] RTL: item order mirrors (Home on the right in AR); icons not mirrored except per `rtl.md`.
- [x] Wide screens: bar capped at `maxContentWidth` and centered.
- [x] Keep the flat fallback fill as a constant only; leave `// TODO(control-page-plan T9): low-tier fallback fill is not used; no device detection yet (user decision).` where the glass layer is built.
- [x] Tests: active item shows the filled icon and bubble; Create never selected; badge hidden at 0, shows "4", "99+" at 100; semantics labels; RTL order; reduce motion has no animation.
**Out of scope:** tab switching state, hiding, Navigators.
**Done when:** S0 acceptance items 1-4 and 7 pass in a preview over scrolling content (placeholder list).
**Verify:** widget tests; compare with the bar in `docs/specs/control/screenshots/ref-nav-on-home.png` (EN and AR).

### Phase 4: Shell (tabs, state, back, re-tap, hiding, start-up)
**Status:** [x]
**Goal:** `/home` opens the shell with 4 stateful tabs, each with its own Navigator, and the nav from Phase 3.
**Depends on:** Phases 2-3.
**Spec refs:** `00-overview.md` (Scope, Navigation map, Structure advice); `screens/s0-glass-nav.md` > Behavior, Data mapping; `02-components.md` C1, C5; `.claude/conventions/` (architecture, state, navigation, di, file-placement); existing `TODO(reset-link)` in `lib/core/router/app_router.dart`.
**Tasks:**
- [x] Feature folder for the control page per the project conventions; screen provides the Cubit, view reads it with small selectors.
- [x] Shell state (Cubit): selected tab, chat unread count (hardcoded 4), nav visible. Leave `// TODO(control-page-plan T5): chat unread count is hardcoded to 4; the chat feature must supply it.` where the count is set.
- [x] Tabs keep state (one Navigator per tab, e.g. an indexed stack); sub-pages push inside the tab so the nav stays visible. The tab-root wiring (how a feature's root screen is given to the shell) follows the conventions: features hand over screens, never datasources (Q3).
- [x] Tab roots are `PlaceholderScreen`s for now, each with its marker: `// TODO(control-page-plan T1): Home tab placeholder until the home feature is built.`, `T2` (Shorts), `T3` (Chat), `T4` (Profile).
- [x] Each tab body reserves bottom clearance 104 + `viewPadding.bottom` (via `AppSafeArea` `bottomSpace`) so the last item scrolls above the bar.
- [x] Back: pop inside the active tab; on a non-Home tab root go to Home; on the Home root leave the app (Android).
- [x] Re-tap the active tab: pop it to root; if already at root, scroll its primary scroll view to top. Leave `// TODO(control-page-plan T6): on the Home root also refresh the feed once the home feature exists.`
- [x] Hide the nav (slide down 200 ms) while the keyboard is open; full-screen routes are pushed on the root Navigator and cover the shell, so the nav is hidden there too.
- [x] "+" opens the Create sheet (Phase 5 fills it; until then an empty shell sheet is acceptable).
- [x] `AppRouter`: `/home` builds the shell; remove `TODO(auth-plan)` on that route (moved to T1).
- [x] Reset link: on opening the shell, if the auth feature's `IsRecoveryPendingUseCase` says a reset is pending, go to `/reset-password` the way `SplashCubit` does (never stay on Home); remove `TODO(reset-link)`. Check that `SessionGuard` still sees `/home` as a normal route (the shell lives on the root route `/home`).
- [x] Tests: cubit (tab select, re-tap, nav visibility, badge value); widget: tab state survives switching, sub-page push keeps the nav, back rules, keyboard hides the nav, pending recovery goes to `/reset-password`; app boot test still lands on the shell for a signed-in user (`bootApp`, `SharedPreferences.resetStatic()`, `getIt.reset()`, `App(key: UniqueKey())`).
**Out of scope:** Create sheet content and create routes (Phase 5); real tab pages.
**Done when:** S0 acceptance items 5-6 pass; sign-in / splash end on the shell; analyzer and tests green.
**Verify:** run the app (signed in) on a phone, switch tabs, push a test sub-page, open the keyboard; `fvm flutter test`.

### Phase 5: S1 Create sheet and create routes
**Status:** [x]
**Goal:** "+" opens the Create sheet; Post and Short open full-screen placeholders over the shell.
**Depends on:** Phases 2 and 4.
**Spec refs:** `screens/s1-create-sheet.md` (all sections); `01-design-tokens.md` > Create sheet; `02-components.md` C6-C7; `assets.md`.
**Tasks:**
- [x] Sheet content on the Phase 2 shell: title "Create" (`createTitle`), close; two option rows: icon tile 48 `primarySoft` with `ic_create_post` / `ic_create_short` 24 `primary`, title 16/700 (`createPost`, `createShort`), subtitle 13/400 `textSecondary` wrapping to 2 lines (`createPostSub`, `createShortSub`), chevron 18 at the end (mirrors in RTL); rows >= 56 high, Semantics = title + subtitle, button role; pressed state.
- [x] l10n keys from the spec's Strings table (EN + AR drafts tagged `x-review`).
- [x] Post: close the sheet, push `/create/post` on the root Navigator (nav hidden). Short: same for `/create/short`.
- [x] `AppRouter`: resolve both routes to `PlaceholderScreen`s with `// TODO(control-page-plan T7): New post placeholder until the post feature's New post screen (docs/specs/post/screens/s1-new-post.md) is built.` and `// TODO(control-page-plan T8): New short placeholder until the shorts feature exists.`
- [x] Tests: sheet shows both rows with the right strings; each row closes the sheet and pushes its route; scrim / X / back close; RTL chevrons mirror.
**Out of scope:** the New post and New short screens.
**Done when:** S1 acceptance checklist passes.
**Verify:** compare with `docs/specs/control/screenshots/s1-create-sheet.png` (EN and AR); widget tests.

### Phase 6: Polish
**Status:** [~] (all automated checks done; the real-device checks are left: blur performance, side-by-side screenshots in EN and AR)
**Goal:** verify the whole shell across directions, sizes and accessibility settings.
**Depends on:** Phases 3-5.
**Spec refs:** `screens/s0-glass-nav.md` and `screens/s1-create-sheet.md` > Responsive / a11y, Acceptance; `_theme/rtl.md`.
**Tasks:**
- [x] RTL (Arabic): nav order, badge anchor, sheet close and chevrons.
- [x] Wide screen / tablet: bar and sheet capped and centered.
- [x] Text scaling 1.5 on the sheet (subtitles wrap, rows grow); screen reader pass on nav and sheet; tap targets >= 56 (nav) and >= 44 (close).
- [x] Reduce motion: no bubble slide or cross-fade.
- [ ] Blur performance check (needs a real device; not done) while scrolling a long placeholder list on a real Android and iOS device (T9 stays as is unless jank shows: report, do not add detection).
- [x] `grep -rn "TODO(control-page-plan"` lists exactly T1-T9; each still matches its open row above.
**Out of scope:** new behavior.
**Done when:** all acceptance items of S0 and S1 pass in EN and AR; analyzer and tests green.
**Verify:** device run + screenshots side by side; `fvm flutter analyze`; `fvm flutter test`.

## Verification
- Every phase: `fvm flutter analyze` and `fvm flutter test` green; the phase's widget/cubit tests added.
- Visual: `docs/specs/control/screenshots/ref-nav-on-home.png` (bar only) and `s1-create-sheet.png`, in EN and AR.
- Behavior: S0 and S1 acceptance checklists.
- Markers: `grep -rn "TODO(control-page-plan"` matches the Code TODOs table (T1-T9).
