# Project Conventions

New project scaffolded from the flutter-app-builder defaults (Phase 0 of docs/plans/onboarding-plan.md). Specs: docs/specs/ (theme in `_theme/`, features in `<feature>/`). Plan: docs/plans/.

## Architecture
Feature-first: `lib/features/<feature>/{data,presentation}`, shared code in `lib/core/`, entry in `lib/app/`. Add repository / entity / use case only when needed.

## State
Local UI state: setState / ValueNotifier. Feature state: `flutter_bloc` Cubit (Cubits extend `BaseCubit` in `lib/core/state/`, minimal: only the emit-after-close guard; first one: `OnboardingCubit`; `bloc_test` + mocktail for tests). Add `run()` to `BaseCubit` when the first backend feature adds Failure/Either/Dio; add freezed only when a feature needs it.

## Navigation
Start-up: `AppRoutes.root` (`/`) resolves in `AppRouter` to `/onboarding` (first launch) or `/sign-in` (flag `onboarding_seen` set). `/sign-in` and `/register` are `PlaceholderScreen`s until those screens are specced. Leaving onboarding uses `AppNavigator.resetTo`.
Built-in Navigator. Routes in `lib/core/router/` (`AppRoutes`, `AppRouter.onGenerateRoute`, `AppNavigator`). No routing package.

## DI
get_it + injectable. `lib/core/di/injection.dart`; generated `injection.config.dart` via `dart run build_runner build --delete-conflicting-outputs`.

## Text styles
All `AppTextStyles` are `inherit: false` (Material's ambient text theme must not add letter spacing/height). CSS shorthand in the specs: `a b c` = top a, sides b, bottom c.

## Widgets
Shared (2+ features): `lib/core/widgets/` with barrel `widgets.dart` (`AppSvgIcon`, `PrimaryButton`). Feature-only widgets: `features/<f>/presentation/widgets/` (onboarding: `OnboardingTopBar`, `OnboardingPanel`, `OnboardingTextBlock`, `PageDots`, `SignInLink`).

## Onboarding
`features/onboarding/presentation/`: `screen/onboarding_screen.dart` (route `/onboarding`) -> `view/onboarding_view.dart` (PageView, page index in a ValueNotifier) ; page data list in `utils/onboarding_page.dart`; widgets in `widgets/`. `app.dart` initialRoute is temporarily `/onboarding` until Phase 7.

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
Enums: data/enums/ (data) or presentation/utils/enums/. Models: data/model/. Datasources: data/datasource/. Screens: presentation/screen/, views: presentation/view/. Illustrations: assets/images/onboarding/{en,ar}/ (placeholder names, user will edit). Fonts: assets/fonts/ (Sora, NotoSans, NotoSansArabic, declared in pubspec). Note: `flutter test` renders the Ahem block font unless a test loads fonts with `FontLoader`.

## Notes
`SharedPreferences` is `@preResolve` in `lib/app/app_module.dart`, so `configureDependencies()` is async and `main()` awaits it. All `SharedPreferences` access goes through the shared `LocalStorageService` (abstract, `lib/core/storage/`; today backed by `SharedPrefsStorageService`; `getValue<T>` / `setValue` (type argument; `decode` / `encode` for enums and models), no keys); each datasource owns its keys. Local flags go through a datasource (e.g. `OnboardingDatasource`) called by a Cubit (`OnboardingCubit`, `flutter_bloc`, plain `Cubit<T>`, no freezed/BaseCubit yet), never from widgets; a screen provides its Cubit with `BlocProvider(create: (_) => getIt<…>())`, and `AppRouter` also reads `OnboardingDatasource.isSeen` at start-up. Tests that boot the app call `SharedPreferences.resetStatic()` + `setMockInitialValues` and `getIt.reset()` first, and use `App(key: UniqueKey())` to force a fresh Navigator.
