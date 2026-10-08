import '../../../../core/utils/json_mapper.dart';

/// The optional gender chosen on the About-you step; the wire value is what `profiles.gender` stores.
enum Gender {
  female(value: 'female'),
  male(value: 'male'),
  preferNotToSay(value: 'prefer_not_to_say');

  const Gender({required this.value});

  /// Wire value in JSON.
  final String value;

  /// `null` for a missing or unrecognised value.
  static Gender? fromJson(Object? json) {
    final value = JsonMapper.string(json);
    for (final gender in values) {
      if (gender.value == value) return gender;
    }
    return null;
  }
}
