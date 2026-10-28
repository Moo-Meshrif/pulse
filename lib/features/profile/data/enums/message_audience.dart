import '../../../../core/utils/json_mapper.dart';

/// Who may message the person (`profiles.who_can_message`).
enum MessageAudience {
  everyone(wire: 'everyone'),
  following(wire: 'following'),
  none(wire: 'none');

  const MessageAudience({required this.wire});

  final String wire;

  /// [everyone] for a missing or unrecognised value.
  static MessageAudience fromJson(Object? json) {
    final value = JsonMapper.string(json);
    for (final audience in values) {
      if (audience.wire == value) return audience;
    }
    return everyone;
  }
}
