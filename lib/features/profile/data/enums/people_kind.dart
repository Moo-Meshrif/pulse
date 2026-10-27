import '../../../../core/utils/json_mapper.dart';

/// Which list of people a person's page opens: who follows them, who they follow, or the people you
/// follow who follow them ("Followed by").
enum PeopleKind {
  followers(value: 'followers', function: 'followers_of'),
  following(value: 'following', function: 'following_of'),
  mutual(value: 'mutual', function: 'mutual_followers');

  const PeopleKind({required this.value, required this.function});

  /// Value in the route (`/people?kind=`).
  final String value;

  /// The Supabase function that answers the list.
  final String function;

  /// Null for a missing or unrecognised value.
  static PeopleKind? fromJson(Object? json) {
    final value = JsonMapper.string(json);
    for (final kind in values) {
      if (kind.value == value) return kind;
    }
    return null;
  }
}
