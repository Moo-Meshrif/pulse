import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/auth/domain/use_case/is_recovery_pending_use_case.dart';
import 'package:pulse/features/control/presentation/cubit/control_cubit.dart';
import 'package:pulse/features/control/presentation/cubit/control_state.dart';
import 'package:pulse/features/control/presentation/utils/enums/main_tab.dart';
import 'package:pulse/features/post/domain/event/feed_refresh_requested.dart';

class MockIsRecoveryPending extends Mock implements IsRecoveryPendingUseCase {}

void main() {
  late MockIsRecoveryPending recovery;
  late EventBus bus;

  setUp(() {
    recovery = MockIsRecoveryPending();
    bus = EventBus();
    when(() => recovery()).thenReturn(false);
  });

  ControlCubit build() => ControlCubit(recovery, bus);

  test('refreshHome asks the home feed to load again', () {
    expectLater(
      bus.on<FeedRefreshRequested>(),
      emits(const FeedRefreshRequested()),
    );
    build().refreshHome();
  });

  test('starts on Home with the hardcoded chat badge of 4', () {
    final cubit = build();
    expect(cubit.state.selected, MainTab.home);
    expect(cubit.state.chatUnread, 4);
    expect(cubit.state.redirect, isNull);
  });

  blocTest<ControlCubit, ControlState>(
    'select switches the tab',
    build: build,
    act: (cubit) => cubit.select(MainTab.chat),
    expect: () => [const ControlState(selected: MainTab.chat, chatUnread: 4)],
  );

  blocTest<ControlCubit, ControlState>(
    'selecting the selected tab emits nothing',
    build: build,
    act: (cubit) => cubit.select(MainTab.home),
    expect: () => <ControlState>[],
  );

  blocTest<ControlCubit, ControlState>(
    'goHome returns to Home from another tab',
    build: build,
    seed: () => const ControlState(selected: MainTab.profile),
    act: (cubit) => cubit.goHome(),
    expect: () => [const ControlState()],
  );

  blocTest<ControlCubit, ControlState>(
    'start with no reset pending emits nothing',
    build: build,
    act: (cubit) => cubit.start(),
    expect: () => <ControlState>[],
  );

  blocTest<ControlCubit, ControlState>(
    'start with a reset pending redirects to the reset screen',
    build: () {
      when(() => recovery()).thenReturn(true);
      return build();
    },
    act: (cubit) => cubit.start(),
    expect: () => [
      const ControlState(chatUnread: 4, redirect: AppRoutes.resetPassword),
    ],
  );
}
