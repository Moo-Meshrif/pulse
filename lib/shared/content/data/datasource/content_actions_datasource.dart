import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/report_reason.dart';
import '../../../../core/error/guard.dart';
import '../enums/content_audience.dart';
import '../enums/content_kind.dart';
import '../enums/mute_scope.dart';

/// What a person does to a post, a short or a story the same way: report it, change who can see it,
/// mute its author. Core, so every feature that shows content shares one path. Every call throws a
/// `Failure` on error.
abstract interface class ContentActionsDatasource {
  /// Reports [id]; for a post or a short the server also hides it for the reporter.
  Future<void> report(
    ContentKind kind,
    String id,
    ReportReason reason, {
    String? note,
  });

  /// Changes who can see your content [id]. A story only takes Followers and Close friends.
  Future<void> setAudience(
    ContentKind kind,
    String id,
    ContentAudience audience,
  );

  /// Mutes [userId] ([muted]) or brings them back (Undo) for [scope].
  Future<void> setMuted(
    String userId, {
    required bool muted,
    required MuteScope scope,
  });
}

/// [ContentActionsDatasource] as an adapter over Supabase: `report_content`, `set_content_audience`
/// and `set_mute`.
@LazySingleton(as: ContentActionsDatasource)
final class SupabaseContentActionsDatasource
    implements ContentActionsDatasource {
  SupabaseContentActionsDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<void> report(
    ContentKind kind,
    String id,
    ReportReason reason, {
    String? note,
  }) => Guard.run(
    () => _client.rpc<dynamic>(
      'report_content',
      params: {
        'p_kind': kind.wire,
        'p_id': id,
        'p_reason': reason.wire,
        'p_note': note,
      },
    ),
  );

  @override
  Future<void> setAudience(
    ContentKind kind,
    String id,
    ContentAudience audience,
  ) => Guard.run(
    () => _client.rpc<dynamic>(
      'set_content_audience',
      params: {'p_kind': kind.wire, 'p_id': id, 'p_audience': audience.wire},
    ),
  );

  @override
  Future<void> setMuted(
    String userId, {
    required bool muted,
    required MuteScope scope,
  }) => Guard.run(
    () => _client.rpc<dynamic>(
      'set_mute',
      params: {'p_user': userId, 'p_muted': muted, 'p_scope': scope.wire},
    ),
  );
}
