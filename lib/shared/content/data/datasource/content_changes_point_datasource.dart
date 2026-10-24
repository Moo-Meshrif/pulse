import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/services/storage/local_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';
import '../enums/content_kind.dart';
import '../model/content_changes_point_model.dart';

/// Where the last check of each kind stopped, kept on this device. Each user has their own points.
abstract interface class ContentChangesPointDatasource {
  /// Null when there is none, it cannot be read, or no one is signed in.
  ContentChangesPointModel? read(ContentKind kind);

  Future<void> write(ContentKind kind, ContentChangesPointModel point);
}

@LazySingleton(as: ContentChangesPointDatasource)
final class LocalContentChangesPointDatasource
    implements ContentChangesPointDatasource {
  LocalContentChangesPointDatasource(this._storage, this._client);

  final LocalStorageService _storage;
  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  ContentChangesPointModel? read(ContentKind kind) {
    final uid = _uid;
    if (uid == null) return null;
    return _storage.getValue<ContentChangesPointModel>(
      StorageKeys.contentChangesPoint(uid, kind.wire),
      decode: (json) => json is Map<String, dynamic>
          ? ContentChangesPointModel.fromJson(json)
          : null,
    );
  }

  @override
  Future<void> write(ContentKind kind, ContentChangesPointModel point) =>
      Guard.run(() async {
        final uid = _uid;
        if (uid == null) return;
        await _storage.setValue<ContentChangesPointModel>(
          StorageKeys.contentChangesPoint(uid, kind.wire),
          point,
          encode: (value) => value.toJson(),
        );
      }, checkOffline: false);
}
