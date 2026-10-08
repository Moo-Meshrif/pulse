import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/entity/profile_update_entity.dart';

void main() {
  test('profiles with the same fields are equal', () {
    const a = ProfileEntity(
      id: 'u',
      username: 'dip',
      gender: Gender.male,
      signupStep: SignupStep.profile,
    );
    const b = ProfileEntity(
      id: 'u',
      username: 'dip',
      gender: Gender.male,
      signupStep: SignupStep.profile,
    );
    expect(a, b);
    expect(a, isNot(const ProfileEntity(id: 'u', username: 'other')));
  });

  test('isSignupComplete is true only for the complete step', () {
    expect(
      const ProfileEntity(signupStep: SignupStep.complete).isSignupComplete,
      isTrue,
    );
    expect(
      const ProfileEntity(signupStep: SignupStep.follow).isSignupComplete,
      isFalse,
    );
    expect(const ProfileEntity().isSignupComplete, isFalse);
  });

  test('an update with nothing set equals another empty one', () {
    expect(const ProfileUpdateEntity(), const ProfileUpdateEntity());
    expect(
      const ProfileUpdateEntity(bio: 'a'),
      isNot(const ProfileUpdateEntity(bio: 'b')),
    );
  });
}
