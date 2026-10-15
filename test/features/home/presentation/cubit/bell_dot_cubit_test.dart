import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/activity/domain/use_case/get_unread_activity_count_use_case.dart';
import 'package:pulse/features/home/presentation/cubit/bell_dot_cubit.dart';
import 'package:pulse/features/post/domain/event/feed_refresh_requested.dart';

class _Unread extends Mock implements GetUnreadActivityCountUseCase {}

void main() {
  late _Unread unread;
  late EventBus bus;

  setUp(() {
    unread = _Unread();
    bus = EventBus();
  });

  test('shows the dot while anything waits', () async {
    when(unread.call).thenAnswer((_) async => 3);
    final cubit = BellDotCubit(unread, bus);
    expect(cubit.state, isFalse);
    await cubit.load();
    expect(cubit.state, isTrue);
  });

  test('hides the dot once nothing waits', () async {
    when(unread.call).thenAnswer((_) async => 2);
    final cubit = BellDotCubit(unread, bus);
    await cubit.load();
    when(unread.call).thenAnswer((_) async => 0);
    await cubit.load();
    expect(cubit.state, isFalse);
  });

  test('a count that cannot be read leaves the dot as it is', () async {
    when(unread.call).thenAnswer((_) async => 1);
    final cubit = BellDotCubit(unread, bus);
    await cubit.load();
    when(unread.call).thenAnswer((_) async => throw const NetworkFailure());
    await cubit.load();
    expect(cubit.state, isTrue);
  });

  test('start reads the count, and again whenever Home is refreshed', () async {
    when(unread.call).thenAnswer((_) async => 0);
    final cubit = BellDotCubit(unread, bus);
    await cubit.start();
    expect(cubit.state, isFalse);

    when(unread.call).thenAnswer((_) async => 4);
    bus.fire(const FeedRefreshRequested());
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isTrue);

    await cubit.close();
    bus.fire(const FeedRefreshRequested());
    await Future<void>.delayed(Duration.zero);
    verify(unread.call).called(2);
  });
}
