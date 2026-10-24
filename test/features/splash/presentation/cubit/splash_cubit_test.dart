import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/enums/connection_problem.dart';
import 'package:pulse/core/enums/signed_out_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/services/connectivity_service.dart';
import 'package:pulse/features/auth/domain/use_case/is_recovery_pending_use_case.dart';
import 'package:pulse/features/auth/domain/use_case/is_signed_in_use_case.dart';
import 'package:pulse/features/auth/domain/use_case/sign_out_use_case.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/is_signup_done_on_device_use_case.dart';
import 'package:pulse/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:pulse/features/splash/presentation/cubit/splash_state.dart';
import 'package:pulse/features/splash/presentation/utils/enums/splash_problem.dart';

class MockIsSignedIn extends Mock implements IsSignedInUseCase {}

class MockIsRecoveryPending extends Mock implements IsRecoveryPendingUseCase {}

class MockIsSignupDoneOnDevice extends Mock
    implements IsSignupDoneOnDeviceUseCase {}

class MockGetSignupStep extends Mock implements GetSignupStepUseCase {}

class MockSignOut extends Mock implements SignOutUseCase {}

class MockConnectivity extends Mock implements ConnectivityService {}

void main() {
  setUpAll(() => registerFallbackValue(const NetworkFailure()));

  late MockIsSignedIn isSignedIn;
  late MockIsRecoveryPending isRecoveryPending;
  late MockIsSignupDoneOnDevice isSignupDoneOnDevice;
  late MockGetSignupStep getSignupStep;
  late MockSignOut signOut;
  late MockConnectivity connectivity;

  setUp(() {
    isSignedIn = MockIsSignedIn();
    isRecoveryPending = MockIsRecoveryPending();
    when(() => isRecoveryPending()).thenReturn(false);
    isSignupDoneOnDevice = MockIsSignupDoneOnDevice();
    when(() => isSignupDoneOnDevice()).thenReturn(false);
    getSignupStep = MockGetSignupStep();
    signOut = MockSignOut();
    when(() => signOut()).thenAnswer((_) async {});
    connectivity = MockConnectivity();
    when(() => connectivity.diagnose(any()))
        .thenAnswer((_) async => ConnectionProblem.offline);
  });

  SplashCubit cubit() => SplashCubit(
    isSignedIn,
    isRecoveryPending,
    isSignupDoneOnDevice,
    getSignupStep,
    signOut,
    connectivity,
  );

  void stepIs(SignupStep step) =>
      when(() => getSignupStep()).thenAnswer((_) async => step);

  test('starts undecided', () {
    expect(cubit().state, const SplashState.deciding());
  });

  blocTest<SplashCubit, SplashState>(
    'an unfinished password reset resumes the reset screen, even with a session',
    setUp: () {
      when(() => isRecoveryPending()).thenReturn(true);
      when(() => isSignedIn()).thenReturn(true);
    },
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [const SplashState.go(AppRoutes.resetPassword)],
    verify: (_) => verifyNever(() => getSignupStep()),
  );

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

  blocTest<SplashCubit, SplashState>(
    'a sign-up finished on this phone goes Home with no request',
    setUp: () {
      when(() => isSignedIn()).thenReturn(true);
      when(() => isSignupDoneOnDevice()).thenReturn(true);
    },
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [const SplashState.go(AppRoutes.home)],
    verify: (_) => verifyNever(() => getSignupStep()),
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
    when(() => getSignupStep()).thenThrow(failure);
  }

  blocTest<SplashCubit, SplashState>(
    'NetworkFailure shows the offline screen',
    setUp: () => stepFails(const NetworkFailure()),
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [const SplashState.failed(SplashProblem.offline)],
  );

  blocTest<SplashCubit, SplashState>(
    'TimeoutFailure signs out and Sign in says it expired',
    setUp: () => stepFails(const TimeoutFailure()),
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [
      SplashState.go(AppRoutes.signInWith(SignedOutReason.expired)),
    ],
    verify: (_) => verify(() => signOut()).called(1),
  );

  group('showing the diagnosed connection problem', () {
    const cases = {
      ConnectionProblem.offline: SplashProblem.offline,
      ConnectionProblem.noInternet: SplashProblem.noInternet,
      ConnectionProblem.weak: SplashProblem.weakConnection,
      ConnectionProblem.cantReach: SplashProblem.cantReach,
    };
    for (final MapEntry(key: diagnosis, value: problem) in cases.entries) {
      for (final failure in <Failure>[const NetworkFailure()]) {
        blocTest<SplashCubit, SplashState>(
          '${failure.runtimeType} diagnosed as ${diagnosis.name} shows ${problem.name}',
          setUp: () {
            stepFails(failure);
            when(() => connectivity.diagnose(failure))
                .thenAnswer((_) async => diagnosis);
          },
          build: cubit,
          act: (c) => c.decide(),
          expect: () => [SplashState.failed(problem)],
        );
      }
    }

    blocTest<SplashCubit, SplashState>(
      'a server failure is not diagnosed',
      setUp: () => stepFails(const ServerFailure(statusCode: 500)),
      build: cubit,
      act: (c) => c.decide(),
      expect: () => [const SplashState.failed(SplashProblem.cantReach)],
      verify: (_) => verifyNever(() => connectivity.diagnose(any())),
    );
  });

  testWidgets(
    'a start-up request that never answers times out after 5 s and ends the session',
    (tester) async {
      final never = Completer<SignupStep>();
      when(() => isSignedIn()).thenReturn(true);
      when(() => getSignupStep()).thenAnswer((_) => never.future);
      final c = cubit();
      unawaited(c.decide());

      await tester.pump(const Duration(seconds: 4));
      expect(c.state, const SplashState.deciding());
      await tester.pump(const Duration(seconds: 2));
      expect(
        c.state,
        SplashState.go(AppRoutes.signInWith(SignedOutReason.expired)),
      );
      verify(() => signOut()).called(1);
      // Not awaited: this test runs on a fake clock, so only a pump would finish the cancel.
      unawaited(c.close());
    },
  );

  blocTest<SplashCubit, SplashState>(
    'a session whose profile is gone is signed out and Sign in says it expired',
    setUp: () => stepFails(const NotFoundFailure()),
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [
      SplashState.go(AppRoutes.signInWith(SignedOutReason.expired)),
    ],
    verify: (_) => verify(() => signOut()).called(1),
  );

  for (final failure in <Failure>[
    const ServerFailure(statusCode: 500),
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
    'an expired session goes to Sign in with the expired reason, not to an error screen',
    setUp: () => stepFails(const AuthFailure(AuthFailureReason.sessionExpired)),
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [
      SplashState.go(AppRoutes.signInWith(SignedOutReason.expired)),
    ],
  );

  blocTest<SplashCubit, SplashState>(
    'a revoked session goes to Sign in with the revoked reason',
    setUp: () => stepFails(const AuthFailure(AuthFailureReason.sessionRevoked)),
    build: cubit,
    act: (c) => c.decide(),
    expect: () => [
      SplashState.go(AppRoutes.signInWith(SignedOutReason.revoked)),
    ],
  );

  blocTest<SplashCubit, SplashState>(
    'Try again keeps the problem screen with a spinning button, then decides again (a recovered connection goes on)',
    setUp: () {
      when(() => isSignedIn()).thenReturn(true);
      var calls = 0;
      when(() => getSignupStep()).thenAnswer((_) async {
        if (++calls == 1) throw const NetworkFailure();
        return SignupStep.complete;
      });
    },
    build: cubit,
    act: (c) async {
      await c.decide();
      await c.retry();
    },
    expect: () => [
      const SplashState.failed(SplashProblem.offline),
      const SplashState.retrying(SplashProblem.offline),
      const SplashState.go(AppRoutes.home),
    ],
    verify: (_) => verify(() => getSignupStep()).called(2),
  );

  blocTest<SplashCubit, SplashState>(
    'Try again can fail again with another problem',
    setUp: () {
      when(() => isSignedIn()).thenReturn(true);
      var calls = 0;
      when(() => getSignupStep()).thenAnswer((_) async {
        throw ++calls == 1 ? const NetworkFailure() : const UnexpectedFailure();
      });
    },
    build: cubit,
    act: (c) async {
      await c.decide();
      await c.retry();
    },
    expect: () => [
      const SplashState.failed(SplashProblem.offline),
      const SplashState.retrying(SplashProblem.offline),
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
    expect(splash.state, const SplashState.retrying(SplashProblem.offline));
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
