import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/auth/domain/use_case/is_signed_in_use_case.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';
import 'package:pulse/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:pulse/features/splash/presentation/cubit/splash_state.dart';
import 'package:pulse/features/splash/presentation/utils/enums/splash_problem.dart';

class MockIsSignedIn extends Mock implements IsSignedInUseCase {}

class MockGetSignupStep extends Mock implements GetSignupStepUseCase {}

void main() {
  late MockIsSignedIn isSignedIn;
  late MockGetSignupStep getSignupStep;

  setUp(() {
    isSignedIn = MockIsSignedIn();
    getSignupStep = MockGetSignupStep();
  });

  SplashCubit cubit() => SplashCubit(isSignedIn, getSignupStep);

  void stepIs(SignupStep step) =>
      when(() => getSignupStep()).thenAnswer((_) async => Right(step));

  test('starts undecided', () {
    expect(cubit().state, const SplashState.deciding());
  });

  blocTest<SplashCubit, SplashState>(
    'no session goes to Sign in without asking for the step',
    setUp: () => when(() => isSignedIn()).thenReturn(false),
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [const SplashState.go(AppRoutes.signIn)],
    verify: (_) => verifyNever(() => getSignupStep()),
  );

  blocTest<SplashCubit, SplashState>(
    'a finished sign-up goes Home',
    setUp: () {
      when(() => isSignedIn()).thenReturn(true);
      stepIs(SignupStep.complete);
    },
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [const SplashState.go(AppRoutes.home)],
  );

  for (final step in [
    SignupStep.aboutYou,
    SignupStep.profile,
    SignupStep.interests,
    SignupStep.follow,
  ]) {
    blocTest<SplashCubit, SplashState>(
      'a pending sign-up resumes at ${step.name}',
      setUp: () {
        when(() => isSignedIn()).thenReturn(true);
        stepIs(step);
      },
      build: cubit,
      act: (c) => c.decide(),
      expect: () => [SplashState.go('/register?step=${step.number}')],
    );
  }

  void stepFails(Failure failure) {
    when(() => isSignedIn()).thenReturn(true);
    when(() => getSignupStep()).thenAnswer((_) async => Left(failure));
  }

  for (final failure in <Failure>[
    const NetworkFailure(),
    const TimeoutFailure(),
  ]) {
    blocTest<SplashCubit, SplashState>(
      '${failure.runtimeType} shows the offline screen',
      setUp: () => stepFails(failure),
      build: cubit,
      act: (c) => c.decide(),
      expect: () => [const SplashState.failed(SplashProblem.offline)],
    );
  }

  for (final failure in <Failure>[
    const ServerFailure(statusCode: 500),
    const NotFoundFailure(),
    const ParseFailure(),
    const UnexpectedFailure(),
    const AuthFailure(AuthFailureReason.rateLimited),
  ]) {
    blocTest<SplashCubit, SplashState>(
      '$failure shows the can\'t-reach screen',
      setUp: () => stepFails(failure),
      build: cubit,
      act: (c) => c.decide(),
      expect: () => [const SplashState.failed(SplashProblem.cantReach)],
    );
  }

  blocTest<SplashCubit, SplashState>(
    'a revoked or expired session goes to Sign in, not to an error screen',
    setUp: () => stepFails(const AuthFailure(AuthFailureReason.sessionExpired)),
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [const SplashState.go(AppRoutes.signIn)],
  );

  blocTest<SplashCubit, SplashState>(
    'Try again goes back to loading, then decides again (a recovered connection goes on)',
    setUp: () {
      when(() => isSignedIn()).thenReturn(true);
      var calls = 0;
      when(() => getSignupStep()).thenAnswer(
        (_) async => ++calls == 1
            ? const Left(NetworkFailure())
            : const Right(SignupStep.complete),
      );
    },
    build: cubit,
    act: (c) async {
      await c.decide();
      await c.retry();
    },
    expect: () => [
      const SplashState.failed(SplashProblem.offline),
      const SplashState.deciding(),
      const SplashState.go(AppRoutes.home),
    ],
    verify: (_) => verify(() => getSignupStep()).called(2),
  );

  blocTest<SplashCubit, SplashState>(
    'Try again can fail again with another problem',
    setUp: () {
      when(() => isSignedIn()).thenReturn(true);
      var calls = 0;
      when(() => getSignupStep()).thenAnswer(
        (_) async => Left(
          ++calls == 1 ? const NetworkFailure() : const UnexpectedFailure(),
        ),
      );
    },
    build: cubit,
    act: (c) async {
      await c.decide();
      await c.retry();
    },
    expect: () => [
      const SplashState.failed(SplashProblem.offline),
      const SplashState.deciding(),
      const SplashState.failed(SplashProblem.cantReach),
    ],
  );

  blocTest<SplashCubit, SplashState>(
    'Try again does nothing while it is still deciding',
    setUp: () => when(() => isSignedIn()).thenReturn(false),
    build: cubit,
    act: (c) => c.retry(),
    expect: () => <SplashState>[],
    verify: (_) => verifyNever(() => isSignedIn()),
  );

  test('Try again yields before its first emit too', () async {
    stepFails(const NetworkFailure());
    final splash = cubit();
    await splash.decide();
    when(() => isSignedIn()).thenReturn(false);

    final retried = splash.retry();
    expect(splash.state, const SplashState.deciding());
    await retried;
    expect(splash.state, const SplashState.go(AppRoutes.signIn));
  });

  test(
    'never emits before the caller can subscribe, even with no session',
    () async {
      // The screen calls decide() from BlocProvider.create, before its listener exists: a synchronous
      // emit would be missed and the splash would never leave.
      when(() => isSignedIn()).thenReturn(false);
      final splash = cubit();

      final decided = splash.decide();
      expect(splash.state, const SplashState.deciding());

      await decided;
      expect(splash.state, const SplashState.go(AppRoutes.signIn));
    },
  );

  test('registerAt builds the resume link', () {
    expect(AppRoutes.registerAt(4), '/register?step=4');
  });
}
