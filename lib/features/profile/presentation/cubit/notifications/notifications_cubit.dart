import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../data/datasource/notification_prefs_datasource.dart';
import '../../../data/enums/notification_pref.dart';
import 'notifications_state.dart';

/// Settings > Notifications (docs/specs/profile/screens/s7-notifications.md): each switch saves at once,
/// shown first and put back if the save fails.
@injectable
class NotificationsCubit extends BaseCubit<NotificationsState> {
  NotificationsCubit(this._prefs) : super(const NotificationsState());

  final NotificationPrefsDatasource _prefs;

  Future<void> load() => run(
    _prefs.get,
    loading: state.copyWith(loadFailed: false),
    onSuccess: (prefs) => state.copyWith(prefs: prefs),
    onFailure: (_) => state.copyWith(loadFailed: true),
  );

  Future<void> toggle(NotificationPref pref, bool value) async {
    final current = state.prefs;
    if (current == null || current[pref] == value) return;
    // TODO(profile-plan T12): ask the OS permission when push is wired
    emit(state.copyWith(prefs: current.withValue(pref, value), failure: null));
    await run(
      () => _prefs.set(pref, value),
      onSuccess: (_) => null,
      // Only this switch goes back: another one may have changed meanwhile.
      onFailure: (failure) => state.copyWith(
        prefs: state.prefs?.withValue(pref, !value),
        failure: failure,
      ),
    );
  }
}
