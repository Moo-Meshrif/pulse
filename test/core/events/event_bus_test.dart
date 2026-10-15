import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/events/event_bus.dart';

sealed class _Status {
  const _Status();
}

class _Idle extends _Status {
  const _Idle();
}

class _Busy extends _Status {
  const _Busy();
}

void main() {
  late EventBus bus;

  setUp(() => bus = EventBus());

  test('latest is null until something was fired with fireLatest', () {
    expect(bus.latest<_Status>(), isNull);
    bus.fire(const _Busy());
    expect(bus.latest<_Status>(), isNull);
  });

  test('fireLatest sends the event and keeps the newest one', () async {
    final heard = <_Status>[];
    bus.on<_Status>().listen(heard.add);
    bus
      ..fireLatest<_Status>(const _Busy())
      ..fireLatest<_Status>(const _Idle());
    await Future<void>.delayed(Duration.zero);
    expect(heard, [isA<_Busy>(), isA<_Idle>()]);
    expect(bus.latest<_Status>(), isA<_Idle>());
  });
}
