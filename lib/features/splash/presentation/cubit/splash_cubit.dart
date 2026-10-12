import 'package:injectable/injectable.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/enums/connection_problem.dart';
import '../../../../core/enums/signed_out_reason.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../auth/domain/use_case/is_recovery_pending_use_case.dart';
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
  SplashCubit(
    this._isSignedIn,
    this._isRecoveryPending,
    this._getSignupStep,
    this._connectivity,
  ) : super(const SplashState.deciding());

  final IsSignedInUseCase _isSignedIn;
  final IsRecoveryPendingUseCase _isRecoveryPending;
  final GetSignupStepUseCase _getSignupStep;
  final ConnectivityService _connectivity;

  /// The most the start-up decision may take: a slower answer counts as a lost connection.
  static const _decideWithin = Duration(seconds: 10);

  Future<void> decide() async {
    // Yield first, always: the screen calls this from `BlocProvider.create`, before its listener is
    // subscribed. Emitting synchronously (the no-session path has nothing to await) would be missed.
    await Future<void>.value();
    // A reset that was started and not finished (the app was closed on its screen) resumes there.
    if (_isRecoveryPending()) {
      emit(const SplashState.go(AppRoutes.resetPassword));
      return;
    }
    if (!_isSignedIn()) {
      emit(const SplashState.go(AppRoutes.signIn));
      return;
    }
    await run(
      () => _getSignupStep().timeout(_decideWithin),
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

  Future<SplashState> _failed(Failure failure) async {
    switch (failure) {
      case AuthFailure(reason: AuthFailureReason.sessionExpired):
        return SplashState.go(AppRoutes.signInWith(SignedOutReason.expired));
      case AuthFailure(reason: AuthFailureReason.sessionRevoked):
        return SplashState.go(AppRoutes.signInWith(SignedOutReason.revoked));
      case NetworkFailure() || TimeoutFailure():
        return SplashState.failed(await _connectionProblem(failure));
      default:
        return const SplashState.failed(SplashProblem.cantReach);
    }
  }

  Future<SplashProblem> _connectionProblem(Failure failure) async =>
      switch (await _connectivity.diagnose(failure)) {
        ConnectionProblem.offline => SplashProblem.offline,
        ConnectionProblem.noInternet => SplashProblem.noInternet,
        ConnectionProblem.weak => SplashProblem.weakConnection,
        ConnectionProblem.cantReach => SplashProblem.cantReach,
      };

  String _routeFor(SignupStep step) => switch (step) {
    SignupStep.complete => AppRoutes.home,
    _ => AppRoutes.registerAt(step.number),
  };
}
