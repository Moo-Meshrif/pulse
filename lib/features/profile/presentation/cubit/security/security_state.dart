import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../auth/presentation/utils/password_policy.dart';
import '../../utils/enums/security_notice.dart';

part 'security_state.freezed.dart';

@freezed
abstract class SecurityState with _$SecurityState {
  const SecurityState._();

  const factory SecurityState({
    @Default('') String current,
    @Default('') String next,
    @Default('') String confirm,
    @Default(false) bool isUpdating,
    @Default(false) bool isLoggingOutOthers,

    /// The current password typed was wrong; shown under that field.
    @Default(false) bool currentWrong,

    /// This phone's name; null until read.
    String? deviceName,

    /// One-shot: what the screen tells the user.
    SecurityNotice? notice,

    /// Why the last action failed; the screen shows it once.
    Failure? failure,
  }) = _SecurityState;

  bool get mismatch => confirm.isNotEmpty && confirm != next;

  bool get canUpdate =>
      !isUpdating &&
      current.isNotEmpty &&
      PasswordPolicy.meetsResetRules(next) &&
      confirm == next;
}
