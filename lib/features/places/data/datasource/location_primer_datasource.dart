import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/storage/local_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';

/// Local flag: the person chose "Not now" on the location permission primer, so a location picker does not
/// ask again every time it opens.
@lazySingleton
class LocationPrimerDatasource {
  LocationPrimerDatasource(this._storage);

  final LocalStorageService _storage;

  bool get isDismissed =>
      _storage.getValue<bool>(StorageKeys.locationPrimerDismissed) ?? false;

  /// A failed write is reported and ignored: the primer would just show once more.
  Future<void> markDismissed() async {
    try {
      await _storage.setValue(StorageKeys.locationPrimerDismissed, true);
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
