import 'dart:async';

import '../utils/either.dart';
import 'backend_failure.dart';
import 'error_reporter.dart';
import 'exceptions.dart';
import 'failures.dart';
import 'result.dart';

/// The only place that turns exceptions into [Failure]s. Static-only, no state: datasources and
/// repositories call `Guard.run(...)`. Unknown errors are reported and become [UnexpectedFailure].
abstract final class Guard {
  /// Runs a call and returns its value, or the matching [Failure].
  static Future<Result<T>> run<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } catch (error, stackTrace) {
      final failure = _toFailure(error, stackTrace);
      return Left(failure);
    }
  }

  static Failure _toFailure(Object error, StackTrace stackTrace) =>
      switch (error) {
        AuthRejectedException(:final reason) => AuthFailure(reason),
        NotFoundException() => const NotFoundFailure(),
        TimeoutException() => const TimeoutFailure(),
        FormatException() ||
        TypeError() => _reported(const ParseFailure(), error, stackTrace),
        _ =>
          backendFailure(error) ??
              _reported(const UnexpectedFailure(), error, stackTrace),
      };

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
