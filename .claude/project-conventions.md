# Project Conventions

New project scaffolded from the flutter-app-builder defaults (Phase 0 of docs/plans/onboarding-plan.md). Specs: docs/specs/ (theme in `_theme/`, features in `<feature>/`). Plan: docs/plans/.

## Architecture
Feature-first: `lib/features/<feature>/{data,domain,presentation}`, shared code in `lib/core/`, entry in `lib/app/`. A feature is a capability, not a table (interests and follows belong to `profile`). Add repository / entity / use case only when needed.

## State
Local UI state: setState / ValueNotifier. Feature state: `flutter_bloc` Cubit (Cubits extend `BaseCubit` in `lib/core/state/`, minimal: only the emit-after-close guard; first one: `OnboardingCubit`; `bloc_test` + mocktail for tests). Add `run()` to `BaseCubit` when the first backend feature adds Failure/Either/Dio; freezed (`freezed_annotation` + `freezed`) is used only for a state with data that must survive (first: `SignInState`; single `@freezed abstract class`, nullable fields reset with `copyWith(x: null)`); simple states stay hand-written `Equatable` like `SplashState`.

## Navigation
Start: `AppRoutes.root` (`/`) resolves in `AppRouter` to `/onboarding` (first launch) or `SplashScreen` in `features/splash` (flag `onboarding_seen` set), which picks `/sign-in`, `/home` or `/register?step=N`. `/sign-in` and `/register` are `PlaceholderScreen`s until those screens are specced. Leaving onboarding uses `AppNavigator.resetTo`.
Built-in Navigator. Routes in `lib/core/router/` (`AppRoutes`, `AppRouter.onGenerateRoute`, `AppNavigator`). No routing package.

## DI
get_it + injectable. `lib/core/di/injection.dart`; generated `injection.config.dart` via `dart run build_runner build --delete-conflicting-outputs`.

