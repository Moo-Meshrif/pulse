import '../../../follow/data/enums/follow_status.dart';
import '../../../follow/data/model/suggested_profile_model.dart';

/// The pure rules behind the Follow step's instant follow / unfollow.
abstract final class FollowChanges {
  /// What the backend will answer for [id]: a request for a private profile, else a follow.
  static FollowStatus expectedStatus(
    Iterable<List<SuggestedProfileModel>> lists,
    String id,
  ) {
    final person = [for (final list in lists) ...list]
        .where((person) => person.id == id)
        .firstOrNull;
    return person?.isPrivate == true
        ? FollowStatus.pending
        : FollowStatus.accepted;
  }

  /// [follows] with each change applied; `null` (or none) removes the person.
  static Map<String, FollowStatus> apply(
    Map<String, FollowStatus> follows,
    Map<String, FollowStatus?> changes,
  ) {
    final result = {...follows};
    for (final MapEntry(:key, :value) in changes.entries) {
      value == null || value == FollowStatus.none
          ? result.remove(key)
          : result[key] = value;
    }
    return result;
  }
}
