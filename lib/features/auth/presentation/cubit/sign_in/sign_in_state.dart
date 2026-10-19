import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/enums/signed_out_reason.dart';
import '../../../../../core/error/failures.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';

part 'sign_in_state.freezed.dart';

/// What Sign in shows: the two fields' values (so the button can enable), a request in flight, the
/// last [failure], the throttle countdown and, once it succeeded, where to go next.
@freezed
abstract class SignInState with _$SignInState {
  const SignInState._();

  const factory SignInState({
    @Default('') String identifier,
    @Default('') String password,
    @Default(false) bool loading,

    /// Why the last attempt failed; cleared when the user edits a field.
    Failure? failure,

    /// Time left before another attempt is allowed (too many attempts); null when not throttled.
    Duration? retryIn,

    /// One-shot: where the screen goes next. The Cubit clears it right after emitting it.
    String? route,

    /// With [route]: replace the whole stack (signed in) rather than push (verify email).
    @Default(false) bool clearStack,

    /// Why the session ended, when Sign in was opened for that (S14); null for a plain Sign in.
    SignedOutReason? reason,

    /// The saved account named on the screen (its username is then [identifier]); null when none is known
    /// or after "Not you?".
    LastAccountEntity? account,
  }) = _SignInState;

  bool get throttled => retryIn != null;

  /// Both fields have text, nothing is in flight and the throttle is over.
  bool get canSubmit =>
      identifier.trim().isNotEmpty &&
      password.isNotEmpty &&
      !loading &&
      !throttled;
}
