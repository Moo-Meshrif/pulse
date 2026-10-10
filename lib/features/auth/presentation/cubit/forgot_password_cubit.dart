import 'package:injectable/injectable.dart';

import '../../../../core/services/launch_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../data/datasource/auth_datasource.dart';
import '../utils/countdown.dart';
import '../utils/enums/reset_link_message.dart';
import 'forgot_password_state.dart';

/// Forgot password (S2) and its "link sent" dialog (S9), one flow
/// (docs/specs/auth/screens/s2-forgot-password.md). The resend cooldown lives with the screen, so reopening
/// the dialog does not skip it.
@injectable
class ForgotPasswordCubit extends BaseCubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._auth, this._launcher)
    : super(const ForgotPasswordState());

  static const resendCooldown = Duration(seconds: 30);

  final AuthDatasource _auth;
  final LaunchService _launcher;

  final _countdown = Countdown();

  void emailChanged(String value) => emit(state.copyWith(email: value));

  void emailLeft() => emit(state.copyWith(emailTouched: true));

  Future<void> submit() async {
    final email = state.email.trim();
    await run(
      prevent: !state.canSubmit,
      loading: state.copyWith(loading: true, failure: null),
      () => _auth.sendPasswordReset(email),
      onSuccess: (_) {
        _startCooldown(loading: false, sentTo: email);
        return state.copyWith(sentTo: null);
      },
      onFailure: (failure) => state.copyWith(loading: false, failure: failure),
    );
  }

  /// "Resend link" in the dialog; ignored during the cooldown.
  Future<void> resend() async {
    await run(
      prevent: !state.canResend,
      loading: state.copyWith(loading: true),
      () => _auth.sendPasswordReset(state.email.trim()),
      onSuccess: (_) {
        _startCooldown(loading: false);
        _notify(ResetLinkMessage.resent);
      },
      onFailure: (_) {
        _notify(ResetLinkMessage.resendFailed, loading: false);
      },
    );
  }

  Future<void> openEmailApp() async {
    final opened = await _launcher.openEmailApp();
    if (!opened) _notify(ResetLinkMessage.noEmailApp);
  }

  /// "Change email" in the dialog: the view focuses the field.
  void editEmail() =>
      emit(state.copyWith(focusRequest: state.focusRequest + 1));

  /// Emits [message] once: the next emit clears it.
  void _notify(ResetLinkMessage message, {bool? loading}) {
    emit(state.copyWith(message: message, loading: loading ?? state.loading));
    emit(state.copyWith(message: null));
  }

  void _startCooldown({required bool loading, String? sentTo}) {
    emit(
      state.copyWith(
        loading: loading,
        cooldown: resendCooldown,
        sentTo: sentTo,
      ),
    );
    _countdown.start(
      resendCooldown,
      (left) => emit(state.copyWith(cooldown: left)),
    );
  }

  @override
  Future<void> close() {
    _countdown.cancel();
    return super.close();
  }
}
