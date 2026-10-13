import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/auth/domain/use_case/is_recovery_pending_use_case.dart';
import 'package:pulse/features/control_page/presentation/cubit/control_page_cubit.dart';
import 'package:pulse/features/control_page/presentation/cubit/control_page_state.dart';
import 'package:pulse/features/control_page/presentation/utils/enums/main_tab.dart';

class MockIsRecoveryPending extends Mock implements IsRecoveryPendingUseCase {}

void main() {
  late MockIsRecoveryPending recovery;

  setUp(() {
    recovery = MockIsRecoveryPending();
    when(() => recovery()).thenReturn(false);
  });

  ControlPageCubit build() => ControlPageCubit(recovery);

  test('starts on Home with the hardcoded chat badge of 4', () {
    final cubit = build();
    expect(cubit.state.selected, MainTab.home);
    expect(cubit.state.chatUnread, 4);
    expect(cubit.state.redirect, isNull);
  });

  blocTest<ControlPageCubit, ControlPageState>(
    'select switches the tab',
    build: build,
    act: (cubit) => cubit.select(MainTab.chat),
    expect: () => [
      const ControlPageState(selected: MainTab.chat, chatUnread: 4),
    ],
  );

  blocTest<ControlPageCubit, ControlPageState>(
    'selecting the selected tab emits nothing',
    build: build,
    act: (cubit) => cubit.select(MainTab.home),
    expect: () => <ControlPageState>[],
  );

  blocTest<ControlPageCubit, ControlPageState>(
    'goHome returns to Home from another tab',
    build: build,
    seed: () => const ControlPageState(selected: MainTab.profile),
    act: (cubit) => cubit.goHome(),
    expect: () => [const ControlPageState()],
  );

  blocTest<ControlPageCubit, ControlPageState>(
    'start with no reset pending emits nothing',
    build: build,
    act: (cubit) => cubit.start(),
    expect: () => <ControlPageState>[],
  );

  blocTest<ControlPageCubit, ControlPageState>(
    'start with a reset pending redirects to the reset screen',
    build: () {
      when(() => recovery()).thenReturn(true);
      return build();
    },
    act: (cubit) => cubit.start(),
    expect: () => [
      const ControlPageState(chatUnread: 4, redirect: AppRoutes.resetPassword),
    ],
  );
}
