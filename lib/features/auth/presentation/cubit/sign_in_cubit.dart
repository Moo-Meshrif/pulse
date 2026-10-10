import 'package:injectable/injectable.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../profile/data/enums/signup_step.dart';
import '../../../profile/domain/use_case/get_signup_step_use_case.dart';
import '../../data/datasource/auth_datasource.dart';
import '../utils/countdown.dart';
import 'sign_in_state.dart';

/// Sign in (S1, docs/specs/auth/screens/s1-signin.md). The first field is an email or a username; a wrong
/// password and an unknown username give the same answer, so it never leaks which exist.
@injectable
class SignInCubit extends BaseCubit<SignInState> {
  SignInCubit(this._auth, this._getSignupStep) : super(const SignInState());

  final AuthDatasource _auth;
  final GetSignupStepUseCase _getSignupStep;

  final _countdown = Countdown();

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
