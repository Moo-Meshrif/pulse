import 'package:clock/clock.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/services/photo_picker_service.dart';
import '../../../../../core/utils/birthday.dart';
import '../../../../../core/utils/phone_format.dart';
import '../../../../../core/utils/username_format.dart';
import '../../../domain/entity/profile_entity.dart';
import '../../utils/enums/username_status.dart';

part 'personal_info_state.freezed.dart';

@freezed
abstract class PersonalInfoState with _$PersonalInfoState {
  const PersonalInfoState._();

  const factory PersonalInfoState({
    @Default(true) bool isLoading,

    /// Why the profile could not be read; the screen shows a retry.
    Failure? loadFailure,

    /// The profile as saved; the edits are compared with it.
    ProfileEntity? original,
    @Default('') String email,
    @Default('') String fullName,
    @Default('') String username,
    @Default('') String bio,
    @Default('') String city,
    @Default('') String phone,
    DateTime? birthday,

    /// A new picture chosen but not saved yet.
    PickedPhoto? avatar,
    @Default(false) bool removeAvatar,
    PickedPhoto? cover,
    @Default(false) bool removeCover,
    @Default(UsernameStatus.idle) UsernameStatus usernameStatus,
    @Default(false) bool isSaving,

    /// Saved: the screen shows the notice and leaves.
    @Default(false) bool saved,

    /// Why the last save failed; the screen shows it once.
    Failure? failure,
  }) = _PersonalInfoState;

  static const bioMax = 150;
  static const cityMax = 60;
  static const fullNameMax = 80;

  /// The username as the server stores it (lower case).
  String get _usernameKey => username.trim().toLowerCase();

  bool get usernameChanged =>
      _usernameKey != (original?.username ?? '').toLowerCase();

  bool get isUsernameFormatInvalid =>
      username.isNotEmpty && !isValidUsername(username.trim());

  bool get isPhoneInvalid => phone.isNotEmpty && !isValidPhone(phone);

  bool get isBirthdayInvalid {
    final date = birthday;
    return date != null &&
        date != original?.birthday &&
        !isOldEnough(date, clock.now());
  }

  bool get hasPhotoEdits =>
      avatar != null || removeAvatar || cover != null || removeCover;

  /// The text fields differ from the saved profile.
  bool get hasFieldEdits {
    final saved = original;
    if (saved == null) return false;
    return fullName.trim() != (saved.fullName ?? '') ||
        usernameChanged ||
        bio.trim() != (saved.bio ?? '') ||
        city.trim() != (saved.city ?? '') ||
        _digits(phone) != _digits(saved.phone ?? '') ||
        (birthday != null && birthday != saved.birthday);
  }

  bool get isDirty => hasFieldEdits || hasPhotoEdits;

  bool get isValid =>
      fullName.trim().isNotEmpty &&
      !isUsernameFormatInvalid &&
      username.trim().isNotEmpty &&
      (!usernameChanged || usernameStatus == UsernameStatus.free) &&
      !isPhoneInvalid &&
      !isBirthdayInvalid;

  bool get canSave => !isLoading && !isSaving && isDirty && isValid;

  static String _digits(String phone) => phone.replaceAll(RegExp(r'\s'), '');
}
