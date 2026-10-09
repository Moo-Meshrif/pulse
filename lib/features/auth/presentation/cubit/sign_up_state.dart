import 'package:clock/clock.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/photo_picker_service.dart';
import '../../../profile/data/enums/gender.dart';
import '../../../profile/data/enums/suggestion_tab.dart';
import '../../../profile/data/model/interest_model.dart';
import '../../../profile/data/model/suggested_profile_model.dart';
import '../utils/birthday.dart';
import '../utils/email_format.dart';
import '../utils/enums/follow_tab.dart';
import '../utils/enums/load_status.dart';
import '../utils/password_policy.dart';
import '../utils/phone_format.dart';
import '../utils/username_format.dart';
import '../widgets/otp_field.dart';

part 'sign_up_state.freezed.dart';

/// What the sign-up flow shows (docs/specs/auth/00-overview.md): the current [step] (1 Account, 2 Verify
/// email, 3 to 6 the profile steps) and the values that must survive moving between steps.
@freezed
abstract class SignUpState with _$SignUpState {
  const SignUpState._();

  const factory SignUpState({
    /// 1 to 6, as "Step N of 6" shows it.
    @Default(1) int step,
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool termsAccepted,

    /// The field was left once, so its format error may show.
    @Default(false) bool emailTouched,
    @Default(false) bool passwordTouched,

    /// The 6 digits typed on the Verify email step.
    @Default('') String code,

    /// About you (step 3).
    @Default('') String fullName,
    @Default('') String username,
    @Default(false) bool usernameTouched,
    DateTime? birthday,
    Gender? gender,

    /// Profile (step 4): everything is optional.
    PickedPhoto? photo,
    @Default('') String bio,
    @Default('') String city,
    @Default('') String phone,
    @Default(false) bool phoneTouched,

    /// Interests (step 5): the topics, loaded when Profile is left.
    @Default(LoadStatus.idle) LoadStatus interestsStatus,
    @Default([]) List<InterestModel> interests,
    @Default({}) Set<int> selectedInterests,

    /// Follow (step 6): the people per backend tab, loaded when Interests is left.
    @Default(FollowTab.suggested) FollowTab followTab,
    @Default({}) Map<SuggestionTab, LoadStatus> peopleStatus,
    @Default({}) Map<SuggestionTab, List<SuggestedProfileModel>> people,
    @Default({}) Set<String> following,
    @Default(false) bool loading,

    /// Why the last request failed; cleared when the user edits the field it belongs to.
    Failure? failure,

    /// One-shot: where the flow goes when it ends (Home, or Sign in after leaving). The Cubit clears it
    /// right after emitting it.
    String? route,

    /// Time left before "Resend code" works again; null when it works.
    Duration? resendIn,
  }) = _SignUpState;

  bool get emailValid => isValidEmail(email);

  bool get emailInvalidShown => emailTouched && email.isNotEmpty && !emailValid;

  bool get passwordShortShown =>
      passwordTouched &&
      password.isNotEmpty &&
      !PasswordPolicy.hasMinLength(password);

  bool get emailTaken => switch (failure) {
    AuthFailure(reason: AuthFailureReason.emailTaken) => true,
    _ => false,
  };

  bool get wrongCode => switch (failure) {
    AuthFailure(reason: AuthFailureReason.invalidCode) => true,
    _ => false,
  };

  bool get canSubmitAccount =>
      !loading &&
      emailValid &&
      PasswordPolicy.hasMinLength(password) &&
      termsAccepted;

  bool get canVerify => !loading && code.length == OtpField.length;

  bool get usernameInvalidShown =>
      usernameTouched && username.isNotEmpty && !isValidUsername(username);

  bool get usernameTaken => failure is ConflictFailure;

  bool get underage => birthday != null && !isOldEnough(birthday!, clock.now());

  bool get canSubmitAbout =>
      !loading &&
      fullName.trim().isNotEmpty &&
      isValidUsername(username) &&
      birthday != null &&
      !underage;

  bool get phoneInvalidShown =>
      phoneTouched && phone.trim().isNotEmpty && !isValidPhone(phone.trim());

  bool get canSubmitProfile =>
      !loading && (phone.trim().isEmpty || isValidPhone(phone.trim()));

  LoadStatus get followStatus => followTab.source == null
      ? LoadStatus.loaded
      : peopleStatus[followTab.source] ?? LoadStatus.idle;

  /// The people the current tab lists.
  List<SuggestedProfileModel> get visiblePeople =>
      people[followTab.source] ?? const [];

  bool get canResend => !loading && resendIn == null;

  /// Every failure goes to a snackbar, as on Sign in; no field shows a backend error.
  Failure? get toastFailure => failure;
}
