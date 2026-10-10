import '../../../../core/utils/json_mapper.dart';

/// Where a follow stands: [pending] until the followed user accepts (private profiles), then [accepted].
/// [none] is no follow at all.
enum FollowStatus {
  none(value: 'none'),
  pending(value: 'pending'),
  accepted(value: 'accepted');

  const FollowStatus({required this.value});

  /// Wire value in JSON (`follows.status`).
  final String value;

  /// [none] for a missing or unrecognised value.
  static FollowStatus fromJson(Object? json) {
    final value = JsonMapper.string(json);
    for (final status in values) {
      if (status.value == value) return status;
    }
    return none;
  }
}
