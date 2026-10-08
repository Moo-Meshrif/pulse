/// Every key persisted through [LocalStorageService]. Lives in core so features can share a key. Never
/// change a shipped string.
abstract final class StorageKeys {
  static const onboardingSeen = 'onboarding_seen';

  // profile: the copy of the signed-in user's profile, one entry per user id
  static String profile(String userId) => 'profile_$userId';
}
