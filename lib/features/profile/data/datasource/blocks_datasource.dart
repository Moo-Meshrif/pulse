import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../model/blocked_person_model.dart';

/// The people the caller blocked. Every call throws a `Failure` on error.
abstract interface class BlocksDatasource {
  /// A page of blocked people, newest block first. [before] is the last person already shown.
  Future<List<BlockedPersonModel>> list({
    BlockedPersonModel? before,
    int limit = pageSize,
  });

  /// How many people the caller blocked.
  Future<int> count();

  Future<void> block(String userId);

  /// Does not bring the follows between the two back.
  Future<void> unblock(String userId);

  static const pageSize = 20;
}

/// [BlocksDatasource] over `blocked_users`, `block_user` and `unblock_user`.
@LazySingleton(as: BlocksDatasource)
final class SupabaseBlocksDatasource implements BlocksDatasource {
  SupabaseBlocksDatasource(this._client);

  final SupabaseClient _client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<List<BlockedPersonModel>> list({
    BlockedPersonModel? before,
    int limit = BlocksDatasource.pageSize,
  }) => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>(
      'blocked_users',
      params: {
        'p_limit': limit,
        'p_before_time': before?.blockedAt?.toIso8601String(),
        'p_before_id': before?.id,
      },
    );
    return List<Map<String, dynamic>>.from(rows)
        .map(BlockedPersonModel.fromJson)
        .toList();
  });

  @override
  Future<int> count() =>
      Guard.run(() => _client.from('blocks').count().eq('blocker_id', _uid));

  @override
  Future<void> block(String userId) => Guard.run(
    () => _client.rpc<void>('block_user', params: {'p_user': userId}),
  );

  @override
  Future<void> unblock(String userId) => Guard.run(
    () => _client.rpc<void>('unblock_user', params: {'p_user': userId}),
  );
}
