import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/storage_keys.dart';
import '../model/profile_model.dart';

/// The profile saved on this device, one entry per user. Preferences are not encrypted, so phone and
/// birthday are never written.
@lazySingleton
class ProfileLocalDatasource {
  ProfileLocalDatasource(this._storage);

  final LocalStorageService _storage;

  ProfileModel? read(String userId) => _storage.getValue<ProfileModel>(
    StorageKeys.profile(userId),
    decode: (json) =>
        json is Map<String, dynamic> ? ProfileModel.fromJson(json) : null,
  );

  /// A failed write is reported and never fails the caller: the server already has the data.
  Future<void> write(ProfileModel profile) async {
    final id = profile.id;
    if (id == null) return;
    try {
      await _storage.setValue<ProfileModel>(
        StorageKeys.profile(id),
        profile,
        encode: (p) => p.toJson()
          ..remove('phone')
          ..remove('birthday'),
      );
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }

  Future<void> clear(String userId) async {
    try {
      await _storage.remove(StorageKeys.profile(userId));
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
