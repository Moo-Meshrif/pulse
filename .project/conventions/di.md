# DI
Covers: get_it + injectable setup
Rule: `lib/core/di/injection.dart`, generated `injection.config.dart` (`fvm dart run build_runner build --delete-conflicting-outputs`). `SharedPreferences` is `@preResolve` in `lib/app/app_module.dart`; `SupabaseClient` also from `AppModule`; `configureDependencies()` async, awaited in `main()`.
Tests: `getIt.reset()` before booting; `bootApp` registers signed-out mock datasources.
Example: lib/app/app_module.dart
