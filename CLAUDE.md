# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Flutter is pinned through FVM (`.fvmrc`), so always prefix with `fvm`.

```
fvm flutter pub get
fvm flutter run
fvm flutter analyze                      # flutter_lints; build/, android/, ios/ excluded
fvm flutter test                         # all tests
fvm flutter test test/features/onboarding/presentation/cubit/onboarding_cubit_test.dart   # one file
fvm flutter test --plain-name "some test name"
fvm dart run build_runner build --delete-conflicting-outputs   # regenerate lib/core/di/injection.config.dart after changing @injectable classes / @module
fvm flutter gen-l10n                     # normally automatic (flutter: generate: true)
```

## Architecture

Feature-first Flutter app (EN + AR, light theme only): `lib/features/<feature>/{data,presentation}`, shared code in `lib/core/`, entry in `lib/app/`. Add repository/entity/use-case layers only when a feature needs them. `.claude/project-conventions.md` holds the detailed conventions; specs live in `docs/specs/` (theme in `_theme/`, per-feature folders) and implementation plans in `docs/plans/`. Treat the specs and screenshots as the source of truth for UI.

- **State:** local UI state via `setState`/`ValueNotifier`; feature state via `flutter_bloc` Cubits. `BaseCubit` (`lib/core/state/`) only guards emit-after-close; `run()`/Failure/Either/Dio/freezed are deliberately not added until a backend feature needs them. Widgets never touch `SharedPreferences` directly: they go through a datasource called by a Cubit.
- **DI:** get_it + injectable (`lib/core/di/injection.dart`, generated `injection.config.dart`). `SharedPreferences` is `@preResolve` in `lib/app/app_module.dart`, so `configureDependencies()` is async and `main()` awaits it. A screen provides its Cubit with `BlocProvider(create: (_) => getIt<…>())`.
- **Navigation:** built-in Navigator, no routing package. All routes (including deep links) resolve in `AppRouter.onGenerateRoute` (`lib/core/router/`); `/` picks `/onboarding` or `/sign-in` based on the `onboarding_seen` flag. Leave flows with `AppNavigator.resetTo`. `/sign-in` and `/register` are `PlaceholderScreen`s until specced.
- **Errors:** `ErrorReporter` + global handlers (`FlutterError.onError`, `PlatformDispatcher.onError`) in `lib/main.dart`.
- **Theme:** tokens in `lib/core/theme/`. Use `context.appColors.<token>` (ThemeExtension), `context.text.<style>` (no color; Arabic set chosen by locale), `AppSpacing`/`AppRadius`/`AppShadows`. All `AppTextStyles` are `inherit: false` on purpose. Fonts: Sora (headings), Noto Sans, Noto Sans Arabic. RTL rules: `docs/specs/_theme/rtl.md`. Asset paths go in `lib/core/constants/app_assets.dart`.
- **Localization:** gen-l10n from `lib/l10n/app_en.arb` (template) and `app_ar.arb`; read via `context.l10n`. Arabic strings are drafts tagged `x-review` until the user approves them. Unsupported device locales fall back to English.
- **Widgets:** shared (used by 2+ features) in `lib/core/widgets/` with barrel `widgets.dart`; feature-only widgets in `features/<f>/presentation/widgets/`. File placement: `data/{datasource,model,enums}`, `presentation/{screen,view,cubit,widgets,utils/enums}`; screen provides the Cubit, view is the pure UI.

## Testing

`test/` mirrors `lib/`; helpers in `test/helpers/pump_app.dart` (`pumpApp`, `bootApp` for real wiring, `setUpView`, `l10nEn`/`l10nAr`). Uses mocktail and bloc_test. Tests that boot the app must call `SharedPreferences.resetStatic()` + `setMockInitialValues` and `getIt.reset()` first, and use `App(key: UniqueKey())` for a fresh Navigator. Assert against generated l10n strings, not literals. `flutter test` renders the Ahem block font unless the test loads fonts with `FontLoader`.

## Known state

`lib/app/app.dart` has `initialRoute` temporarily set to `/onboarding` (plan Phase 7 restores start-up routing via `/`). `.claude/project-conventions.md` has a stale note saying there is no `BaseCubit` yet; it exists in `lib/core/state/base_cubit.dart`.
