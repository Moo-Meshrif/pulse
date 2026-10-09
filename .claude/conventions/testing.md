# Testing
Rule: `test/` mirrors `lib/`; helpers `test/helpers/pump_app.dart` (`pumpApp`, `bootApp`, `setUpView`, `testView` for 390x844 frame, `l10nEn`/`l10nAr`); `test/helpers/backend_double.dart` for datasource tests. mocktail + bloc_test. Assert generated l10n strings. Booting tests: `SharedPreferences.resetStatic()` + `setMockInitialValues`, `getIt.reset()`, `App(key: UniqueKey())`. Widget tests EN + AR/RTL + 1.5x text. Ahem font unless FontLoader.
Example: test/features/auth/
