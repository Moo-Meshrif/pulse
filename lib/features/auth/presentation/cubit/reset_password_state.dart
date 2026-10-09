import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../utils/password_policy.dart';

part 'reset_password_state.freezed.dart';

/// What Set a new password shows (docs/specs/auth/screens/s11-set-new-password.md).
@freezed
abstract class ResetPasswordState with _$ResetPasswordState {
  const ResetPasswordState._();

  const factory ResetPasswordState({
    /// The recovery session's email; null when no recovery session exists (the link expired).
    String? email,
    @Default('') String password,
    @Default('') String confirm,
    @Default(true) bool logoutOthers,
    @Default(false) bool loading,
    Failure? failure,

    /// The password was changed; the screen shows the "Password updated" dialog.
    @Default(false) bool updated,

    /// With [updated]: the other devices were signed out too (the body of the dialog says so).
    @Default(false) bool othersLoggedOut,

    /// One-shot: where the screen goes next (Sign in).
    String? route,
  }) = _ResetPasswordState;

  bool get linkExpired => email == null;

  bool get mismatch => confirm.isNotEmpty && confirm != password;

  bool get canSubmit =>
      !loading &&
      !updated &&
      PasswordPolicy.meetsResetRules(password) &&
      confirm == password;
}
