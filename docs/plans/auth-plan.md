# Plan: auth
Source specs: docs/specs/auth/, docs/specs/_theme/
Status: approved
Mode: one-by-one

## Summary
- **Screens (12):** S1 Sign in, S2 Forgot password, S3-S8 the six sign-up steps (one `SignUpFlow` screen), S9 reset-link-sent dialog, S10 leave-sign-up dialog, S11 Set a new password, S12 Password-updated dialog.
- **Goals:** match `docs/specs/auth/screenshots/` at 390 x 844; light theme; EN + AR with RTL per `_theme/rtl.md`; Supabase auth now behind datasource interfaces (adapters) so a REST backend can replace it later.
- **Backend scope (decided with the user):**
  - Real Supabase for everything: auth calls (sign in by email **or username**, sign up, OTP, reset, update password, sign out) and data (profile, interests, follows, avatar upload, suggested profiles, resume).
  - The schema is `docs/specs/auth/schema.sql`, trimmed to what the specs use. It is applied in Phase 3 after the user confirms.
  - All of it stays behind datasource interfaces (`AuthDatasource`, `ProfileDatasource`, `InterestsDatasource`, `FollowsDatasource`) with Supabase adapters, each interface and its adapter in one file, so the later REST swap touches only the data layer.
- **Architecture (final rules; spec `00-overview.md` -> Structure, builder skill `architecture.md` -> *The rules in one list*):**
  - Features are capabilities: `auth` (session, sign-in/reset screens, the sign-up flow), `profile` (profile, interests, follows), `splash`. Not a feature per table.
  - Datasources return `data/model` classes. A repository only where sources are coordinated: `ProfileRepository` (remote + local copy). An entity only for the profile (`ProfileEntity`).
  - Features trade only through use cases; `profile` never imports `auth` or `splash`; nobody imports another feature's datasource, repository, model or entity.
  - Use cases: public entry points (`IsSignedInUseCase`, `GetSignupStepUseCase`) and the ones the sign-up flow needs from `profile`, added with the phase that needs them. Never one per datasource method.
- **Out of scope:** dark mode, real Google/Apple sign-in (snackbar "Coming soon"), contacts matching, the real Home screen, Terms/Privacy content.
- **Testing:** every phase adds Cubit tests (`bloc_test`) and widget tests (EN and AR/RTL), following `test/` conventions in CLAUDE.md.

## Reuse
| Existing | Use |
|---|---|
| `context.appColors`, `context.text`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppScale` | All tokens. Only the deltas in `auth/01-design-tokens.md` are added |
| `PrimaryButton`, `AppText`, `AppSvgIcon`, `ContentWidth`, `AppScaleScope` | Reused. `PrimaryButton` gains disabled + loading (C4) |
| `AppRouter` / `AppRoutes` / `AppNavigator.resetTo` / `PlaceholderScreen` | `/sign-in` and `/register` placeholders are replaced; new routes are added |
| `BaseCubit` | Base for every auth Cubit |
| get_it + injectable | Datasource adapters (`@LazySingleton(as: …)`) and Cubits registered the same way as `OnboardingCubit` |
| `LocalStorageService` | Only if a local flag is needed (no widget touches `SharedPreferences`) |
| gen-l10n (`app_en.arb`, `app_ar.arb`, `context.l10n`) | All strings from the screen specs; Arabic tagged `x-review` |
| Icons already in `assets/icons/` (`ic_key`, `ic_trash`, `ic_warning` included, but not yet in `AppAssets`) | Add the missing constants to `app_assets.dart` |
| `onboarding` feature `SignInLink` | Onboarding already routes to `/sign-in` and `/register` |

## Blockers
| # | Item | Blocks phase | Needed from | Status |
|---|---|---|---|---|
| B1 | TODO (later): Supabase "Confirm signup" email template must include the 6-digit `{{ .Token }}` (S4 uses `verifyOTP`) | Real S4 end to end (Phase 6 Verify, Phase 10). UI and tests are not blocked | User (dashboard) | TODO, deferred |
| B2 | Supabase URL + anon key for the app constants file. Project `pulse` (`xwldtqsvcpyzktysgmuv`, eu-west-1) was created with the Supabase MCP; URL `https://xwldtqsvcpyzktysgmuv.supabase.co`; the legacy anon key / `sb_publishable_...` key are fetched with `get_publishable_keys` when writing the constants (Phase 0) | Phase 0 / 3 | - | resolved (value goes in code in Phase 0) |
| B3 | Apply `docs/specs/auth/schema.sql` | Phase 3 | - | resolved: applied to project `pulse` on 2026-10-08 (4 tables, 14 interests, RLS on, `avatars` bucket, grants hardened) |
| B9 | S8 meta line / empty state | Phase 8 | User | resolved: mutual friends or city, hidden otherwise; the school line is dropped; empty tab = message only; S7/S8 are skipped when their list is empty |
| B4 | TODO (later): recovery deep link: add Supabase redirect URL `pulse://reset-password` (dashboard), then URL scheme + native config (Q13) | Phase 10 task "deep-link wiring". S11 UI (Phase 9) is not blocked: it can be opened by route | User (dashboard) | TODO, deferred |
| B5 | Expired / invalid recovery-link state | Phase 9 / 10 | - | resolved: specced in S11 (message + "Request a new link" -> S2) |
| B6 | Arabic copy review (Q9) | Release, not build | User | open |
| B7 | Terms / Privacy copy (Q5) | None. Placeholder: title + "Coming soon" | User | open, default used |
| B10 | S13 offline copy promises an automatic retry when the connection returns: needs the `connectivity_plus` dependency (Q24). Default: add it | Phase 3b (the automatic retry only; the "Try again" button is not blocked) | User (confirm the dependency) | open |
| B11 | S13 failure -> state mapping: connection lost or timeout -> Offline; expired session -> Sign in; other failures -> Can't reach Pulse (Q25, estimated) | Phase 3b | User (confirm) | open, default used |
| B12 | Auth's per-IP limit on `/auth/v1/token` (password and refresh grants) is shared by every user once all sign-ins come from the Edge Function's IP. Findings: the current value cannot be read with the MCP (no tool for Auth config): read it in Dashboard > Authentication > Rate Limits (or give a Management API token through an env var, never in chat). Per Supabase docs Auth uses the caller's IP; the real client IP reaches Auth only with the `Sb-Forwarded-For` header, sent with a **secret** API key, and the project setting "IP Address Forwarding" enabled (it is off by default for new projects); publishable / anon-key calls are not supported. So the planned publishable-key call would put all users in one bucket. **Decided [user]:** the function makes the password grant with the secret key + `Sb-Forwarded-For`, and you enable IP Address Forwarding. Fallback if Auth ignores it: raise the per-IP limit and rely on the function's own limits (5 / min per IP, 5 / 15 min per identifier). Record the outcome here. **Still missing from your answers:** (3) whether the project already has a `default` secret key or one was created, and (4) the current per-IP value from Authentication > Rate Limits: both were left as placeholders in the message | Phase 3c (the function deploy needs the secret key; the fallback needs the value) | User | **Result (2026-10-08, corrected):** **Which Auth limit applies.** The Supabase docs I can query (Rate limits; Production Checklist) list `/auth/v1/token` once, as "Token refresh requests": 1800 per hour per IP, burst 30. They do not state a separate sign-in default. The dashboard (Authentication > Rate Limits) has a separate "sign-ups and sign-ins" limit that you put at about 30 per 5 minutes per IP; I could not confirm that number from the docs or read the project's actual value (no Management API token here). I earlier compared against the 1800 / hour refresh figure, which was the wrong one for sign-in. Working assumption: sign-in is about 30 per 5 minutes per IP. **Consequence:** the function's old per-IP limit (10 / min = 50 per 5 minutes) was NOT tighter than that. Changed to **5 / min per IP (25 per 5 minutes)**; the per-identifier limit stays 5 / 15 min. Redeployed as version 2, tests updated, checks re-run (all pass). **Does the password grant go out right?** Yes: the code and its unit test (`the password grant uses the secret key and forwards the client IP`) show the headers `apikey` (the secret key), `Content-Type` and `Sb-Forwarded-For` (the client IP), and no `Authorization`; printing the header names from the real handler gave `apikey, Content-Type, Sb-Forwarded-For`. Live, the function's throttle row for the hash of this machine's public IP exists in `private.auth_rate_limits` (10 hits), so `clientIp` returns the real client IP and that is the value sent as `Sb-Forwarded-For`. The outbound request itself cannot be observed from outside the function without a probe function or the secret key, so it was not captured live. **Does forwarding work?** **Not shown, and the log cannot show it.** Auth's `auth_logs` records `remote_addr` (the connecting peer) only: the function's egress addresses for sign-ins, this machine's IP for a direct signup call. There is no forwarded-IP field, so the log neither proves nor disproves that Auth rate-limits on the forwarded IP. The setting itself (IP Address Forwarding) is yours to confirm in the dashboard. **Fallback in place:** the function's own limits (5 / min per IP, 5 / 15 min per identifier) bound a brute-force attempt without depending on Auth. Auth's own 429 is now mapped inside the function to the same `429 rate_limited` + `Retry-After` shape (60 s when Auth sends no header). Left for you: confirm "IP Address Forwarding" is on and read/raise the sign-ups and sign-ins limit (Dashboard > Authentication > Rate Limits) | Phase 3c | User (dashboard only) | resolved with fallback; dashboard items open |
| B8 | S9 "Resend link" 30 s cooldown and "Change email" behavior | None. Spec marks them resolved as written | - | resolved |

