import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/storage_keys.dart';
import '../model/content_discard_model.dart';

/// The signed-in user's discards that the server has not confirmed yet, kept on this device so a discard
/// made offline, or cut short by the app closing, is finished later. Each user has their own list.
abstract interface class ContentDiscardsDatasource {
  /// Oldest first; empty when there are none, the list cannot be read, or no one is signed in.
  List<ContentDiscardModel> read();

  /// Adds [discard], unless its id is in the list already.
  Future<void> add(ContentDiscardModel discard);

  /// Takes [id] off the list.
  Future<void> remove(String id);
}

@LazySingleton(as: ContentDiscardsDatasource)
final class LocalContentDiscardsDatasource
    implements ContentDiscardsDatasource {
  LocalContentDiscardsDatasource(this._storage, this._client);

  final LocalStorageService _storage;
  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  @override
  List<ContentDiscardModel> read() {
    final uid = _uid;
    if (uid == null) return const [];
    return _storage.getValue<List<ContentDiscardModel>>(
          StorageKeys.contentDiscards(uid),
          decode: _decode,
        ) ??
        const [];
  }

  @override
  Future<void> add(ContentDiscardModel discard) => Guard.run(() async {
    final saved = read();
    if (saved.any((item) => item.id == discard.id)) return;
    await _write([...saved, discard]);
  }, checkOffline: false);

  @override
  Future<void> remove(String id) => Guard.run(() async {
    final saved = read();
    if (!saved.any((item) => item.id == id)) return;
    await _write([
      for (final item in saved)
        if (item.id != id) item,
    ]);
  }, checkOffline: false);

  Future<void> _write(List<ContentDiscardModel> discards) async {
    final uid = _uid;
    if (uid == null) return;
    final key = StorageKeys.contentDiscards(uid);
    if (discards.isEmpty) {
      await _storage.remove(key);
      return;
    }
    await _storage.setValue<List<ContentDiscardModel>>(
      key,
      discards,
      encode: (value) => [for (final item in value) item.toJson()],
    );
  }

  static List<ContentDiscardModel>? _decode(Object? json) => json is List
      ? [
          for (final item in json)
            if (item is Map<String, dynamic>)
              ContentDiscardModel.fromJson(item),
        ]
      : null;
}
