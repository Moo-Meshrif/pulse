import '../../../../core/utils/json_mapper.dart';

/// Why a profile is suggested; presentation builds the meta line from it (mutual friends, city).
enum SuggestionReason {
  mutual(value: 'mutual'),
  city(value: 'city'),
  popular(value: 'popular');

  const SuggestionReason({required this.value});

  /// Wire value in JSON (`reason_kind`).
  final String value;

  /// `null` for a missing or unrecognised value.
  static SuggestionReason? fromJson(Object? json) {
    final value = JsonMapper.string(json);
    for (final reason in values) {
      if (reason.value == value) return reason;
    }
    return null;
  }
}
