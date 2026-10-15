import 'dart:async';

import 'package:injectable/injectable.dart';

/// One app-wide channel for "this happened" between screens that cannot reach each other's Cubits (the
/// story viewer tells Home's rail a story is being deleted). Events are plain classes: [fire] one, [on]
/// listens for its type. Fire-and-forget; nothing is replayed to a late listener.
@LazySingleton()
class EventBus {
  final StreamController<Object> _controller =
      StreamController<Object>.broadcast();

  Stream<T> on<T extends Object>() =>
      _controller.stream.where((event) => event is T).cast<T>();

  void fire(Object event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  @disposeMethod
  Future<void> dispose() => _controller.close();
}
