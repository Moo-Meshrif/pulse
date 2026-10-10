# Errors
Covers: Failure/Guard, reporting
Does not cover: showing errors in UI (ui.md)
Rule: calls return the value and throw `Failure` (sealed, implements Exception; lib/core/error/: failures, exceptions, guard, backend_failure). `Guard.run` turns exceptions into thrown Failures; `Guard.toFailure` maps any error. Cubits call through `BaseCubit.run`, never a bare try/catch except to ignore a non-fatal failure on purpose (catch `on Failure`). No Either/Result/Unit. `ErrorReporter` + global handlers (`FlutterError.onError`, `PlatformDispatcher.onError`) in `lib/main.dart`. Failure text via `failure_l10n.dart` in presentation.
Example: lib/features/auth/data/datasource/auth_datasource.dart