## Text styles
All `AppTextStyles` are `inherit: false` (Material's ambient text theme must not add letter spacing/height). CSS shorthand in the specs: `a b c` = top a, sides b, bottom c.

## Widgets
Shared (2+ features): `lib/core/widgets/` with barrel `widgets.dart` (`AppSvgIcon`, `PrimaryButton`). Feature-only widgets: `features/<f>/presentation/widgets/` (onboarding: `OnboardingTopBar`, `OnboardingPanel`, `OnboardingTextBlock`, `PageDots`, `SignInLink`).

## Onboarding
`features/onboarding/presentation/`: `screen/onboarding_screen.dart` (route `/onboarding`) -> `view/onboarding_view.dart` (PageView, page index in a ValueNotifier) ; page data list in `utils/onboarding_page.dart`; widgets in `widgets/`. `app.dart` initialRoute is temporarily `/onboarding` until Phase 7.

## Config
`lib/core/constants/app_config.dart` (`AppConfig`): Supabase URL + publishable key as constants (public by design). Auth feature: `docs/plans/auth-plan.md`; routes `/forgot-password`, `/reset-password`, `/home` are `PlaceholderScreen`s until their phases; `/terms` and `/privacy` use `LegalPlaceholderScreen` (`features/auth/presentation/screen/`).

## Data layer and flows
A datasource per concern, each an **interface plus an adapter in one file**: `auth_datasource.dart` holds `AuthDatasource` + `SupabaseAuthDatasource` (`features/auth/data/datasource/`); `profile_datasource.dart`, `interests_datasource.dart`, `follows_datasource.dart` do the same in `features/profile/data/datasource/`. Interfaces are `abstract interface class`, adapters `final class` bound with `@LazySingleton(as: …)`. They return `Result<T>` and **wire models** (`data/model/…_model.dart`, hand-written `fromJson`/`toJson`; enums in `data/enums/` own their wire values); the adapter holds the Supabase calls. **A repository only where a source is coordinated**: `ProfileRepository` (`data/repository/profile_repository.dart`, abstract + `ProfileRepositoryImpl` in one file) writes through to `ProfileLocalDatasource` (a concrete class over `LocalStorageService`, one entry per user, never phone or birthday), reads network-first and falls back to the copy only on a lost connection, and maps `ProfileModel` -> `ProfileEntity` and `ProfileUpdateEntity` -> `ProfileUpdateModel` itself (private `_toEntity` / `_toUpdateModel` in the repository; a model never has `toEntity()` and never imports `domain/`) (`domain/entity`, only where the concept differs from the model: interests and suggested profiles are used as models). **Features trade only through use cases** (`domain/use_case/`, `@injectable`, named by intent, returning the smallest useful type): `features/splash` (first-route decision) calls `IsSignedInUseCase` (`auth`) and `GetSignupStepUseCase` (`profile`); the sign-up flow (S3-S8) lives in `features/auth/presentation` and calls profile use cases one way (`auth` -> `profile`); `ClearLocalProfileUseCase` is what a sign-out flow calls first. No feature imports another's datasource, repository, model or entities; `profile` never imports `auth` or `splash`. Inside a feature a Cubit or use case calls its own repository / datasources. Supabase is initialized in `main()`; `SupabaseClient` comes from `AppModule`. Datasource tests drive the real client against a canned HTTP backend (`test/helpers/backend_double.dart`); `bootApp` registers signed-out mock datasources.

## Loading
Splash (S13): `SplashState` is deciding / go(route) / failed(`SplashProblem`); `SplashCubit.retry()` re-runs `decide()` (network or timeout -> offline, session expired -> sign in, anything else -> can't reach); `SplashScreen` -> `SplashView` -> `SplashLoading` / `SplashProblemView`. Shared by two features now, in `core/widgets/`: `PinnedBottomCta`, `LogoTile` (`.large()` for the splash), `LogoLockup`.

One loader: `AppSpinner` (`core/widgets/`) is the only place a `CircularProgressIndicator` is built; `AppLoadingView` is the centered, labelled screen-body version (splash, first-data waits); `PrimaryButton`'s loading state reuses `AppSpinner`. A method called in `BlocProvider.create` (`..decide()`) yields before its first emit so the `BlocListener` is subscribed first (`SplashCubit`).

## Errors
`ErrorReporter` (lib/core/error/) + global handlers in `main.dart`. Failure/Result/Guard not added yet (no data layer).

## Localization
gen-l10n: `lib/l10n/app_en.arb` (template), `app_ar.arb`. Read strings with `context.l10n` from `lib/core/extensions/l10n.dart`. Arabic strings in `app_ar.arb` are drafts tagged with `x-review` metadata until the user approves them. `App` falls back to English for unsupported device languages.

## UI
Implemented (Phase 1): `lib/core/theme/{app_colors,app_text_styles,app_dimens,app_theme}.dart`, `lib/core/constants/app_assets.dart`, `lib/core/extensions/context_extensions.dart`. Colors: `context.appColors.<token>` (ThemeExtension, light only). Text: `context.text.<style>` (no color; Arabic set picked by locale). Dimens: `AppSpacing`, `AppRadius`, `AppShadows`, `OnboardingDimens`.
Tokens/theme go in `lib/core/theme/` (app_colors, app_text_styles, app_dimens) and asset paths in `lib/core/constants/app_assets.dart`, per docs/specs/_theme/. RTL rules: docs/specs/_theme/rtl.md.

## Testing
`test/` mirrors `lib/`; helpers in `test/helpers/pump_app.dart` (`pumpApp`, `bootApp` for the real wiring, `setUpView` for size/insets/text scale/device locale, `l10nEn`/`l10nAr`). mocktail for mocks. Widget tests pump the view with callbacks; app-level tests boot `App` with `SharedPreferences.setMockInitialValues`. Assert against generated l10n strings, not literals.

## Tooling
Flutter via FVM: run `fvm flutter ...` / `fvm dart ...`.

## File placement
Enums: one per file, shared ones in `lib/core/enums/` (never in a widgets folder; e.g. `PillButtonVariant`), data/enums/ (data) or presentation/utils/enums/ (never inside a widget file); a presentation-only enum owns its facts, `l10n(context)` label and `color(context)` as members (no extension); a data enum's label/icon/color go in one extension in presentation/utils/l10n/<enum>_l10n.dart. Models: data/model/. Datasources: data/datasource/. Screens: presentation/screen/, views: presentation/view/. Illustrations: assets/images/onboarding/{en,ar}/ (placeholder names, user will edit). Fonts: assets/fonts/ (Sora, NotoSans, NotoSansArabic, declared in pubspec). Note: `flutter test` renders the Ahem block font unless a test loads fonts with `FontLoader`.

## Notes
`pinput` is pinned to ^6.0.2: 7.x needs the separate `material_ui` package (its `Material` is a different class from `flutter/material.dart`'s), so its debug assertions fail here. Auth form widgets: `AppTextField`, `SelectableChip`, `PillButton` (`.outline` / `.soft` / `.danger`), `AppDialogShell` in `core/widgets/` and `ConfirmationDialog` + its strategies in `core/widgets/confirmation_dialog/` (a widget with several related files gets its own folder); step bar, OTP, strength meter, rules list, checkbox, header and tiles in `features/auth/presentation/widgets/`. Tests at the design frame use `testView` (`test/helpers/pump_app.dart`).
`SharedPreferences` is `@preResolve` in `lib/app/app_module.dart`, so `configureDependencies()` is async and `main()` awaits it. All `SharedPreferences` access goes through the shared `LocalStorageService` (abstract, `lib/core/services/local_storage_service.dart` with `SharedPrefsStorageService` in the same file, keys in `storage_keys.dart`; `getValue<T>` / `setValue` (type argument; `decode` / `encode` for enums and models), no keys); each datasource owns its keys. Local flags go through a datasource (e.g. `OnboardingDatasource`) called by a Cubit (`OnboardingCubit`, `flutter_bloc`, plain `Cubit<T>`, no freezed/BaseCubit yet), never from widgets; a screen provides its Cubit with `BlocProvider(create: (_) => getIt<…>())`, and `AppRouter` also reads `OnboardingDatasource.isSeen` at start-up. Tests that boot the app call `SharedPreferences.resetStatic()` + `setMockInitialValues` and `getIt.reset()` first, and use `App(key: UniqueKey())` to force a fresh Navigator.

## Core folders
`lib/core/`: `constants/` (app_assets, app_config), `di/`, `enums/` (shared enums), `error/` (Failure, Result, Guard, ErrorReporter), `extensions/`, `router/`, `services/` (things that talk to the device: `LaunchService`, `LocalStorageService` + `StorageKeys`; an interface and its implementation share one file), `state/` (`BaseCubit`), `theme/`, `utils/` (pure Dart: Either, Equatable, JsonMapper), `widgets/`.
