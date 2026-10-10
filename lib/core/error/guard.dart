import 'dart:async';

import 'backend_failure.dart';
import 'error_reporter.dart';
import 'exceptions.dart';
import 'failures.dart';

/// The only place that turns exceptions into [Failure]s. Static-only, no state: datasources and
/// repositories call `Guard.run(...)`. Unknown errors are reported and become [UnexpectedFailure].
abstract final class Guard {
  /// Runs a call and returns its value, or throws the matching [Failure].
  static Future<T> run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error, stackTrace) {
      throw toFailure(error, stackTrace);
    }
  }

  /// The [Failure] for any error. A [Failure] that was already thrown passes through untouched.
  static Failure toFailure(Object error, StackTrace stackTrace) =>
      switch (error) {
        Failure() => error,
        AuthRejectedException(:final reason) => AuthFailure(reason),
        NotFoundException() => const NotFoundFailure(),
        TimeoutException() => const TimeoutFailure(),
        FormatException() ||
        TypeError() => _reported(const ParseFailure(), error, stackTrace),
        _ => _fromBackend(error, stackTrace),
      };

  /// A backend answer we have no specific case for (an unmapped auth code, a 5xx) is mapped to
  /// [ServerFailure] but still reported, so it can get its own case later.
  static Failure _fromBackend(Object error, StackTrace stackTrace) {
    final failure = backendFailure(error);
    if (failure == null) {
      return _reported(const UnexpectedFailure(), error, stackTrace);
    }
    return failure is ServerFailure
        ? _reported(failure, error, stackTrace)
        : failure;
  }

  /// Parse errors and unknown errors are bugs, not user conditions (the user only sees the generic
  /// message): report them (non-fatal). Handled failures (network, credentials, ...) are not logged.
  static Failure _reported(
    Failure failure,
    Object error,
    StackTrace stackTrace,
  ) {
    ErrorReporter.report(error, stackTrace);
    return failure;
  }
}
