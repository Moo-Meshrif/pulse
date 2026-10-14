import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';

/// The files of posts, shorts and stories: the private `post-media` bucket, `{uid}/{id}/…` for a post
/// and `{uid}/stories/…` for a story. Cleanup after a delete is best effort: nothing here throws, because
/// the row is already gone and leftover files are not worth failing the delete.
abstract interface class MediaFilesDatasource {
  /// The paths of the files in the signed-in user's folder [name]; empty when the listing fails.
  Future<List<String>> listFolder(String name);

  /// Removes [paths]; a failure is ignored.
  Future<void> remove(List<String> paths);
}

/// [MediaFilesDatasource] as an adapter over Supabase storage.
@LazySingleton(as: MediaFilesDatasource)
final class SupabaseMediaFilesDatasource implements MediaFilesDatasource {
  SupabaseMediaFilesDatasource(this._client);

  static const _bucket = 'post-media';

  final SupabaseClient _client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<List<String>> listFolder(String name) async {
    try {
      final folder = '$_uid/$name';
      final objects = await _client.storage.from(_bucket).list(path: folder);
      return [for (final object in objects) '$folder/${object.name}'];
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> remove(List<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await _client.storage.from(_bucket).remove(paths);
    } on Object {
      // The content is gone; leftover files are not worth an error.
    }
  }
}
