import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/interest_model.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:pulse/features/profile/data/model/profile_update_model.dart';

void main() {
  final json = {
    'id': 'u1',
    'username': 'dip',
    'full_name': 'Dip Roy',
    'birthday': '1999-02-03',
    'gender': 'male',
    'bio': 'hi',
    'city': 'Cairo',
    'phone': '+201234567',
    'avatar_url': 'https://x/y',
    'signup_step': 4,
  };

  group('ProfileModel', () {
    test('reads every column', () {
      final model = ProfileModel.fromJson(json);
      expect(model.id, 'u1');
      expect(model.birthday, DateTime.utc(1999, 2, 3));
      expect(model.gender, Gender.male);
      expect(model.signupStep, SignupStep.profile);
      expect(model.phone, '+201234567');
    });

    test('a new account has only an id and the first step', () {
      final model = ProfileModel.fromJson({
        'id': 'u1',
        'username': null,
        'signup_step': 3,
      });
      expect(model.username, isNull);
      expect(model.signupStep, SignupStep.aboutYou);
    });

    test('wrong types and unknown values become null, never throw', () {
      expect(
        ProfileModel.fromJson({
          'id': 5,
          'gender': 'x',
          'signup_step': 'soon',
          'birthday': 'nope',
        }),
        const ProfileModel(),
      );
    });

    test('toJson round-trips through fromJson', () {
      final model = ProfileModel.fromJson(json);
      expect(ProfileModel.fromJson(model.toJson()), model);
    });

    test('copyWith changes fields, keeps the id, and can clear the avatar', () {
      final model = ProfileModel.fromJson(json);
      final changed = model.copyWith(bio: 'new', signupStep: SignupStep.follow);
      expect(changed.id, 'u1');
      expect(changed.bio, 'new');
      expect(changed.signupStep, SignupStep.follow);
      expect(changed.username, 'dip');
      expect(model.copyWith(clearAvatar: true).avatarUrl, isNull);
      expect(model.copyWith().avatarUrl, 'https://x/y');
    });
  });

  group('ProfileUpdateModel', () {
    test('sends only the fields that are set', () {
      expect(
        const ProfileUpdateModel(
          bio: 'hi',
          signupStep: SignupStep.interests,
        ).toJson(),
        {'bio': 'hi', 'signup_step': 5},
      );
      expect(const ProfileUpdateModel().toJson(), isEmpty);
    });

    test('the About-you step writes its four fields and the next step', () {
      expect(
        ProfileUpdateModel(
          fullName: 'Dip Roy',
          username: 'dip',
          birthday: DateTime.utc(2001, 2, 3),
          gender: Gender.preferNotToSay,
          signupStep: SignupStep.profile,
        ).toJson(),
        {
          'full_name': 'Dip Roy',
          'username': 'dip',
          'birthday': '2001-02-03',
          'gender': 'prefer_not_to_say',
          'signup_step': 4,
        },
      );
    });

    test('the birthday is a date: no time, zero-padded', () {
      expect(
        ProfileUpdateModel(birthday: DateTime.utc(1999, 1, 9))
            .toJson()['birthday'],
        '1999-01-09',
      );
    });
  });

  group('InterestModel', () {
    final model = InterestModel.fromJson({
      'id': 2,
      'slug': 'photography',
      'name_en': 'Photography',
      'name_ar': 'تصوير',
      'sort_order': 2,
    });

    test('reads the row and round-trips', () {
      expect(model.slug, 'photography');
      expect(InterestModel.fromJson(model.toJson()), model);
    });

    test('nameFor picks the language, falling back to the other', () {
      expect(model.nameFor('ar'), 'تصوير');
      expect(model.nameFor('en'), 'Photography');
      expect(model.nameFor('fr'), 'Photography');
      expect(const InterestModel(nameEn: 'Food').nameFor('ar'), 'Food');
      expect(const InterestModel().nameFor('en'), isNull);
    });
  });
}
