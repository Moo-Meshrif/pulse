import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/events/event_cubit_mixin.dart';
import 'package:pulse/core/state/base_cubit.dart';

class _Ping {
  const _Ping(this.by);

  final int by;
}

class _Reset {
  const _Reset();
}

class _CounterCubit extends BaseCubit<int> with EventCubitMixin<int> {
  _CounterCubit(this.events) : super(0);

  @override
  final EventBus events;

  final heard = <Object>[];

  void listen() {
    syncState<_Ping>(
      (current, event) => event.by == 0 ? null : current + event.by,
    );
    syncState<_Reset>((current, _) => current == 0 ? current : 0);
    listenTo<_Reset>(heard.add);
  }

  void tell(Object event) => fire(event);
}

void main() {
  late EventBus bus;
  late _CounterCubit cubit;

  setUp(() {
    bus = EventBus();
    cubit = _CounterCubit(bus)..listen();
    addTearDown(bus.dispose);
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('syncState emits the state the event produces', () async {
    bus.fire(const _Ping(2));
    bus.fire(const _Ping(3));
    await flush();
    expect(cubit.state, 5);
  });

  test('null or the same state emits nothing', () async {
    final states = <int>[];
    cubit.stream.listen(states.add);
    bus.fire(const _Ping(0));
    bus.fire(const _Reset());
    await flush();
    expect(states, isEmpty);
  });

  test('a type gets all of its listeners, and others are ignored', () async {
    bus.fire(const _Ping(1));
    bus.fire(const _Reset());
    await flush();
    expect(cubit.state, 0);
    expect(cubit.heard, hasLength(1));
  });

  test('fire reaches the bus', () async {
    final events = <_Ping>[];
    bus.on<_Ping>().listen(events.add);
    cubit.tell(const _Ping(4));
    await flush();
    expect(events.single.by, 4);
  });

  test('stops listening when closed', () async {
    await cubit.close();
    bus.fire(const _Ping(1));
    await flush();
    expect(cubit.state, 0);
    expect(cubit.heard, isEmpty);
  });
}
