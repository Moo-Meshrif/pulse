import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../utils/email_format.dart';
import '../utils/enums/reset_link_message.dart';

part 'forgot_password_state.freezed.dart';

/// State of Forgot password and its "link sent" dialog; the one-shot fields are signals the UI reacts to
/// once.
@freezed
abstract class ForgotPasswordState with _$ForgotPasswordState {
  const ForgotPasswordState._();

  const factory ForgotPasswordState({
    @Default('') String email,

    /// A send or a resend is in flight.
    @Default(false) bool loading,

    /// The user left the email field; the format error may show from now on.
    @Default(false) bool emailTouched,

    /// Why sending failed; the screen shows a snackbar.
    Failure? failure,

    /// Time left before "Resend link" works; zero when it may be used.
    @Default(Duration.zero) Duration cooldown,

    /// One-shot: the link was sent to this email, so the screen opens the "link sent" dialog.
    String? sentTo,

    /// One-shot: a notice for the dialog's snackbar.
    ResetLinkMessage? message,

    /// Counts "Change email" taps: the view moves the focus to the field when it grows.
    @Default(0) int focusRequest,
  }) = _ForgotPasswordState;

  bool get emailValid => isValidEmail(email);

  bool get emailInvalidShown => emailTouched && email.isNotEmpty && !emailValid;

  bool get canSubmit => emailValid && !loading;

  bool get canResend => cooldown <= Duration.zero && !loading;
}
