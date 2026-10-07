import 'dart:developer';

import 'package:flutter/foundation.dart';

typedef ErrorSink = Future<void> Function(
  Object error,
  StackTrace stack, {
  required bool fatal,
});

/// Reports unexpected errors. Never pass tokens or personal data in [error] messages.
abstract final class ErrorReporter {
  static ErrorSink? _sink;

  /// Called once in `main()` with the project's crash SDK.
  static void configure(ErrorSink sink) => _sink = sink;

  static void report(Object error, StackTrace stack, {bool fatal = false}) {
    final sink = _sink;
    if (kDebugMode || sink == null) {
      // debug builds never send reports
      log(
        fatal ? 'Fatal error' : 'Error',
        error: error,
        stackTrace: stack,
        name: 'ErrorReporter',
      );
      return;
    }
    sink(error, stack, fatal: fatal);
  }
}
