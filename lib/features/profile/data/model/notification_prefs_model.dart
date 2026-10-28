import '../../../../core/utils/json_mapper.dart';
import '../enums/notification_pref.dart';

/// The caller's notification switches. A switch the server did not send (or no saved row yet) has its
/// default.
class NotificationPrefsModel {
  const NotificationPrefsModel(this._values);

  factory NotificationPrefsModel.fromJson(Map<String, dynamic>? json) =>
      NotificationPrefsModel({
        for (final pref in NotificationPref.values)
          pref: JsonMapper.boolean(json?[pref.wire]) ?? pref.defaultValue,
      });

  final Map<NotificationPref, bool> _values;

  bool operator [](NotificationPref pref) => _values[pref]!;

  NotificationPrefsModel withValue(NotificationPref pref, bool value) =>
      NotificationPrefsModel({..._values, pref: value});
}
