import 'dart:async';

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
import '../../../auth/domain/use_case/sign_out_use_case.dart';
import '../../../profile/data/enums/signup_step.dart';
import '../../../profile/domain/use_case/get_signup_step_use_case.dart';
import '../../../profile/domain/use_case/is_signup_done_on_device_use_case.dart';
import '../utils/enums/splash_problem.dart';
import 'splash_state.dart';

/// The splash flow: decides the first screen once onboarding has been seen
/// (docs/specs/auth/00-overview.md). It reaches other features only through their use cases. A revoked or
/// expired session goes to Sign in and the stored session stays, so signing in again just works.
/// When the saved profile says sign-up is finished it opens Home with no request; otherwise it asks the
/// server for the latest step and a reply slower than [_decideWithin] ends the session.
@injectable
class SplashCubit extends BaseCubit<SplashState> {
  SplashCubit(
    this._isSignedIn,
    this._isRecoveryPending,
    this._isSignupDoneOnDevice,
    this._getSignupStep,
    this._signOut,
    this._connectivity,
  ) : super(const SplashState.deciding());

  final IsSignedInUseCase _isSignedIn;
  final IsRecoveryPendingUseCase _isRecoveryPending;
  final IsSignupDoneOnDeviceUseCase _isSignupDoneOnDevice;
  final GetSignupStepUseCase _getSignupStep;
  final SignOutUseCase _signOut;
  final ConnectivityService _connectivity;

  /// The most the server may take to answer the start-up check: a slower answer ends the session.
  static const _decideWithin = Duration(seconds: 5);

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
    // Finished on this phone: no request. A dead session shows on Home's own first request.
    if (_isSignupDoneOnDevice()) {
      emit(const SplashState.go(AppRoutes.home));
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
    emit(SplashState.retrying(state.problem!));
    return decide();
  }

  Future<SplashState> _failed(Failure failure) async {
    switch (failure) {
      // A dead session is handled here, not by `SessionGuard`: the root route is in its `_keepsScreen`, so splash
      // alone picks the sign-in route and the two never navigate at once.
      case AuthFailure(reason: AuthFailureReason.sessionExpired):
        return SplashState.go(AppRoutes.signInWith(SignedOutReason.expired));
      case AuthFailure(reason: AuthFailureReason.sessionRevoked):
        return SplashState.go(AppRoutes.signInWith(SignedOutReason.revoked));
      // A session whose profile is gone (the account was deleted): end it and tell the user it expired.
      case NotFoundFailure():
        return _endSession();
      // The server did not answer in time: end the session too, so a stuck start-up never blocks the user.
      case TimeoutFailure():
        return _endSession();
      case NetworkFailure():
        return SplashState.failed(await _connectionProblem(failure));
      default:
        return const SplashState.failed(SplashProblem.cantReach);
    }
  }

  SplashState _endSession() {
    // Not awaited: the stored session is cleared locally and a failure changes nothing here.
    unawaited(_signOut().catchError((Object _) {}));
    return SplashState.go(AppRoutes.signInWith(SignedOutReason.expired));
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
