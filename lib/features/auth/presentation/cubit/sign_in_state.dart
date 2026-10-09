import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';

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
  }) = _SignInState;

  bool get throttled => retryIn != null;

  /// Both fields have text, nothing is in flight and the throttle is over.
  bool get canSubmit =>
      identifier.trim().isNotEmpty &&
      password.isNotEmpty &&
      !loading &&
      !throttled;
}
