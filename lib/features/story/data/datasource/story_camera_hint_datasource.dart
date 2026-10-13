import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/storage_keys.dart';

/// Local flag: was a story captured before? The camera then stops showing "Tap for photo, hold for video".
@lazySingleton
class StoryCameraHintDatasource {
  StoryCameraHintDatasource(this._storage);

  final LocalStorageService _storage;

  bool get isSeen =>
      _storage.getValue<bool>(StorageKeys.storyCameraHintSeen) ?? false;

  /// A failed write is reported and ignored: the hint would just show once more.
  Future<void> markSeen() async {
    try {
      await _storage.setValue(StorageKeys.storyCameraHintSeen, true);
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
