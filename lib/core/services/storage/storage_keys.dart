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

  // post: the New post draft of one user (caption, settings, the names of its files in post_drafts/)
  static String postDraft(String userId) => 'post_draft_$userId';

  // post: the posts one user shared that are not out yet (each like a draft, its files in post_drafts/)
  static String postShared(String userId) => 'post_shared_$userId';

  // content: the discards of one user the server has not confirmed yet (id and kind of each)
  static String contentDiscards(String userId) => 'content_discards_$userId';

  // content: where the last check for changes stopped, one per user and kind (post, short, story)
  static String contentChangesPoint(String userId, String kind) =>
      'content_changes_${kind}_$userId';

  // places: the last places picked (a post's location), newest first
  static const recentPlaces = 'recent_places';

  // places: "Not now" was chosen on the location permission primer
  static const locationPrimerDismissed = 'location_primer_dismissed';

  // post: the first page of one user's Home feed in SnapshotStorage (no signed media links)
  static String feed(String userId) => 'feed_$userId';

  // story: the Stories rail of one user in SnapshotStorage
  static String storyRail(String userId) => 'story_rail_$userId';
}
