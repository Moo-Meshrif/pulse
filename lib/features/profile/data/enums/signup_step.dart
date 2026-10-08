import '../../../../core/utils/json_mapper.dart';

/// The next sign-up step, as `profiles.signup_step` stores it (3 About you, 4 Profile, 5 Interests,
/// 6 Follow); [complete] (0) means sign-up is finished. The app reads it to resume a sign-up.
enum SignupStep {
  complete(number: 0),
  aboutYou(number: 3),
  profile(number: 4),
  interests(number: 5),
  follow(number: 6);

  const SignupStep({required this.number});

  /// Wire value in JSON; also the step shown as "Step N of 6" (0 for [complete]).
  final int number;

  /// Sign-up still has steps to do.
  bool get isPending => this != complete;

  /// `null` for a missing or unrecognised value.
  static SignupStep? fromJson(Object? json) {
    final number = JsonMapper.integer(json);
    for (final step in values) {
      if (step.number == number) return step;
    }
    return null;
  }
}
