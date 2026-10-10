import 'package:injectable/injectable.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../auth/domain/use_case/is_signed_in_use_case.dart';
import '../../../profile/data/enums/signup_step.dart';
import '../../../profile/domain/use_case/get_signup_step_use_case.dart';
import '../utils/enums/splash_problem.dart';
import 'splash_state.dart';

/// The splash flow: decides the first screen once onboarding has been seen
/// (docs/specs/auth/00-overview.md). It reaches other features only through their use cases. A revoked or
/// expired session goes to Sign in and the stored session stays, so signing in again just works.
@injectable
class SplashCubit extends BaseCubit<SplashState> {
  SplashCubit(this._isSignedIn, this._getSignupStep)
    : super(const SplashState.deciding());

  final IsSignedInUseCase _isSignedIn;
  final GetSignupStepUseCase _getSignupStep;

  Future<void> decide() async {
    // Yield first, always: the screen calls this from `BlocProvider.create`, before its listener is
    // subscribed. Emitting synchronously (the no-session path has nothing to await) would be missed.
    await Future<void>.value();
    if (!_isSignedIn()) {
      emit(const SplashState.go(AppRoutes.signIn));
      return;
    }
    await run(
      _getSignupStep.call,
      onSuccess: (step) => SplashState.go(_routeFor(step)),
      onFailure: _failed,
    );
  }

  /// "Try again": back to loading, then decide again.
  Future<void> retry() {
    if (state.problem == null) return Future<void>.value();
    emit(const SplashState.deciding());
    return decide();
  }

  SplashState _failed(Failure failure) => switch (failure) {
    AuthFailure(reason: AuthFailureReason.sessionExpired) =>
      const SplashState.go(AppRoutes.signIn),
    NetworkFailure() ||
    TimeoutFailure() => const SplashState.failed(SplashProblem.offline),
    _ => const SplashState.failed(SplashProblem.cantReach),
  };

  String _routeFor(SignupStep step) => switch (step) {
    SignupStep.complete => AppRoutes.home,
    _ => AppRoutes.registerAt(step.number),
  };
}
