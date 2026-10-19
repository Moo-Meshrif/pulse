import 'package:injectable/injectable.dart';

import '../../../../../core/enums/auth_failure_reason.dart';
import '../../../../../core/enums/signed_out_reason.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../profile/data/enums/signup_step.dart';
import '../../../../profile/domain/use_case/forget_last_account_use_case.dart';
import '../../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../../../profile/domain/use_case/get_signup_step_use_case.dart';
import '../../../data/datasource/auth_datasource.dart';
import '../../utils/countdown.dart';
import 'sign_in_state.dart';

/// Sign in (S1, docs/specs/auth/screens/s1-signin.md). The first field is an email or a username; a wrong
/// password and an unknown username give the same answer, so it never leaks which exist.
@injectable
class SignInCubit extends BaseCubit<SignInState> {
  SignInCubit(
    this._auth,
    this._getSignupStep,
    this._getLastAccount,
    this._forgetLastAccount,
  ) : super(const SignInState());

  final AuthDatasource _auth;
  final GetSignupStepUseCase _getSignupStep;
  final GetLastAccountUseCase _getLastAccount;
  final ForgetLastAccountUseCase _forgetLastAccount;

  final _countdown = Countdown();

  /// Opened because a session ended ([reason]): names the saved account, whose username is then the
  /// identifier, so only the password is left to type (S14). Without a saved account the banner shows
  /// over the normal form. No [reason] leaves a plain Sign in.
  void start(SignedOutReason? reason) {
    if (reason == null) return;
    final account = _getLastAccount();
    emit(
      state.copyWith(
        reason: reason,
        account: account,
        identifier: account?.username ?? state.identifier,
      ),
    );
  }

  /// "Not you?": forgets the saved account on this device and shows the normal form.
  Future<void> forgetAccount() async {
    if (state.loading || state.account == null) return;
    await _forgetLastAccount();
    emit(state.copyWith(reason: null, account: null, identifier: ''));
  }

  // Typing clears a credentials error, but not the throttle message while its countdown runs.
  void identifierChanged(String value) => emit(
    state.copyWith(
      identifier: value,
      failure: state.throttled ? state.failure : null,
    ),
  );

  void passwordChanged(String value) => emit(
    state.copyWith(
      password: value,
      failure: state.throttled ? state.failure : null,
    ),
  );

  Future<void> submit() async {
    await run(
      prevent: !state.canSubmit,
      loading: state.copyWith(loading: true, failure: null),
      () => _auth.signIn(
        identifier: state.identifier.trim(),
        password: state.password,
      ),
      onSuccess: (_) => _signedIn(),
      onFailure: _failed,
    );
  }

  Future<void> _signedIn() async {
    await run(
      _getSignupStep.call,
      onSuccess: (step) {
        final route = step == SignupStep.complete
            ? AppRoutes.home
            : AppRoutes.registerAt(step.number);
        _go(route, clearStack: true);
      },
      onFailure: _failed,
    );
  }

  Future<void> _failed(Failure failure) async {
    if (failure case AuthFailure(
      reason: AuthFailureReason.emailNotConfirmed,
      :final email?,
    )) {
      // A fresh code for the Verify email step; if it cannot be sent, that step has "Resend code".
      try {
        await _auth.resendSignUpCode(email);
      } on Failure {
        // Not fatal, see above.
      }
      _go(AppRoutes.verifyEmailAt(email));
      return;
    }
    if (failure case AuthFailure(
      reason: AuthFailureReason.tooManyAttempts,
      :final retryAfter,
    )) {
      _startCountdown(failure, retryAfter ?? const Duration(minutes: 1));
      return;
    }
    emit(state.copyWith(loading: false, failure: failure));
  }

  void _go(String route, {bool clearStack = false}) {
    emit(state.copyWith(loading: false, route: route, clearStack: clearStack));
    emit(state.copyWith(loading: false, route: null, clearStack: false));
  }

  void _startCountdown(Failure failure, Duration wait) {
    emit(state.copyWith(loading: false, failure: failure, retryIn: wait));
    _countdown.start(
      wait,
      (left) => emit(
        left > Duration.zero
            ? state.copyWith(retryIn: left)
            : state.copyWith(failure: null, retryIn: null),
      ),
    );
  }

  @override
  Future<void> close() {
    _countdown.cancel();
    return super.close();
  }
}
