import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/storage/local_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';

/// The Settings switches kept on this phone (Autoplay shorts, Data saver). Storage goes through the
/// shared [LocalStorageService].
@lazySingleton
class AppPreferencesDatasource {
  AppPreferencesDatasource(this._storage);

  final LocalStorageService _storage;

  bool get autoplayShorts =>
      _storage.getValue<bool>(StorageKeys.autoplayShorts) ?? true;

  bool get dataSaver => _storage.getValue<bool>(StorageKeys.dataSaver) ?? false;

  Future<void> setAutoplayShorts(bool value) =>
      _write(StorageKeys.autoplayShorts, value);

  Future<void> setDataSaver(bool value) => _write(StorageKeys.dataSaver, value);

  /// A failed write is reported, never thrown: the switch just does not survive a restart.
  Future<void> _write(String key, bool value) async {
    try {
      await _storage.setValue(key, value);
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
