import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';

/// Local flag: has the user finished the onboarding flow (Skip, Get started or Sign in)?
/// Writes the `onboarding_seen` key ([StorageKeys.onboardingSeen]); storage goes through the shared [LocalStorageService].
@lazySingleton
class OnboardingDatasource {
  OnboardingDatasource(this._storage);

  final LocalStorageService _storage;

  bool get isSeen =>
      _storage.getValue<bool>(StorageKeys.onboardingSeen) ?? false;

  /// A failed write is reported but never blocks leaving onboarding: the user would just see it once more.
  Future<void> markSeen() async {
    try {
      await _storage.setValue(StorageKeys.onboardingSeen, true);
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
