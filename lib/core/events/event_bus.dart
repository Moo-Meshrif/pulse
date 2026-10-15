import 'dart:async';

import 'package:injectable/injectable.dart';

/// An app-wide event bus: a way for parts of the app that cannot reach each other directly to tell one
/// another that something happened.
///
/// An event is any object, usually a small immutable class. [fire] sends one and [on] listens for events of
/// a type.
///
/// Delivery is fire-and-forget: an event reaches only the listeners that exist when it is sent, and a
/// listener that starts later does not get it. The exception is [fireLatest], which also keeps the newest
/// event of a type so a late listener can read it with [latest].
@LazySingleton()
class EventBus {
  final StreamController<Object> _controller =
      StreamController<Object>.broadcast();

  /// The newest event sent with [fireLatest], by the type it was sent as.
  final Map<Type, Object> _latest = {};

  /// The events of type [T] sent from now on. Subtypes count too: if `Status` is a base class,
  /// `on<Status>()` also receives each of its subclasses. Events sent before listening are not delivered.
  Stream<T> on<T extends Object>() =>
      _controller.stream.where((event) => event is T).cast<T>();

  /// Sends [event] to the current listeners. Does nothing once the bus is disposed.
  void fire(Object event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  /// Sends [event] like [fire] and also keeps it as the newest [T]; a later call replaces it. Pass [T]
  /// explicitly (`fireLatest<Status>(event)`) so all subtypes are stored under the same type.
  void fireLatest<T extends Object>(T event) {
    _latest[T] = event;
    fire(event);
  }

  /// The newest event sent with `fireLatest<T>`, or null if there was none. Use it as the current value
  /// when something starts after the event was sent: read it once, then listen with [on] for changes.
  T? latest<T extends Object>() => _latest[T] as T?;

  /// Closes the bus. Events fired afterwards are ignored.
  @disposeMethod
  Future<void> dispose() => _controller.close();
}
