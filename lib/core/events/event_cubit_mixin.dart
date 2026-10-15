import 'dart:async';

import 'package:flutter/foundation.dart';

import '../state/base_cubit.dart';
import 'event_bus.dart';

/// Lets a Cubit send events to, and receive events from, other parts of the app through an [EventBus].
///
/// Use [fire] to announce something, [listenTo] to react to an event, and [syncState] to turn an event
/// straight into a new state. Every listener is cancelled when the Cubit closes, so nothing leaks.
///
/// ```dart
/// class CounterCubit extends BaseCubit<int> with EventCubitMixin<int> {
///   CounterCubit(this._bus) : super(0);
///
///   final EventBus _bus;
///
///   @override
///   EventBus get events => _bus;
///
///   void start() => syncState<Reset>((current, event) => 0);
/// }
/// ```
mixin EventCubitMixin<S> on BaseCubit<S> {
  final _eventSubscriptions = <StreamSubscription<Object>>[];

  /// The bus this Cubit uses. Keep the injected bus in a field and return it here.
  @protected
  EventBus get events;

  /// Sends [event] to everything listening for its type on [events].
  @protected
  void fire(Object event) => events.fire(event);

  /// Calls [onEvent] for each event of type [E], for side effects such as reloading data. Call it once
  /// per event type, usually from a `start()` method; calling it twice runs [onEvent] twice per event.
  @protected
  void listenTo<E extends Object>(void Function(E event) onEvent) =>
      _eventSubscriptions.add(events.on<E>().listen(onEvent));

  /// Emits the state that [apply] returns for each event of type [E]. [apply] gets the current state and
  /// the event. Returning null, or the current state itself, emits nothing.
  @protected
  void syncState<E extends Object>(S? Function(S current, E event) apply) =>
      listenTo<E>((event) {
        final next = apply(state, event);
        if (next != null && !identical(next, state)) emit(next);
      });

  /// Cancels every listener added by [listenTo] and [syncState], then closes the Cubit.
  @override
  Future<void> close() async {
    await Future.wait(_eventSubscriptions.map((sub) => sub.cancel()));
    return super.close();
  }
}
