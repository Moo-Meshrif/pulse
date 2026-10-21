import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../enums/content_kind.dart';
import '../model/content_changes_model.dart';
import '../model/post_count_model.dart';

/// What changed in posts, shorts and stories since a point, and the counts of posts on screen. Every call
/// throws a `Failure` on error.
abstract interface class ContentChangesDatasource {
  /// A page of changes of [kind] after the point ([afterAt], [afterId]); a null [afterAt] asks for a
  /// starting point (the answer is a reset that carries one).
  Future<ContentChangesModel> changesSince(
    ContentKind kind, {
    DateTime? afterAt,
    String? afterId,
  });

  /// The counts of the posts [ids] the signed-in user can see (up to 100).
  Future<List<PostCountModel>> postCounts(List<String> ids);
}

/// [ContentChangesDatasource] as an adapter over the `changes_since` and `post_counts` functions.
@LazySingleton(as: ContentChangesDatasource)
final class SupabaseContentChangesDatasource
    implements ContentChangesDatasource {
  SupabaseContentChangesDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<ContentChangesModel> changesSince(
    ContentKind kind, {
    DateTime? afterAt,
    String? afterId,
  }) => Guard.run(() async {
    final json = await _client.rpc<Map<String, dynamic>>(
      'changes_since',
      params: {
        'p_kind': kind.wire,
        'p_after_at': afterAt?.toUtc().toIso8601String(),
        'p_after_id': afterId,
      },
    );
    return ContentChangesModel.fromJson(json);
  });

  @override
  Future<List<PostCountModel>> postCounts(List<String> ids) =>
      Guard.run(() async {
        final rows = await _client.rpc<List<dynamic>>(
          'post_counts',
          params: {'p_ids': ids},
        );
        return [
          for (final row in rows)
            if (row is Map<String, dynamic>) PostCountModel.fromJson(row),
        ];
      });
}
