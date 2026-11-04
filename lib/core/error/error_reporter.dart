import 'dart:collection';
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
  static final Queue<String> _recent = Queue<String>();

  /// Error types only, so diagnostics do not contain exception messages or personal data.
  static List<String> get recentErrors => List.unmodifiable(_recent);

  /// Called once in `main()` with the project's crash SDK.
  static void configure(ErrorSink sink) => _sink = sink;

  static void report(Object error, StackTrace stack, {bool fatal = false}) {
    if (_recent.length == 50) _recent.removeFirst();
    _recent.addLast('${fatal ? 'Fatal' : 'Error'}: ${error.runtimeType}');
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