Spec defaults accepted by the user: avatar color = stable hash of user id -> palette index (Q7); `[estimated]` spacings are used as written and checked against the screenshots (Q8); `/home` is a placeholder.

## Phases

### Phase 0: Prerequisites
**Status:** [x]
- **Goal:** dependencies, assets, routes and constants are in place; the app still compiles and runs.
- **Depends on:** nothing.
- **Spec refs:** `auth/assets.md`, `auth/00-overview.md` (Navigation map), `_theme/icons-and-assets.md`.
- **Tasks:**
  - [x] Add packages from `assets.md`: `supabase_flutter`, `pinput`, `image_picker`, `url_launcher`. Confirm versions at install time.
  - [x] Add `AppAssets` constants for the icons the auth specs use that are missing: `key`, `warning`, `trash`. All paths stay in `app_assets.dart`.
  - [x] Register the Supabase URL + anon key in an app constants file (B2). If the MCP is unavailable, leave clearly marked empty constants and record the blocker.
  - [x] Add route constants for `/forgot-password`, `/reset-password`, `/terms`, `/privacy`, `/home`.
  - [x] Add placeholder screens for `/terms` and `/privacy` (title + "Coming soon") and `/home` (a `PlaceholderScreen`), resolved in `AppRouter`.
  - [x] Platform permissions needed later by `image_picker` (camera, photo library) and `url_launcher` (`mailto:` query on iOS/Android).
- **Out of scope:** any auth code, theme tokens, Supabase initialization logic.
- **Done when:** `fvm flutter pub get` and `fvm flutter analyze` are clean; the app launches as before; the new routes open their placeholders.
- **Verify:** run the app; `fvm flutter analyze`; `fvm flutter test` (existing tests still pass).

### Phase 1: Theme deltas and PrimaryButton states
**Status:** [x]
- **Goal:** the new tokens exist and `PrimaryButton` supports disabled and loading.
- **Depends on:** Phase 0.
- **Spec refs:** `auth/01-design-tokens.md`, `auth/02-components.md` (C4), `_theme/colors.md`, `_theme/typography.md`.
- **Tasks:**
  - [x] Add `dangerSoft` #FBE4E5 to the color extension.
  - [x] Add the new dimension constants from `01-design-tokens.md` (dialog padding and radius, input padding, tile sizes, progress and strength segments, OTP box, chips, avatar sizes, checkbox, button heights) as scaled values. Tap targets (44) stay unscaled.
  - [x] Dialog backdrop blur value (sigma 12) and dialog shadow (= onboarding cards shadow) exposed as tokens.
  - [x] `PrimaryButton`: disabled = `primary` @ 40% opacity, taps ignored; loading = white 20 px spinner replaces the label, taps ignored. Existing onboarding usage must not change.
- **Out of scope:** new widgets.
- **Done when:** every row in the "New / differs" table has a code token with the exact value; `PrimaryButton` shows disabled and loading states; the onboarding tests still pass.
- **Verify:** widget test for the three `PrimaryButton` states; `fvm flutter analyze`.

### Phase 2: Shared auth components
**Status:** [x]
- **Goal:** build the components used by several auth screens, in isolation.
- **Depends on:** Phase 1.
- **Spec refs:** `auth/02-components.md` (C1-C4, C5, C6, C8, C8b, C9, C10, C11, C14, C15), `auth/01-design-tokens.md`, `_theme/rtl.md`.
- **Tasks:**
  - [x] Core (`lib/core/widgets/`, barrel updated), used by more than one feature or flow:
    - [x] `AppDialogShell`: barrier scrim + blur, card 342 max, fade + scale 180 ms, scrolls at large text.
    - [x] `ConfirmationDialog` with the four factories `destructive`, `primary`, `info`, `stacked` (fixed layout per factory, `info` has `dismissible`).
    - [x] Outline, soft and danger pill buttons (C4).
    - [x] `AuthTextField` (C3) with variants: plain, password, "@" prefix, multiline with counter, read-only tap field.
    - [x] `SelectableChip` (C11) incl. the dark segmented variant.
  - [x] Auth-only (`features/auth/presentation/widgets/`): `AuthHeader`, `LogoTile`, `IconTile` (C1, C2), `SocialButtonsRow` (C5), `OrDivider` (C6), `PasswordStrengthMeter` (C8), `PasswordRulesList` (C8b), `LabeledCheckbox` (C9), `OtpField` on `pinput` (C10), `PinnedBottomCta` (C15), `StepTopBar` (C7).
  - [x] Pure helper for the password score (shared by C8, S3 and S11) and for masking an email (shared by S4, S9, S11).
- **Out of scope:** screens, state, Supabase. `AvatarInitials`/`FollowRow` and `PhotoPickerAvatar` are built in the screen phase that uses them (C12 in Phase 8, C13 in Phase 7).
- **Done when:** each component matches its spec in LTR and RTL; directional icons flip and the logo mark does not; the password eye has the Show/Hide Semantics; the dialog has role + title semantics; masking follows the S4 rule; the strength score matches C8.
- **Notes (builder):** `AuthTextField` is built as `AppTextField` in `core/widgets/` (a shared form field); the three pills are one `PillButton` with `.outline` / `.soft` / `.danger` factories and a `PillButtonVariant` enum that owns their sizing and colors; `PrimaryButton` gained `buttonHeight`. `pinput` is pinned to `^6.0.2`: 7.x moved to the separate `material_ui` package and fails its Material assertion in an app on `flutter/material.dart`. The links inside the S3 checkbox label are built with S3 (Phase 6). Screenshot comparison (`confirmation-dialog-component.png` etc.) needs the running app and is done with the screens and in Phase 11.
- **Verify:** widget tests per component (EN and AR); a temporary preview (not committed) compared with `screenshots/confirmation-dialog-component.png`.

