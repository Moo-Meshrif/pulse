import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../data/model/settings_summary_model.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    /// The values beside the rows; null until they arrive (the rows show no value) or when they fail.
    SettingsSummaryModel? summary,

    /// The app version, e.g. `1.2.0`; null until read.
    String? version,
    @Default(true) bool autoplayShorts,
    @Default(false) bool dataSaver,
    @Default(false) bool isLoggingOut,
    @Default(false) bool isDeleting,

    /// The password typed to delete the account was wrong; the dialog shows it under the field.
    @Default(false) bool passwordWrong,

    /// This device's session is gone and local data is cleared: the screen leaves to Sign in.
    @Default(false) bool signedOut,

    /// Why the last log out or delete failed; the screen shows it once.
    Failure? failure,
  }) = _SettingsState;
}
