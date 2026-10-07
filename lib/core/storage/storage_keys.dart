/// Every key persisted through [LocalStorageService], grouped by feature. Lives in core so a feature
/// can read a key another feature writes without importing across features. The string is the persisted
/// name: never change it once shipped.
abstract final class StorageKeys {
  // onboarding
  static const onboardingSeen = 'onboarding_seen';
}
