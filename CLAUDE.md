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

Feature-first Flutter app (EN + AR, light theme only): `lib/features/<feature>/{data,domain,presentation}`, shared code in `lib/core/`, entry in `lib/app/`. A feature is an application capability, not a table. Add repository/entity/use-case layers only when a feature needs them (a repository only for caching, sync, combining sources or real transformation; a use case only for real business rules). `.claude/project-conventions.md` holds the detailed conventions; specs live in `docs/specs/` (theme in `_theme/`, per-feature folders) and implementation plans in `docs/plans/`. Treat the specs and screenshots as the source of truth for UI. UI specs live in `docs/specs/<feature>` (auth: `docs/specs/auth`); read its `00-overview.md` before UI work; never guess values, ask.

- **State:** local UI state via `setState`/`ValueNotifier`; feature state via `flutter_bloc` Cubits. `BaseCubit` (`lib/core/state/`) guards emit-after-close and has `run(action, {loading, onSuccess, onFailure})`: it awaits a call that returns its value or throws a `Failure`, and emits the state a callback returns (a callback returning null emits nothing, it handled the result itself); other errors reach `onFailure` as a `Failure` via `Guard.toFailure`. freezed is used only for states that carry data (`SignInState`); simple ones stay hand-written `Equatable` (`SplashState`); run `build_runner` after changing a `@freezed` class. Data access: a datasource per concern, each an interface plus a Supabase adapter in one file (`auth_datasource.dart`; `profile_datasource.dart`, `interests_datasource.dart`, `follows_datasource.dart` in `features/profile`), bound in DI, returning wire `data/model` classes (enums with their wire values in `data/enums`). Data calls return the plain value (`Future<void>` for none) and throw a `Failure` (an `Exception`, `lib/core/error/`); `Guard.run` turns exceptions into `Failure`s. No `Either`/`Result`. `profile` also has a **repository** because it coordinates a remote and a local source: `ProfileRepository` (abstract + `…Impl`, one file) saves every read and write on the device (`ProfileLocalDatasource`, no phone or birthday), falls back to that copy only when the connection fails, and maps `ProfileModel` to `ProfileEntity` (`domain/entity`, only where the concept differs from the model). Features trade only through use cases (`domain/use_case/`, a feature's public API): `splash` calls `IsSignedInUseCase` (auth) and `GetSignupStepUseCase` (profile), so it never sees the profile; the sign-up flow in `auth` will call profile use cases. No feature imports another's datasource, repository or entities, and `profile` never imports `auth` or `splash`. Supabase is initialized in `main()`; no Dio. Widgets never touch `SharedPreferences` directly: they go through a datasource called by a Cubit.
- **DI:** get_it + injectable (`lib/core/di/injection.dart`, generated `injection.config.dart`). `SharedPreferences` is `@preResolve` in `lib/app/app_module.dart`, so `configureDependencies()` is async and `main()` awaits it. A screen provides its Cubit with `BlocProvider(create: (_) => getIt<…>())`.
- **Navigation:** built-in Navigator, no routing package. All routes (including deep links) resolve in `AppRouter.onGenerateRoute` (`lib/core/router/`); `/` opens `/onboarding` until the `onboarding_seen` flag is set, then `SplashScreen` (`features/splash`), which picks `/sign-in`, `/home` or `/register?step=N` from the stored session and `profiles.signup_step`. Leave flows with `AppNavigator.resetTo`. `/sign-in` and `/register` are `PlaceholderScreen`s until specced.
- **Errors:** `ErrorReporter` + global handlers (`FlutterError.onError`, `PlatformDispatcher.onError`) in `lib/main.dart`.
- **Theme:** tokens in `lib/core/theme/`. Use `context.appColors.<token>` (ThemeExtension), `context.text.<style>` (no color; Arabic set chosen by locale), `AppSpacing`/`AppRadius`/`AppShadows`. All `AppTextStyles` are `inherit: false` on purpose. Fonts: Sora (headings), Noto Sans, Noto Sans Arabic. RTL rules: `docs/specs/_theme/rtl.md`. Asset paths go in `lib/core/constants/app_assets.dart`.
- **Localization:** gen-l10n from `lib/l10n/app_en.arb` (template) and `app_ar.arb`; read via `context.l10n`. Arabic strings are drafts tagged `x-review` until the user approves them. Unsupported device locales fall back to English.
- **Widgets:** shared (used by 2+ features) in `lib/core/widgets/` with barrel `widgets.dart`; feature-only widgets in `features/<f>/presentation/widgets/`. File placement: `data/{datasource,model,enums}`, `presentation/{screen,view,cubit,widgets,utils/enums}`; screen provides the Cubit, view is the UI and reads its own Cubit through small `BlocSelector`/`BlocBuilder` widgets, and the screen holds the `BlocListener` for one-shot effects (navigation, snackbar, dialog).

## Testing

`test/` mirrors `lib/`; helpers in `test/helpers/pump_app.dart` (`pumpApp`, `bootApp` for real wiring, `setUpView`, `l10nEn`/`l10nAr`). Uses mocktail and bloc_test. Tests that boot the app must call `SharedPreferences.resetStatic()` + `setMockInitialValues` and `getIt.reset()` first, and use `App(key: UniqueKey())` for a fresh Navigator. Assert against generated l10n strings, not literals. `flutter test` renders the Ahem block font unless the test loads fonts with `FontLoader`.

## Known state

`lib/app/app.dart` starts at `/` (start-up routing is live) and listens for the password-recovery event (`WatchPasswordRecoveryUseCase`) to open `/reset-password`. The reset link is `pulse://reset-password`: native scheme set in `AndroidManifest.xml` / `Info.plist` (Flutter's own deep-link routing is off; `supabase_flutter` reads the link). `.claude/project-conventions.md` is an index; the area files are in `.claude/conventions/`.
