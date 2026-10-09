# Errors
Covers: Failure/Result/Guard, reporting
Does not cover: showing errors in UI (ui.md)
Rule: `Result<T>` = `Either<Failure, T>` (lib/core/utils/either.dart; lib/core/error/: failures, exceptions, guard, backend_failure). `Guard.run` turns exceptions into Failures. `ErrorReporter` + global handlers (`FlutterError.onError`, `PlatformDispatcher.onError`) in `lib/main.dart`. Failure text via `failure_l10n.dart` in presentation.
Example: lib/features/auth/data/datasource/auth_datasource.dart
