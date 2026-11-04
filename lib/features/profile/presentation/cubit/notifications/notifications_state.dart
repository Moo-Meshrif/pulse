import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../data/model/notification_prefs_model.dart';

part 'notifications_state.freezed.dart';

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    /// The switches; null until they load.
    NotificationPrefsModel? prefs,

    /// The switches could not be read: the page offers a retry.
    @Default(false) bool loadFailed,

    /// Why the last save failed (the switch is back to its old value); the screen shows it once.
    Failure? failure,
  }) = _NotificationsState;
}
