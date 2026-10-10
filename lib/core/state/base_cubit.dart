import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failures.dart';
import '../error/guard.dart';

/// Base for the app's Cubits. Emits only while open, so emitting after an `await` (the user left the
/// screen) never throws.
abstract class BaseCubit<S> extends Cubit<S> {
  BaseCubit(super.initialState);

  @override
  void emit(S state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Runs a call that returns its value or throws a [Failure], and emits the state the matching
  /// callback returns. Does nothing when [prevent] is set (a guard such as `!state.canSubmit`). Emits [loading] first when given. Any other error is reported and reaches
  /// [onFailure] as a [Failure]. A callback that returns no state emits nothing: it handled the
  /// result itself (navigation, a countdown, its own emits).
  @protected
  Future<void> run<T>(
    Future<T> Function() action, {
    bool prevent = false,
    S? loading,
    required FutureOr<dynamic> Function(T data) onSuccess,
    required FutureOr<dynamic> Function(Failure failure) onFailure,
  }) async {
    if (prevent) return;
    if (loading != null) emit(loading);
    final T data;
    try {
      data = await action();
    } catch (error, stackTrace) {
      final next = onFailure(Guard.toFailure(error, stackTrace));
      await _emitResult(next);
      return;
    }
    await _emitResult(onSuccess(data));
  }

  /// Emits at once when the callback answered synchronously: awaiting a plain value would let another
  /// emit slip in between building the state from `state` and emitting it.
  Future<void> _emitResult(FutureOr<dynamic> result) async {
    final next = result is Future ? await result : result;
    if (next is S) emit(next);
  }
}
