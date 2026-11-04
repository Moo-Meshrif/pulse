import '../../../../core/utils/json_mapper.dart';

/// Who may comment on the person's posts (`profiles.who_can_comment`); the server enforces it.
enum CommentAudience {
  everyone(wire: 'everyone'),
  followers(wire: 'followers'),
  none(wire: 'none');

  const CommentAudience({required this.wire});

  final String wire;

  /// [everyone] for a missing or unrecognised value.
  static CommentAudience fromJson(Object? json) {
    final value = JsonMapper.string(json);
    for (final audience in values) {
      if (audience.wire == value) return audience;
    }
    return everyone;
  }
}
