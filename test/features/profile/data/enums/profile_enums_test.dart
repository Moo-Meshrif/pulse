import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/enums/suggestion_reason.dart';
import 'package:pulse/features/profile/data/enums/suggestion_tab.dart';

void main() {
  test('Gender maps its wire values and gives null otherwise', () {
    expect(Gender.fromJson('female'), Gender.female);
    expect(Gender.fromJson('male'), Gender.male);
    expect(Gender.fromJson('prefer_not_to_say'), Gender.preferNotToSay);
    expect(Gender.fromJson('other'), isNull);
    expect(Gender.fromJson(null), isNull);
    expect(Gender.fromJson(1), isNull);
  });

  test('SignupStep numbers are 0, 3, 4, 5, 6 and parse from JSON', () {
    expect(SignupStep.values.map((s) => s.number), [0, 3, 4, 5, 6]);
    expect(SignupStep.fromJson(0), SignupStep.complete);
    expect(SignupStep.fromJson(3), SignupStep.aboutYou);
    expect(SignupStep.fromJson('4'), SignupStep.profile);
    expect(SignupStep.fromJson(6), SignupStep.follow);
    expect(SignupStep.fromJson(1), isNull);
    expect(SignupStep.fromJson(null), isNull);
  });

  test('only a finished sign-up is not pending', () {
    expect(SignupStep.complete.isPending, isFalse);
    expect(SignupStep.profile.isPending, isTrue);
  });

  test('SuggestionReason maps its wire values', () {
    expect(SuggestionReason.fromJson('mutual'), SuggestionReason.mutual);
    expect(SuggestionReason.fromJson('city'), SuggestionReason.city);
    expect(SuggestionReason.fromJson('popular'), SuggestionReason.popular);
    expect(SuggestionReason.fromJson('school'), isNull);
  });

  test('SuggestionTab values are the RPC arguments', () {
    expect(SuggestionTab.suggested.value, 'suggested');
    expect(SuggestionTab.popular.value, 'popular');
  });
}
