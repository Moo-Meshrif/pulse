import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/storage/local_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';
import '../../../../shared/content/data/enums/content_audience.dart';

/// Local flags: was the "who will see this" notice shown for Close friends and for Only me? Each shows
/// once, the first time a post goes to that audience.
@lazySingleton
class VisibilityNoticeDatasource {
  VisibilityNoticeDatasource(this._storage);

  final LocalStorageService _storage;

  bool isSeen(ContentAudience visibility) =>
      _storage.getValue<bool>(
        StorageKeys.postVisibilityNoticeSeen(visibility.wire),
      ) ??
      false;

  /// A failed write is reported and ignored: the notice would just show once more.
  Future<void> markSeen(ContentAudience visibility) async {
    try {
      await _storage.setValue(
        StorageKeys.postVisibilityNoticeSeen(visibility.wire),
        true,
      );
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
