import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../model/unread_activity_model.dart';

/// The Activity feed of the signed-in person (notifications and follow requests).
abstract interface class ActivityDatasource {
  /// How much is waiting: unread notifications and follow requests.
  Future<UnreadActivityModel> getUnreadCount();
}

/// [ActivityDatasource] as an adapter over Supabase: the `activity_unread_count` function
/// (supabase/migrations/20261014120000_notifications.sql).
@LazySingleton(as: ActivityDatasource)
final class SupabaseActivityDatasource implements ActivityDatasource {
  SupabaseActivityDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<UnreadActivityModel> getUnreadCount() => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>('activity_unread_count');
    final row = List<Map<String, dynamic>>.from(rows).firstOrNull;
    return row == null
        ? const UnreadActivityModel()
        : UnreadActivityModel.fromJson(row);
  });
}
