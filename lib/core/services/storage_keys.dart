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

  // post: the one-time "who will see this" notice was shown for this audience (wire value of the choice)
  static String postVisibilityNoticeSeen(String wire) =>
      'post_visibility_notice_seen_$wire';

  // places: the last places picked (a post's location), newest first
  static const recentPlaces = 'recent_places';

  // places: "Not now" was chosen on the location permission primer
  static const locationPrimerDismissed = 'location_primer_dismissed';
}
