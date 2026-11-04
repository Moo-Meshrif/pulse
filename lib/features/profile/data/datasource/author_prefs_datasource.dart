import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/report_reason.dart';
import '../../../../core/error/guard.dart';

/// Reads and updates the caller's preferences for another profile.
@injectable
class AuthorPrefsDatasource {
  AuthorPrefsDatasource(this._client);
  final SupabaseClient _client;

  /// Returns close friends, post notifications, post mute and story mute, in that order.
  Future<List<bool>> load(String userId) => Guard.run(() async {
    final uid = _client.auth.currentUser!.id;
    final rows = await Future.wait([
      _client
          .from('close_friends')
          .select('friend_id')
          .eq('user_id', uid)
          .eq('friend_id', userId),
      _client
          .from('post_subscriptions')
          .select('author_id')
          .eq('user_id', uid)
          .eq('author_id', userId),
      _client
          .from('mutes')
          .select('muted_id')
          .eq('user_id', uid)
          .eq('muted_id', userId),
      _client
          .from('story_mutes')
          .select('muted_id')
          .eq('user_id', uid)
          .eq('muted_id', userId),
    ]);
    return rows.map((row) => row.isNotEmpty).toList();
  });

  Future<void> set(
    String userId, {
    required bool enabled,
    required bool closeFriend,
  }) => Guard.run(() async {
    final uid = _client.auth.currentUser!.id;
    final table = closeFriend ? 'close_friends' : 'post_subscriptions';
    final column = closeFriend ? 'friend_id' : 'author_id';
    if (enabled) {
      await _client.from(table).insert({'user_id': uid, column: userId});
    } else {
      await _client.from(table).delete().eq('user_id', uid).eq(column, userId);
    }
  });

  /// Sends a profile report; throws a Failure if it cannot be submitted.
  Future<void> report(String userId, ReportReason reason, String? note) =>
      Guard.run(
        () => _client.rpc<void>(
          'report_user',
          params: {'p_user': userId, 'p_reason': reason.wire, 'p_note': note},
        ),
      );
}
