import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../data/model/privacy_settings_model.dart';

part 'privacy_state.freezed.dart';

@freezed
abstract class PrivacyState with _$PrivacyState {
  const factory PrivacyState({
    /// The choices; null until they load.
    PrivacySettingsModel? settings,

    /// The choices could not be read: the page offers a retry.
    @Default(false) bool loadFailed,

    /// How many accounts are blocked; null until known.
    int? blockedCount,

    /// Why the last save failed (the choice is back to its old value); the screen shows it once.
    Failure? failure,
  }) = _PrivacyState;
}
