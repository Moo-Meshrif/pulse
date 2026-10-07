import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/onboarding/data/datasource/onboarding_datasource.dart';
import 'package:pulse/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:pulse/features/onboarding/presentation/utils/enums/onboarding_exit.dart';

class MockOnboardingDatasource extends Mock implements OnboardingDatasource {}

void main() {
  late MockOnboardingDatasource datasource;

  setUp(() {
    datasource = MockOnboardingDatasource();
    when(() => datasource.markSeen()).thenAnswer((_) async {});
  });

  group('finish', () {
    blocTest<OnboardingCubit, OnboardingExit?>(
      'records the flag, then emits how the user left',
      build: () => OnboardingCubit(datasource),
      act: (cubit) => cubit.finish(OnboardingExit.register),
      expect: () => [OnboardingExit.register],
      verify: (_) => verify(() => datasource.markSeen()).called(1),
    );

    blocTest<OnboardingCubit, OnboardingExit?>(
      'a second call while the first is writing is ignored',
      build: () => OnboardingCubit(datasource),
      act: (cubit) async {
        final first = cubit.finish(OnboardingExit.signIn);
        await cubit.finish(OnboardingExit.register);
        await first;
      },
      expect: () => [OnboardingExit.signIn],
    );

    blocTest<OnboardingCubit, OnboardingExit?>(
      'does not emit when the Cubit is closed before the write finishes',
      build: () => OnboardingCubit(datasource),
      act: (cubit) async {
        final pending = cubit.finish(OnboardingExit.signIn);
        await cubit.close();
        await pending;
      },
      expect: () => <OnboardingExit?>[],
    );
  });
}
