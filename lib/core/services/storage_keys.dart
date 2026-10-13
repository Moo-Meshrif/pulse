/// Every key persisted through [LocalStorageService]. Lives in core so features can share a key. Never
/// change a shipped string.
abstract final class StorageKeys {
  static const onboardingSeen = 'onboarding_seen';

  // profile: the copy of the signed-in user's profile, one entry per user id
  static String profile(String userId) => 'profile_$userId';

  // profile: the id of the user whose copy was saved last, so Sign in can name the account after the
  // session (and so the id) is gone
  static const lastAccount = 'last_account_id';

  // auth: a password reset was started on this device and not finished (the recovery session is open)
  static const recoveryPending = 'recovery_pending';

  // story: the camera hint ("Tap for photo, hold for video") was shown and a story was captured
  static const storyCameraHintSeen = 'story_camera_hint_seen';
}