### Phase 3: Auth data layer, session and DI
**Status:** [x]
- **Goal:** the schema is applied; auth and profile data sit behind datasource interfaces with Supabase adapters (plus the profile's local copy and repository, and the two use cases the splash needs); and the splash routes by the session and `signup_step`.
- **Depends on:** Phase 0.
- **Spec refs:** `auth/schema.sql`, `auth/00-overview.md` (Backend, Navigation map, Structure/Resume), `auth/open-questions.md` (Q2, Q10, Q17, Q18), screens' "Behavior and navigation" sections.
- **Tasks:**
  - [x] The schema is already applied to project `pulse` (B3). Save the two migrations (`pulse_schema`, `pulse_harden_function_grants`) as files in `supabase/migrations/` for the record; do not re-apply.
  - [x] Auth interface covering: sign in with password (the identifier is an email or a username, resolved on the server by the `sign-in` function (Phase 3c; first built with the RPC `get_email_for_username`)), sign up, verify signup OTP, resend signup code, send reset email, update password, sign out (current session / others scope), current session / email, and a way to observe the recovery event.
  - [x] Supabase implementation of that interface, initialized at start-up. Map Supabase errors to the static messages the specs use (wrong credentials, email exists, wrong code, unverified email).
  - [x] Profile-data interface with a Supabase implementation per `schema.sql`: read the profile (`signup_step`), username availability RPC, update profile fields and `signup_step`, upload the avatar to the `avatars` bucket (`{uid}/avatar.jpg`) and save `avatar_url`, load interests (`name_en` / `name_ar` by locale) and save with `set_user_interests`, `suggested_profiles` for the Suggested and Popular tabs, follow, unfollow, and `follow_many`. No contacts calls (the tab is "Coming soon").
  - [x] Register everything in DI; regenerate `injection.config.dart`.
  - [x] Splash routing: no session -> `/sign-in`; session + `signup_step` 0 -> `/home`; session + step 3..6 -> `/register` at that step (at least 3); keep the onboarding rule for first launch. `signup_step` is advanced by each step's Continue/Skip and set to 0 after step 6.
  - [x] Failure handling stays minimal (no new architecture): map errors to a small result the Cubits can show.
- **Out of scope:** UI, deep link.
- **Done when:** the migration files are saved in `supabase/migrations/`; unit tests cover error mapping and the start-up decision with mocked datasources; `fvm flutter analyze` is clean; the app still starts to onboarding/sign-in as before.
- **Notes (builder):**
  - `Either`, `Equatable`, `JsonMapper`, `Failure`, `Guard` and the Supabase error mapping are new in `core/` (the first backend feature adds them). `AuthFailure` carries an `AuthFailureReason` enum (`core/enums/`).
  - **Architecture:** the final rules are in the Summary above and in the spec. As built in Phase 3: `auth/data/datasource/auth_datasource.dart` (interface + adapter); `profile/data/datasource/{profile,interests,follows}_datasource.dart` (interface + adapter each) and `profile_local_datasource.dart` (concrete, over `LocalStorageService`: one entry per user, no phone or birthday); `profile/data/model/*` and `data/enums/*` (wire values); `profile/data/repository/profile_repository.dart` (abstract + Impl: write-through to the local copy, network-first reads, the saved copy only on a lost connection, `ProfileModel` -> `ProfileEntity`); `profile/domain/entity/*` (profile only); use cases `IsSignedInUseCase`, `GetSignupStepUseCase`, `ClearLocalProfileUseCase`; `features/splash` (flow) over those use cases.
  - `Supabase.initialize` runs in `main()`, not in DI: initializing in a DI factory left a pending timer in every test that boots the app. `bootApp` now registers signed-out mock datasources for auth and profile.
  - Sign-out flows (Phase 8 Leave, Phase 9 reset): `ClearLocalProfileUseCase` (removed in Phase 4 because nothing called it) is added back in Phase 8, with the Leave dialog, so the saved profile does not stay on the device after signing out.
  - Cross-feature access (added in review): `profile/domain/use_case/get_signup_step_use_case.dart` (`GetSignupStepUseCase`: the step, an unknown one counts as the first) and `auth/domain/use_case/is_signed_in_use_case.dart` (`IsSignedInUseCase`) are the only things `splash` imports from other features.
  - Splash (`features/splash`): after onboarding, `/` opens `SplashScreen` whose `SplashCubit` picks Sign in, Home or `/register?step=N`; any failure reading the profile goes to Sign in. The sign-up screens read `step` in Phase 6. The screen is `BlocProvider(create: (_) => getIt<SplashCubit>()..decide())` and shows the shared `AppLoadingView`; `decide()` yields before its first emit, because the no-session branch would otherwise emit before the `BlocListener` subscribes and the splash would never leave (guarded by a Cubit test and a 6-test screen test over the real Cubit and mocked use cases).
  - Splash design arrived after Phase 3 (screens/s13-splash.md): the empty/spinner splash built here is replaced in Phase 3b.
  - Shared loading (added after Phase 3): `AppSpinner` and `AppLoadingView` in `core/widgets/` (spec `02-components.md` C16), `LoadingDimens`, and the `loading` string (EN + Arabic draft). `PrimaryButton`'s loading state reuses `AppSpinner`. Later screens that wait for first data (S7 interests, S8 suggestions, the sign-in/reset submit) use these, never a raw `CircularProgressIndicator`.
  - **Security gap, closed by Phase 3c:** Phase 3 resolved a username with the RPC `get_email_for_username`, executable by `anon`, so anyone could turn a username into an account's email without signing in. Phase 3c moves username sign-in to an Edge Function and removes the RPC from the app.
  - Bugs the tests caught and fixed: a date-only value (`1999-02-03`) parsed as local midnight, so `toUtc()` moved a birthday back a day east of Greenwich; `.order()` defaults to descending, which would have reversed the interests.
  - Saved `supabase/migrations/` files for the record; the migrations were already applied (B3). Not checked on a device: the start-up with a real stored session.
- **Verify:** `fvm flutter test`; re-check the tables, RPCs and bucket with the Supabase MCP; manual start-up with and without a session.

### Phase 3b: Splash screen (S13): loading, offline, can't reach
**Status:** [x] (except the B10 automatic retry, which needs your OK for a new package)
- **Goal:** the splash matches `screenshots/s13-splash-*.png` in all three states and recovers from a failed start.
- **Depends on:** Phases 1, 2, 3. B10 for the automatic retry only; B11 default is used until confirmed.
- **Spec refs:** `screens/s13-splash.md`, `00-overview.md` (Structure), `assets.md`, `open-questions.md` (Q24, Q25, Q26), `_theme/rtl.md`.
- **Tasks:**
  - [x] Register `ic_wifi_off` and `ic_cloud_alert` in `AppAssets` (the files are already in `assets/icons/`).
  - [x] Strings (EN + Arabic drafts): `offlineTitle`, `offlineBody`, `cantReachTitle`, `cantReachBody`, `tryAgain` (the S13 table); `loading` exists.
  - [x] Splash state and logic: states Loading / Offline / CantReach / go-to-route. Map failures per the spec (B11): lost connection or timeout -> Offline; `AuthFailure(sessionExpired)` -> Sign in; anything else -> CantReach. "Try again" returns to Loading and decides again. Keep the yield-first rule of `decide()` (builder skill, presentation layer). The splash still reaches other features only through `IsSignedInUseCase` and `GetSignupStepUseCase`.
  - [ ] **[B10]** Automatic retry while Offline when the connection returns (`connectivity_plus`, behind a small `core/` service so it can be mocked), cancelled when the screen goes.
  - [x] Loading UI: 72 logo tile (radius 22) with the "pulse" wordmark (`display`) 14 below, centered; a 28 `primary` spinner on a `switchOff` track at the bottom (give `AppSpinner` an optional track color). The shared `AppLoadingView` stays for other screens.
  - [x] Offline / CantReach UI (one widget, icon and copy from the state): the logo mark + wordmark header, centered (reuse the onboarding top-bar logo mark; since a second feature now needs it, move it to `core/widgets/`), the 96 `primarySoft` circle with the 40 icon, title (`messagesTitle` size), `bodySm` body, and a pinned `PrimaryButton` "Try again" (`PinnedBottomCta`). Scrolls on small screens and large text.
  - [x] Semantics: title as a header, header logo decorative, spinner announced "Loading".
  - [x] Replace the Q22 loading view in `SplashScreen` with the S13 loading UI.
- **Built (2026-10-08):** states Loading / `failed(SplashProblem.offline | cantReach)` / go-to-route in `SplashState`; `SplashCubit.retry()` (back to Loading, then `decide()`, yield-first kept); the presentation enum `SplashProblem` owns icon, title and body; `SplashScreen` (provides the Cubit, navigates) -> `SplashView` (pure UI) -> `SplashLoading` / `SplashProblemView`. Moved to `core/widgets/` because the splash is a second feature: `PinnedBottomCta`, `LogoTile` (new `LogoTile.large()`, 72 / radius 22) and `LogoLockup` (extracted from the onboarding top bar, which now uses it). `AppSpinner` has an optional `trackColor`. Dimens in `SplashDimens` (all `[estimated]`, Q26). Deviation: the header logo mark is the onboarding lockup's 26, the spec estimate says 28. Tests: Cubit (every failure -> its state, session expiry -> Sign in, retry, yield-first, retry no-op while deciding), screen (route on every branch, retry reaches loading and goes on), view (EN + AR for both problems, header / circle 96 / pinned button geometry, semantics, 390x844 and 320x480 at text 1.0 and 2.0 with no overflow). `analyze` clean, 425 tests pass. Not done here: the side-by-side comparison with the three screenshots (the app was not run on a device or simulator).
- **Out of scope:** the sign-in screen, any other screen's loading state.
- **Done when:** the S13 acceptance checklist passes; every failure reaches the right state or Sign in; "Try again" works; no raw error text is shown.
- **Verify:** Cubit tests (each failure -> its state, retry, the yield-first timing, automatic retry with a fake connectivity service); screen tests EN + AR for the three states (route changes on every branch); widget tests at 390 x 844, 320 x 480, text scale 2.0; compare with the three screenshots.

### Phase 3c: Server-side sign-in (close the username -> email leak)
**Status:** [x]
- **Goal:** the email never reaches the client unless the password was correct. S1 still takes "Email or username" + password, behind `AuthDatasource`, so a REST swap still touches only the data layer.
- **Depends on:** Phase 3. B12 for the function's Auth call and its Verify. Approval gates: nothing is applied or deployed until you confirm.
- **Spec refs:** `screens/s1-signin.md` (Behavior, States), `open-questions.md` (Q17, Q27), `schema.sql`, the plan's Summary -> Architecture rules and `CLAUDE.md`.
- **Findings from reading the current state (before any change):**
  - Live grants (checked with the MCP): `get_email_for_username` is executable by `anon` and `authenticated` (the leak). The other functions are as intended (anon denied; `service_role` allowed).
  - `public.sha256_hex` does not exist on the project and stays out of the database and out of `schema.sql` [user]: the function hashes `"ip:<ip>"` and `"id:<identifier>"` with `crypto.subtle` SHA-256 and passes only the hex; `hit_rate_limit` refuses any key that is not a 64-character lowercase hex string, so the database never sees a raw value.
  - Schema `private` does not exist: the migration creates it and revokes it from `anon` / `authenticated`. Whether the API exposes it cannot be read with SQL; it is verified through the REST API after applying.
  - No Edge Functions exist yet. Extensions present: `pgcrypto`, `citext`, `supabase_vault`; `pg_cron` is not installed and is not needed (expired rows are deleted inside `hit_rate_limit`).
  - Default Edge Function secrets (Supabase docs): `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEYS` and `SUPABASE_SECRET_KEYS` (JSON dictionaries, key `default`), `SUPABASE_JWKS`, `SUPABASE_DB_URL`, plus the legacy `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY`. New keys are not JWTs: send them on the `apikey` header, never `Authorization: Bearer`, and use `verify_jwt = false`. Whether this project has a `default` secret key (Settings > API Keys) is to confirm; otherwise the function reads the legacy service-role variable.
  - Call sites of the RPC to remove: `auth_datasource.dart` (`_emailFor`), `supabase_auth_datasource_test.dart`; docs: `schema.sql`, both migration files (history, untouched), `s1-signin.md`, Q17. `AuthFailureReason.invalidCredentials` is the existing "wrong credentials" reason. `AuthFailure` carries only `reason` today: it gains optional `email` and `retryAfter`. The app has no web target (Android, iOS), so the function needs no CORS.
- **Tasks:**
  - [x] **Migration** `<ts>_signin_server_side.sql` (saved in `supabase/migrations/`, `schema.sql` updated to match):
    - `get_email_for_username`: revoke execute from `public`, `anon`, `authenticated`; grant to `service_role` only; keep `security definer`, `search_path = ''`, the lower/trim normalization.
    - `private.auth_rate_limits (key text primary key, window_start timestamptz not null, hits int not null)` with a check that `key` is a 64-char hex hash, RLS on, no policies, schema and table revoked from `anon` / `authenticated`.
    - `public.hit_rate_limit(p_key text, p_limit int, p_window_seconds int) returns int`: seconds to wait, or 0 when allowed; atomic `insert ... on conflict do update`, window reset on expiry, expired rows deleted occasionally inside it; `security definer`, `search_path = ''`, execute for `service_role` only. Keys are the function's SHA-256 hex of `ip:<ip>` and `id:<normalized identifier>` (hashed in the function, see above): no raw value is stored.
    - **Status: APPLIED 2026-10-08** (Gate 1 passed) as migration `signin_server_side`, version `20261008031908`; the file is `supabase/migrations/20261008031908_signin_server_side.sql` and `schema.sql` section 7 mirrors it.
  - [x] **Gate 1:** your OK -> applied with the MCP -> checks, all passed: `anon` and `authenticated` are denied on `get_email_for_username` and `hit_rate_limit` (database privileges, and over the REST API with the public key: HTTP 401, `42501 permission denied for function`); `service_role` can execute both; `private.auth_rate_limits` is unreachable through the API (HTTP 406 `PGRST106 Invalid schema: private`, only `public` and `graphql_public` are exposed; the same table name in `public` is HTTP 404); the schema and table have no access for `anon`, `authenticated` or `service_role` (only the security definer function writes it); RLS is on with no policies. `hit_rate_limit` tested with throwaway keys (deleted afterwards, 0 rows left): with a limit of 2, calls 1-2 return 0 and calls 3-4 return the wait (60 s); a 1 s window resets (0, blocked, 0 after 1.3 s); an upper-case key is refused (`22023`). The security advisor no longer lists any `anon`-executable function; the only new entry is an INFO "RLS enabled, no policy" on the private table, which is the intended deny-all. Not tested here: the `authenticated` role over the API (needs a user JWT; covered by the privilege query).
  - [x] **Edge Function written and DEPLOYED** (Gate 2 passed; version 1, `verify_jwt = false`). Files: `supabase/functions/sign-in/index.ts` (limits and the 400 ms padding as constants at the top; startup check of the secret key), `handler.ts` (the flow, with injectable fetch / sleep / clock so it can be tested) and `input.ts` (validation, client IP, SHA-256, the secret-key check). 23 tests in `handler_test.ts`, all passing under Node (`node --test supabase/functions/sign-in/handler_test.ts`) against a faked Supabase: validation, token-only success, username resolution, the secret key and `Sb-Forwarded-For`, identical 401s, the 403, padding, hashed keys, both throttles including the 6th-attempt case, fail-closed when the throttle store is down, no PII in the logs. Not run: a Deno type-check (Deno is not installed here) and anything against the real project. Deploy with the MCP (`verify_jwt = false`; upload `index.ts`, `handler.ts`, `input.ts`, not the test). Spec (`verify_jwt = false`, POST JSON `{ identifier, password }` only):
    1. Validate: identifier trimmed, 3-254 chars; an email if it has "@", otherwise a username (lowercased, `^[a-z0-9._]{3,30}$`); password 1-128 chars. Bad input -> 400 `{"code":"bad_request"}`.
    2. Throttle before any lookup (constants at the top of the file): 5 / minute per IP (changed from 10 after B12, see there), 5 / 15 minutes per identifier. The client IP is the first `x-forwarded-for` entry; the file documents how far that header can be trusted (tested, see Verify). Over the limit -> 429 `{"code":"rate_limited","retry_after":n}` + `Retry-After`.
    3. Resolve a username with `get_email_for_username` through a service-role/secret client; no match goes straight to the generic 401 and Auth is not called.
    4. Sign in with a separate client (no session persistence) using the **secret key** from `SUPABASE_SECRET_KEYS` (the `default` entry) and the `Sb-Forwarded-For` header with the client IP [user, B12]. The function **fails loudly at startup** if that secret is missing: no fallback to the legacy service-role key. The same secret key is the service-role client of step 3.
    5. Responses: 200 `{access_token, refresh_token, expires_in, expires_at, token_type}` only (no user, no email); unknown username / unknown email / wrong password -> the same 401 `{"code":"invalid_credentials"}` with the same body and headers; unverified email -> 403 `{"code":"email_not_confirmed","email":"<email>"}` only after Auth accepted the password (verified with a test user; if Auth reports "not confirmed" before checking the password, return the generic 401 and tell you); anything else -> 500 `{"code":"server_error"}` (server log without PII).
    6. Pad every non-429 response to a fixed minimum (about 400 ms) so "username not found" and "wrong password" take the same time.
    7. No CORS (no web target). Never log passwords, emails or raw identifiers; the secret key is read from the function's environment only.
  - [x] **Gate 2:** your OK -> deployed with the MCP -> live checks passed (results below); `supabase/functions/sign-in/check.sh anonymous|accounts` runs them again (the accounts part reads the git-ignored `.env.test` itself and prints no secrets).
  - [x] **Flutter** (`auth_datasource.dart`, interface + adapter in the same file):
    - `signIn(identifier, password)` keeps its signature; the adapter calls `functions.invoke('sign-in', body: ...)` then `auth.setSession(refreshToken)` so the session stream fires as before. The RPC call is removed from the app.
    - Error mapping in `core/` next to the Supabase mapping, from `FunctionException`: 401 -> `AuthFailure(invalidCredentials)`; 403 `email_not_confirmed` -> `AuthFailure(emailNotConfirmed, email: ...)`; 429 -> `AuthFailure(tooManyAttempts, retryAfter: ...)` (new `AuthFailureReason.tooManyAttempts`); network or timeout -> the existing connection failure; anything else -> the existing unknown failure. `AuthFailure` gains `String? email` (only for `emailNotConfirmed`) and `Duration? retryAfter` (only for `tooManyAttempts`), both in `props`; tests assert both are null for every other reason [user].
    - Update the signed-out mock datasources (`bootApp` and tests): an unknown user returns the generic failure, and the mock can return `tooManyAttempts`.
    - Unit tests: the error mapping for every row above; the adapter calls the function and then `setSession`; the adapter never calls the RPC.
  - [x] **Docs:** `schema.sql` (the function's grants), `s1-signin.md` (Behavior, States, strings), Q17 superseded, Q27 (this change).
- **Out of scope:** the S1 screen and its states (Phase 4, recorded there); sign-up, verify and reset flows (they still call Auth directly); CAPTCHA; the Auth dashboard settings (B12 is yours); any new package, Postgres extension or outside service (none is needed; ask first if one appears).
- **Done when:** no response contains an email except the 403 after a correct password; an unknown username and a wrong password are indistinguishable (status, body, headers, timing); the 6th attempt in 15 minutes for one identifier gets 429 with `Retry-After`; email and username sign-in both return tokens that `setSession` accepts; `get_email_for_username` appears nowhere in `lib/`; `fvm flutter analyze` is clean and `fvm flutter test` is green with the existing Cubit and splash tests unchanged.
- **Verify:**
  - MCP after applying: the permission checks above; `service_role` allowed; `private.auth_rate_limits` unreachable through the API (a REST request with `Accept-Profile: private` is refused).
  - Function after deploying, with `curl` against the test users read from env vars `PULSE_TEST_VERIFIED_EMAIL` / `_USERNAME` / `_PASSWORD` and `PULSE_TEST_UNVERIFIED_EMAIL` / `_PASSWORD` (never hard-coded, never logged, never in the PR) (the commands go in the PR): identical status, body and headers for an unknown username and a wrong password; the 6th attempt returns 429 + `Retry-After`; whether a spoofed `x-forwarded-for` changes the throttle key (decides how far that header is trusted); the unverified-user check; and, for B12, whether Auth rate-limits per forwarded IP. Testing the forwarded IP against Auth needs the secret key: you run that one command from your shell with the key in an env var, or approve a temporary probe function (the MCP cannot delete a function afterwards).
  - Grep for the RPC in `lib/`; app `analyze` and `test`.
  - **B12 / forwarded IP [user]:** no probe function and no key handling on my side. Changed to: use a successful sign-in from the accounts run and compare the Auth log's recorded IP with this machine's public IP; result in B12. Device IP = forwarding works; function IP = use the fallback in B12 (raise the per-IP limit and rely on the function's limits). The outcome is recorded in B12.
- **Live results (2026-10-08, `check.sh`):**
  - An unknown username, an unknown email and a wrong password on a real account all return 401 `{"code":"invalid_credentials"}` with identical status, body and headers.
  - Timing, wrong password, 3 interleaved rounds vs 5: real username min 0.655 s / median 0.676 s; unknown username min 0.650 s / median 0.666 s. Neither is consistently faster (the difference is within network noise; the 400 ms floor is hidden under the round trip).
  - Email + password and username + password both return 200 with only `access_token, expires_at, expires_in, refresh_token, token_type`; no response body contained the email.
  - The unverified account returns 403 `email_not_confirmed` (with its email) only for the correct password; a wrong password gives the generic 401, so GoTrue reports "not confirmed" only after the password check.
  - Auth's own 429 / `over_request_rate_limit` is mapped to the same `429 rate_limited` shape inside the function; covered by unit tests (it cannot be triggered live without exhausting Auth's limit). `check.sh` now spaces its calls to stay under 5 / minute.
  - Re-run on version 2 (2026-10-08): every check above passed again. Timing, wrong password: real username min 0.679 s / median 0.866 s (n=3), unknown username min 0.670 s / median 0.728 s (n=5). The minimums match; the real-account median was slower in this run (earlier run 0.676 vs 0.666 s), so a real account may sometimes take longer than the 400 ms floor on the server. If that matters, raise `MIN_RESPONSE_MS`.
  - The 6th attempt for one identifier within 15 minutes (earlier run, 10 / min IP limit): 429, `Retry-After: 897`, `{"code":"rate_limited","retry_after":897}`.
  - Spoofing: 12 calls with a different fake `x-forwarded-for` each, 10 allowed and calls 11-12 got 429 (before the limit became 5 / minute; re-run with the new limit: 5 allowed, calls 6-12 got 429), so the gateway replaces the header and the per-IP key cannot be rotated by the client. Bad input -> 400, GET -> 405.
  - Flutter: the gateway accepts the publishable key as the `Authorization` bearer for this function (it reaches the function, which answers 400 to `{}`); `analyze` is clean and `fvm flutter test` passes (394 tests). `get_email_for_username` no longer appears anywhere in `lib/`.
- **Test accounts (delete before release):** two throwaway users created for these checks. `auth.signUp` with the publishable key was rejected (`email_address_invalid` for the `@example.com` addresses), so they were created with the seed-style SQL insert into `auth.users` + `auth.identities` (bcrypt hash computed locally, so no plaintext password appears in any SQL). Their credentials live only in `supabase/functions/sign-in/.env.test` (mode 600, git-ignored). Verified user (email confirmed, username `pulse_test_82nswt`, full name, birthday, `signup_step = 0`): `2a3c9c8a-3355-4700-9b41-113bebbab899`. Unverified user (left unconfirmed): `a172bf36-f16c-49e1-b44b-9fbb527ea9e1`. Delete both (the profile rows cascade) with:
  ```sql
  delete from auth.users where id in ('2a3c9c8a-3355-4700-9b41-113bebbab899', 'a172bf36-f16c-49e1-b44b-9fbb527ea9e1');
  ```
- **PR note:** the sign-in flow, the limits (constants at the top of the function, how to change them), B12 status.

### Phase 4: Sign in (S1)
**Status:** [x] (screenshot comparison and the live sign-in with B2 are still to do on a device)
- **Goal:** S1 matches `screenshots/s1-signin.png` and signs the user in.
- **Depends on:** Phases 2, 3, 3c (username sign-in is server-side; S1 is built on that flow).
- **Spec refs:** `screens/s1-signin.md` (updated: Email or username), `02-components.md` (C1-C6), `_theme/rtl.md`.
- **Tasks:**
  - [x] `SignInScreen` (provides `SignInCubit`) + `SignInView` replacing the `/sign-in` placeholder.
  - [x] Layout and tokens per the layout tree; strings and Arabic drafts into both ARBs.
  - [x] State: the first field is "Email or username" (forced LTR, no format error: "@" means email, otherwise username); Sign in disabled until both fields are non-empty; loading makes fields read-only; wrong credentials or unknown username show "Incorrect email or password" under the password.
  - [x] Navigation: success -> `/home` via `resetTo` if the profile is complete, `/register` step 3 if not; unverified email -> S4 with that email and a new code; "Forgot password?" -> S2; "Create account" -> `/register`; Google/Apple -> "Coming soon" snackbar.
  - [x] S1 error states from Phase 3c's failures (`SignInCubit` keeps calling `AuthDatasource`; no repository, no new use case): wrong password and unknown username both show "Incorrect email or password" (existing behavior, they are indistinguishable); **too many attempts** shows "Too many attempts. Try again in {time}." under the password and keeps Sign in disabled until the `retryAfter` countdown ends (strings `tooManyAttempts` in EN and AR, the Arabic tagged `x-review`; `{time}` formatted like the resend cooldown); **unverified email** opens S4 with the email returned in the 403 and sends a new code (unchanged behavior, the email now comes from the failure).
  - [x] Keyboard actions and autofill hints per C3; screen scrolls under the keyboard.
- **Out of scope:** S2, sign-up screens (the targets can still be placeholders at this point), real social login.
- **Done when:** the S1 acceptance checklist passes, including RTL (hint/email stay LTR, eye icon on the leading side).
- **Verify:** Cubit tests (disabled, loading, email vs username path, unknown username, credentials error, too many attempts with a countdown that re-enables Sign in, unverified with the returned email, resume by `signup_step`); widget test EN + AR; compare to the screenshot; manual sign-in with B2.
- **Notes (builder):**
  - Built: `SignInScreen` / `SignInView` / `SignInCubit` + `SignInState` in `features/auth/presentation/`; `ForgotPasswordLink` and `AuthSwitchLink` (the footer link, reusable by S3) in `widgets/`; `formatCountdown` (`m:ss`, `utils/format_countdown.dart`) for the throttle message, to be reused by the S4 resend cooldown. The cubit calls `AuthDatasource` and, after a successful sign-in, `GetSignupStepUseCase` (profile's public API).
  - Unverified account: the cubit sends a new code with `resendSignUpCode` and pushes `AppRoutes.verifyEmailAt(email)` = `/register?step=2&email=...`. **Phase 6 must read `step=2` and `email` from the query.** Success uses `resetTo`; this one uses `push`, so back returns to Sign in.
  - New string not in the spec: `errorNetwork` ("No connection. Check your internet and try again.", Arabic `x-review`), shown in a snackbar for a network or timeout failure; other failures use `errorGeneric`. Both come from `Failure.l10n(context)` (`lib/core/extensions/failure_l10n.dart`). Please approve or reword.
  - `OrDivider` (Phase 2) overflowed at 1.5x text on a 320 dp phone; its label now wraps (max 60% of the window width, `AuthDimens.dividerLabelMaxShare`). It is not a `LayoutBuilder` because `SliverFillRemaining` asks for intrinsic sizes.
  - Layout gaps 56 / 32 / 24 / 20 / 28 are in `AuthDimens` (`signIn*`); the 56 top gap is still `[estimated]` in the spec.
  - Tests: 16 cubit tests, 12 screen tests (EN, AR, small phone at 1.5x text), countdown formatter; full suite 455 green, `flutter analyze` clean.


### Phase 5: Forgot password (S2 + S9)
**Status:** [x] (screenshot comparison on a device still to do)
- **Goal:** S2 and the S9 dialog match the screenshots and request a reset email.
- **Depends on:** Phases 2, 3, 4 (for the sign-in target).
- **Spec refs:** `screens/s2-forgot-password.md`, `screens/s9-forgot-password-sent-dialog.md`, `02-components.md` (C2, C14), `01-design-tokens.md`.
- **Tasks:**
  - [x] `ForgotPasswordScreen` + Cubit on `/forgot-password`: send disabled until the email is non-empty, loading, invalid-format and request errors per spec, pinned "Back to sign in".
  - [x] S9 as custom content inside `AppDialogShell`: masked email, "Open email app" (`mailto:`, snackbar "No email app found" on failure), "Back to sign in" (`resetTo('/sign-in')`), "Resend link" with 30 s cooldown and "Link sent again" snackbar, "Change email" (close + focus the email field), barrier tap closes.
  - [x] Strings (EN + AR drafts).
- **Out of scope:** the emailed link and S11 (Phase 9).
- **Done when:** the S2 and S9 acceptance checklists pass; the dialog blurs and dims S2; RTL flips the back arrow.
- **Verify:** Cubit tests (send, error, cooldown countdown with fake timers); widget tests EN + AR; compare to `s2` and `s9` screenshots.
- **Notes (builder):**
  - Built: `ForgotPasswordScreen` / `ForgotPasswordView` / `ForgotPasswordCubit` (freezed state: email, loading, `invalidEmail`, `failure`, `cooldown`, one-shots `sentTo` and `message`, `focusRequest`), the S9 `ResetLinkSentDialog`, which is a second view of the same `ForgotPasswordCubit` (30 s cooldown, resend, open mail app; one flow, one cubit, so the cooldown lives with the screen and reopening the dialog does not skip it), the shared `LaunchService` (`core/services/launch_service.dart`, interface + `url_launcher` implementation in one file, so Cubits are tested without a platform; one method per use, e.g. `openEmailApp()`; a new use is a new method), and shared `AuthBackButton` (extracted from `StepTopBar`), `isValidEmail`, `boldSpans` (extracted from `AuthHeader`).
  - Flow: Send validates the format first ("Enter a valid email", no request), then `sendPasswordReset`; success opens S9 over S2; a failed request shows the "Something went wrong. Try again." snackbar. "Change email" returns `true` from the dialog and the view focuses (and selects) the field.
  - S9 snackbars ("Link sent again", "No email app found", resend failure): the dialog route has its own `ScaffoldMessenger` + transparent `Scaffold`, so they show above the scrim and not twice. Barrier tap still closes the dialog (tested).
  - New strings beyond the spec: `errorInvalidEmail` key name (text "Enter a valid email" is from the S3/S2 spec, Arabic `x-review`) and `noEmailApp`. The S2/S9 `[estimated]` texts and the 30 s cooldown are unchanged.
  - Cleanup after Phase 5: the sign-in throttle and the resend cooldown shared the same timer code, now one `Countdown` helper (`auth/presentation/utils/countdown.dart`, used by composition) that the Verify email resend (Phase 6) should reuse.
  - Tests: 5 + 6 cubit tests, 12 screen/dialog tests (EN, AR/RTL, 320 dp at 1.5x text), email format; full suite 478 green, `flutter analyze` clean. `/forgot-password` removed from the placeholder route test.


### Phase 6: Sign-up shell, Account (S3) and Verify email (S4)
**Status:** [x] (screenshot comparison on a device and the real end-to-end check with B1 are still to do)
- **Goal:** the `SignUpFlow` screen with the shared step bar, hosting S3 and S4.
- **Depends on:** Phases 2, 3. B1 only for the real end-to-end check.
- **Spec refs:** `screens/s3-signup-account.md`, `screens/s4-signup-verify-email.md`, `00-overview.md` (Structure, Back rules), `02-components.md` (C7-C10, C15).
- **Tasks:**
  - [ ] Build the sign-up flow inside `features/auth/presentation/` (the Terms / Privacy placeholders are already there). `SignUpCubit` calls `AuthDatasource` (its own feature) directly and `profile` only through use cases that `profile` exposes for it, named by intent (for example check the username and save About you, advancing the step; save the profile details and photo; save interests; follow), a one-way `auth` → `profile` dependency. It never imports `ProfileDatasource` or `ProfileEntity`.
  - [ ] The widgets and helpers from Phase 2 stay where they are: sign-in and sign-up are both in `auth`, so nothing moves to `core/`.
  - [ ] `SignUpFlow` screen on `/register` providing one `SignUpCubit`; steps swap without swiping; the step bar progress animates and fills right to left in RTL. Steps 5-8 can render a stub until their phases.
  - [ ] Back handling: step 3's arrow and system back on steps 3-8 will open S10 (wired in Phase 8); on S3 the arrow leaves the flow; on S4 the arrow goes to S3.
  - [ ] S3: fields, strength meter hidden until typing, terms checkbox (links open `/terms` and `/privacy`), Continue enabled when email valid + password >= 8 + checkbox checked, errors (invalid email, short password, email exists), "Sign in" link, social "Coming soon". Continue -> sign up -> S4.
  - [ ] S4: masked email subtitle, 6-box OTP (paste, autofill, backspace), Verify disabled until 6 digits, wrong-code error, 30 s resend cooldown "Resend code in 0:30", "Use a different email" and back -> S3 with the email kept. Verify -> step 3. S4 is not revisitable afterwards.
  - [ ] Entry from S1 for unverified emails opens S4 with that email.
  - [ ] Strings (EN + AR drafts).
- **Out of scope:** steps 3-8 content, S10.
- **Done when:** S3 and S4 acceptance checklists pass; boxes shrink to fit narrow widths (min 44); OTP stays LTR in RTL.
- **Verify:** Cubit tests (enable rules, strength, email exists, wrong code, cooldown, step transitions); widget tests EN + AR + 1.5x text scale; compare to `s3`, `s4` screenshots; real verification once B1 is done.

### Phase 7: About you (S5) and Profile (S6)
**Status:** [x] (screenshot comparison on a device still to do; the interests-empty skip after S6 moves to Phase 8, see below)
- **Goal:** steps 3 and 4 save to Supabase through `profile`'s use cases.
- **Depends on:** Phase 6.
- **Spec refs:** `screens/s5-signup-about-you.md`, `screens/s6-signup-profile.md`, `02-components.md` (C3, C11, C13).
- **Tasks:**
  - [ ] Add the `profile` use cases the flow calls, named by intent and returning the smallest useful type (indicative: `SaveAboutYouUseCase` = check the username is available, then save the About-you fields and advance the step; `SaveProfileDetailsUseCase` = upload the photo if one was picked, save bio / city / phone, advance the step). The flow never imports `ProfileRepository`, `ProfileDatasource`, `ProfileModel` or `ProfileEntity`. Tests: use case tests over a mocked `ProfileRepository` for the rules (taken username, order of calls, advance step).
  - [ ] S5: full name, username with "@" prefix (pattern, lowercase, uniqueness check on Continue, "Username is taken"), birthday via `showDatePicker` (1900..today, min age 18 error), gender chips (single select, tap again clears). Continue saves the fields and sets `signup_step` to 4. Back arrow and system back open S10 (hook is added in Phase 8; until then they leave via a temporary stub that Phase 8 removes).
  - [ ] S6: `PhotoPickerAvatar` (C13) with the bottom sheet (Take photo, Choose from gallery, Remove photo) via `image_picker`, bio with 150 limit + live counter, city max 60, phone validation (7-15 digits, LTR). Continue always enabled; Skip -> step 5; back -> step 3. Continue uploads the photo and saves bio/city/phone (phone spaces stripped); Skip saves nothing. Either then loads the interests: empty -> skip step 5 (`signup_step` 6), otherwise `signup_step` 5 and the list is handed to S7.
  - [ ] Strings (EN + AR drafts).
- **Out of scope:** none beyond the screens.
- **Done when:** S5 and S6 acceptance checklists pass; "@" and username LTR in RTL; the date picker follows the locale.
- **Verify:** Cubit tests (validation, taken username, age, phone, counter, photo set/remove); widget tests EN + AR; compare to `s5`, `s6` screenshots.

### Phase 8: Interests (S7), Follow (S8) and Leave dialog (S10)
**Status:** [x] (screenshot comparison on a device and a live run against Supabase are still to do)
- **Goal:** the last two steps, the Home hand-off and the leave-confirmation behavior across steps 3-8 (S10 copy now says progress is saved; resume is at the saved step).
- **Depends on:** Phase 7.
- **Spec refs:** `screens/s7-signup-interests.md`, `screens/s8-signup-follow.md`, `screens/s10-leave-signup-dialog.md`, `02-components.md` (C11, C12, C14, C15), `00-overview.md` (Navigation map).
- **Tasks:**
  - [ ] Add the remaining `profile` use cases the flow calls (indicative: load the interests and decide whether S7 is skipped; save the picked interests and advance the step; load the suggestions for a tab and decide whether S8 is skipped; follow / unfollow / follow all). A thin cross-feature entry is allowed, but none is created for a method the flow does not call. The Leave action calls `ClearLocalProfileUseCase` and then signs out through `AuthDatasource` (its own feature).
  - [ ] S7: interests come from the `interests` table (names by locale, ordered by `sort_order`), loaded on step 4 Continue/Skip so S7 is skipped when empty; keep the error + Retry state for a failed load, loading skeletons, error + Retry, multi-select, "{n} selected" caption hidden at 0, Skip/Continue -> step 6.
  - [ ] S8: tabs Suggested / From contacts ("Coming soon", no permission request) / Popular, `AvatarInitials` + `FollowRow` in the white card, Follow/Following toggle, "Follow all", loading and error states, avatar color from a stable hash of the user id, meta line from `reason_kind` (mutual friends or city, hidden otherwise), pinned bar with hairline and hint caption. Suggested/popular profiles are loaded on step 5 Continue/Skip, and S8 is skipped (straight to `/home`, `signup_step` 0) when both are empty; an empty tab shows a message only. Continue and Skip -> `/home` via `resetTo`. `signup_step` becomes 6 after S7 and 0 when S8 is left or skipped.
  - [ ] S10 with `ConfirmationDialog.destructive(icon: warning, ...)`: wire it to step 3's arrow and to system back on steps 3-8. Keep going / barrier / back close it; Leave signs out then `resetTo('/sign-in')`. Remove the temporary stub from Phase 7.
  - [ ] Back arrow on steps 4-8 goes to the previous step (unchanged).
  - [ ] Strings (EN + AR drafts, ICU plurals for `mutualFriends`).
- **Out of scope:** contacts matching.
- **Done when:** S7, S8 and S10 acceptance checklists pass; the Leave button is on the end side (mirrors in RTL); the pinned bar rises over the keyboard where relevant.
- **Verify:** Cubit tests (selection, skip-when-empty for S7 and S8, follow all, unfollow, leave flow, back rules); widget tests EN + AR; compare to `s7`, `s8`, `s10` screenshots.

### Phase 9: Set new password (S11) and Password updated (S12)
**Status:** [x] (screenshot comparison on a device and a real recovery link are still to do; the link itself is Phase 10 / B4)
- **Goal:** the reset-password screen works once a recovery session exists, finishing in the S12 dialog.
- **Depends on:** Phases 2, 3, 4.
- **Spec refs:** `screens/s11-set-new-password.md`, `screens/s12-password-updated-dialog.md`, `02-components.md` (C2, C8, C8b, C9, C14).
- **Tasks:**
  - [ ] `ResetPasswordScreen` + Cubit on `/reset-password`: X (not an arrow) at the start, key tile, masked email from the recovery session, short strength segments, 3-rule list with met state, confirm field with mismatch error, "Log out of all other devices" checkbox (default checked), Update enabled when the 3 rules are met and the confirm matches, loading, request error snackbar.
  - [ ] Update: update the password; if the checkbox is checked, sign out other sessions; success -> S12.
  - [ ] S12 with `ConfirmationDialog.info(dismissible: false)`: body variant by checkbox value; "Sign in" signs out the recovery session and `resetTo('/sign-in')`. X does the same sign-out and navigation without confirmation.
  - [ ] Expired/invalid-link state per the S11 spec: shown when no recovery session exists on `/reset-password`; button -> `/forgot-password`.
  - [ ] Strings (EN + AR drafts).
- **Out of scope:** receiving the email link (Phase 10, B4).
- **Done when:** S11 and S12 acceptance checklists pass; barrier tap and Android back do nothing on S12; the X moves to the right in RTL.
- **Verify:** Cubit tests (rules, mismatch, enable, both checkbox paths, error); widget tests EN + AR; compare to `s11`, `s12` screenshots.

### Phase 10: Integration
**Status:** [~] (code done and tested with mocks; the two blocked items B1 and B4 need your dashboard steps and a device run)
- **Goal:** the flows work end to end and the flows are verified against the real backend.
- **Depends on:** Phases 4-9. **B1** (real OTP), **B4** (deep link and expired-link state).
- **Spec refs:** `00-overview.md` (Navigation map, Resume), `open-questions.md` (Q2, Q13), all screens' navigation sections.
- **Tasks:**
  - [x] Walk every arrow in the navigation map and fix mismatches (including S9 -> S1, S11 -> S1, S10 leave, resume at step 3).
  - [x] Confirm `app.dart` starts at `/` and the start-up decision from Phase 3 behaves for: first launch, no session, complete session, incomplete session.
  - [~] **[blocked: B4]** Recovery deep link: URL scheme and native configuration (Android + iOS) and the route to `/reset-password` on the recovery event are done; still yours: add `pulse://reset-password` to the Supabase redirect URLs (dashboard) and try a real link on a device.
  - [ ] **[blocked: B1]** Real sign-up -> OTP -> profile run.
- **Out of scope:** new features, social login.
- **Done when:** a new user can register through step 6 and land on `/home`; a returning user signs in; reset via an emailed link ends in S12 and `/sign-in`. Blocked items remain listed as blocked until their blockers close.
- **Verify:** app-level tests with `bootApp` for the unblocked paths; manual run on a device with Supabase.

### Phase 11: Polish
**Status:** [ ]
- **Goal:** consistency across all auth screens.
- **Depends on:** Phase 10 (unblocked parts).
- **Spec refs:** all `screens/*.md` acceptance checklists, `_theme/rtl.md`, `01-design-tokens.md`.
- **Tasks:**
  - [ ] Compare every screen with its screenshot at 390 x 844 and fix `[estimated]` values that differ (Q8), including the loading view's 32 dp / stroke 3 on the splash (Q22).
  - [ ] RTL pass: mirrors vs forced-LTR content (email, username, phone, OTP, @), progress bar direction, dialog button order.
  - [ ] Accessibility pass: Semantics labels, >= 44 tap targets, focus order, dialog focus (cancel first for destructive), text scale 1.5-2.0 with no overflow on 360 x 640.
  - [ ] Animation pass: step progress ~200 ms, dialog fade/scale 180 ms.
  - [ ] Replace temporary stubs/placeholders that are no longer needed.
- **Out of scope:** new screens, dark mode.
- **Done when:** all acceptance checklists are ticked in the running app; `fvm flutter analyze` and `fvm flutter test` pass.
- **Verify:** full manual pass in EN and AR; the full test suite.

## Verification
- Every phase: `fvm flutter analyze` clean and `fvm flutter test` green before ticking its Status.
- Cubit logic with `bloc_test` + mocktail; views with `pumpApp` / `setUpView` for size, text scale and locale; assertions use generated l10n strings (`l10nEn` / `l10nAr`), not literals.
- Screens are compared to `docs/specs/auth/screenshots/<screen>.png`; each phase ends by ticking its screens' acceptance checklists in the running app.
- Real-backend checks (S1 sign-in, S4 OTP, S9 / S11 emailed link) are done only when their blockers (B1, B2, B4) are closed; until then those checks use mocked datasources.

## Follow feature (follow requests)
`lib/features/follow/` owns the follow toggle, "Follow all", suggestions and follow requests (migration `20261010120000_follow_requests.sql`): public profile = instant follow, private (`profiles.is_private`) = pending request the owner accepts or declines. The sign-up Follow step uses `ToggleFollowUseCase` and `FollowAllUseCase`. Deferred until Home exists: the Activity screen (with the "Follow requests" row and badge from `GetFollowRequestCountUseCase`), the Follow requests screen (`GetFollowRequestsUseCase`, `RespondToFollowRequestUseCase`, "Accept all"), and the private-account toggle.
