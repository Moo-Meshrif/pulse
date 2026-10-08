import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/auth/presentation/utils/countdown.dart';

void main() {
  testWidgets('reports the time left every second and stops at zero', (
    tester,
  ) async {
    final countdown = Countdown();
    final ticks = <Duration>[];

    countdown.start(const Duration(seconds: 3), ticks.add);
    expect(countdown.isRunning, isTrue);

    await tester.pump(const Duration(seconds: 3));
    expect(ticks, const [
      Duration(seconds: 2),
      Duration(seconds: 1),
      Duration.zero,
    ]);
    expect(countdown.isRunning, isFalse);

    await tester.pump(const Duration(seconds: 5));
    expect(ticks, hasLength(3));
  });

  testWidgets('starting again replaces the running countdown', (tester) async {
    final countdown = Countdown();
    final first = <Duration>[];
    final second = <Duration>[];

    countdown.start(const Duration(seconds: 10), first.add);
    await tester.pump(const Duration(seconds: 2));
    countdown.start(const Duration(seconds: 2), second.add);
    await tester.pump(const Duration(seconds: 5));

    expect(first, hasLength(2));
    expect(second, const [Duration(seconds: 1), Duration.zero]);
    countdown.cancel();
  });

  testWidgets('cancel stops it without a final call and is safe twice', (
    tester,
  ) async {
    final countdown = Countdown();
    final ticks = <Duration>[];

    countdown.start(const Duration(seconds: 5), ticks.add);
    await tester.pump(const Duration(seconds: 1));
    countdown
      ..cancel()
      ..cancel();
    await tester.pump(const Duration(seconds: 10));

    expect(ticks, hasLength(1));
    expect(countdown.isRunning, isFalse);
  });
}
