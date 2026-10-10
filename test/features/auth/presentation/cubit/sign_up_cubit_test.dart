import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/enums/photo_source.dart';
import 'package:pulse/core/services/photo_picker_service.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/auth/presentation/utils/enums/follow_tab.dart';
import 'package:pulse/features/auth/presentation/utils/enums/load_status.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/suggestion_reason.dart';
import 'package:pulse/features/profile/data/enums/suggestion_tab.dart';
import 'package:pulse/features/profile/data/model/interest_model.dart';
import 'package:pulse/features/profile/data/model/suggested_profile_model.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_up_cubit.dart';

import '../../../../helpers/pump_app.dart' hide MockAuthDatasource;

class MockAuth extends Mock implements AuthDatasource {}

class MockGetSignupStep extends Mock implements GetSignupStepUseCase {}

void main() {
  late MockAuth auth;
  late MockSaveAboutYouUseCase saveAbout;
  late MockSaveProfileDetailsUseCase saveProfile;
  late MockPhotoPickerService photos;
  late MockGetInterestsUseCase getInterests;
  late MockSaveInterestsUseCase saveInterests;
  late MockGetSuggestedProfilesUseCase getPeople;
  late MockSetFollowingUseCase setFollowing;
  late MockCompleteSignupUseCase complete;
  late MockClearLocalProfileUseCase clearLocal;
  late MockGetSignupStep getSignupStep;
  late MockGetSignupDraftUseCase getDraft;

  const interest1 = InterestModel(id: 1, nameEn: 'Travel');
  const interest2 = InterestModel(id: 2, nameEn: 'Food');
  const ada = SuggestedProfileModel(
    id: 'u1',
    fullName: 'Ada Lovelace',
    reason: SuggestionReason.mutual,
    mutualCount: 3,
  );
  const bob = SuggestedProfileModel(id: 'u2', fullName: 'Bob Roy');

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(PhotoSource.camera);
    registerFallbackValue(<int>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(SuggestionTab.suggested);
  });

  setUp(() {
    auth = MockAuth();
    saveAbout = MockSaveAboutYouUseCase();
    saveProfile = MockSaveProfileDetailsUseCase();
    photos = MockPhotoPickerService();
    getInterests = MockGetInterestsUseCase();
    saveInterests = MockSaveInterestsUseCase();
    getPeople = MockGetSuggestedProfilesUseCase();
    setFollowing = MockSetFollowingUseCase();
    complete = MockCompleteSignupUseCase();
    clearLocal = MockClearLocalProfileUseCase();
    getSignupStep = MockGetSignupStep();
    getDraft = MockGetSignupDraftUseCase();
    when(() => getDraft()).thenAnswer((_) async => const ProfileEntity());
    when(() => getInterests())
        .thenAnswer((_) async => const [interest1, interest2]);
    when(() => saveInterests(any())).thenAnswer((_) async {});
    when(() => getPeople(SuggestionTab.suggested))
        .thenAnswer((_) async => const [ada, bob]);
    when(() => getPeople(SuggestionTab.popular))
        .thenAnswer((_) async => const [bob]);
    when(() => setFollowing(any(), following: any(named: 'following')))
        .thenAnswer((_) async {});
    when(() => setFollowing.all(any())).thenAnswer((_) async {});
    when(() => complete()).thenAnswer((_) async {});
    when(() => clearLocal()).thenAnswer((_) async {});
    when(() => auth.signOut(others: any(named: 'others')))
        .thenAnswer((_) async {});
  });

  SignUpCubit cubit() => SignUpCubit(
    auth,
    saveAbout,
    saveProfile,
    photos,
    getInterests,
    saveInterests,
    getPeople,
    setFollowing,
    complete,
    clearLocal,
    getSignupStep,
    getDraft,
  );

  void signUpReturns([Failure? failure]) =>
      when(
        () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        if (failure != null) throw failure;
      });

  void verifyReturns([Failure? failure]) =>
      when(
        () => auth.verifySignUpCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async {
        if (failure != null) throw failure;
      });

  void resendReturns([Failure? failure]) =>
      when(() => auth.resendSignUpCode(any())).thenAnswer((_) async {
        if (failure != null) throw failure;
      });

  const cooldown = Duration(seconds: 30);

  SignUpCubit filled() => cubit()
    ..emailChanged(' ada@example.com ')
    ..passwordChanged('password1')
    ..termsChanged(true);

  group('Account', () {
    test('Continue needs a valid email, 8+ characters and the terms', () {
      final c = cubit();
      expect(c.state.canSubmitAccount, isFalse);
      c.emailChanged('ada@example.com');
      c.passwordChanged('1234567');
      c.termsChanged(true);
      expect(c.state.canSubmitAccount, isFalse);
      c.passwordChanged('12345678');
      expect(c.state.canSubmitAccount, isTrue);
      c.termsChanged(false);
      expect(c.state.canSubmitAccount, isFalse);
      c.termsChanged(true);
      c.emailChanged('ada@');
      expect(c.state.canSubmitAccount, isFalse);
    });

    test('format errors show only after the field was left', () {
      final c = cubit()
        ..emailChanged('ada')
        ..passwordChanged('123');
      expect(c.state.emailInvalidShown, isFalse);
      expect(c.state.passwordShortShown, isFalse);
      c
        ..emailLeft()
        ..passwordLeft();
      expect(c.state.emailInvalidShown, isTrue);
      expect(c.state.passwordShortShown, isTrue);
      c
        ..emailChanged('ada@example.com')
        ..passwordChanged('12345678');
      expect(c.state.emailInvalidShown, isFalse);
      expect(c.state.passwordShortShown, isFalse);
    });

    test('an empty field shows no format error', () {
      final c = cubit()
        ..emailLeft()
        ..passwordLeft();
      expect(c.state.emailInvalidShown, isFalse);
      expect(c.state.passwordShortShown, isFalse);
    });

    test('submit does nothing while Continue is disabled', () async {
      await cubit().submitAccount();
      verifyNever(
        () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('a created account moves to Verify email with the cooldown', (
      tester,
    ) async {
      signUpReturns();
      final c = filled();
      await c.submitAccount();

      expect(c.state.step, SignUpCubit.verifyStep);
      expect(c.state.email, 'ada@example.com');
      expect(c.state.loading, isFalse);
      expect(c.state.resendIn, cooldown);
      verify(() => auth.signUp(email: 'ada@example.com', password: 'password1'))
          .called(1);
      await c.close();
    });

    test('a taken email stays on Account until the email is edited', () async {
      signUpReturns(const AuthFailure(AuthFailureReason.emailTaken));
      when(
        () => auth.signIn(
          identifier: any(named: 'identifier'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthFailure(AuthFailureReason.invalidCredentials));
      final c = filled();
      await c.submitAccount();

      expect(c.state.step, SignUpCubit.firstStep);
      expect(c.state.emailTaken, isTrue);
      expect(c.state.toastFailure, isNotNull);
      expect(c.state.loading, isFalse);

      c.passwordChanged('password12');
      expect(c.state.emailTaken, isTrue);
      c.emailChanged('ada2@example.com');
      expect(c.state.emailTaken, isFalse);
    });

    group('a taken email', () {
      void signInReturns([Failure? failure]) =>
          when(
            () => auth.signIn(
              identifier: any(named: 'identifier'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async {
            if (failure != null) throw failure;
          });

      test('with the same password resumes at the step still to do', () async {
        signUpReturns(const AuthFailure(AuthFailureReason.emailTaken));
        signInReturns();
        when(() => getSignupStep()).thenAnswer((_) async => SignupStep.profile);
        final c = filled();
        await c.submitAccount();

        expect(c.state.step, SignUpCubit.profileStep);
        expect(c.state.failure, isNull);
        expect(c.state.loading, isFalse);
        await c.close();
      });

      test('with a finished sign-up goes Home', () async {
        signUpReturns(const AuthFailure(AuthFailureReason.emailTaken));
        signInReturns();
        when(() => getSignupStep())
            .thenAnswer((_) async => SignupStep.complete);
        final c = filled();
        final routes = <String?>[];
        c.stream.listen((s) => routes.add(s.route));
        await c.submitAccount();
        await Future<void>.delayed(Duration.zero);

        expect(routes, contains(AppRoutes.home));
        await c.close();
      });

      test('with another password stays taken', () async {
        signUpReturns(const AuthFailure(AuthFailureReason.emailTaken));
        signInReturns(const AuthFailure(AuthFailureReason.invalidCredentials));
        final c = filled();
        await c.submitAccount();

        expect(c.state.step, SignUpCubit.firstStep);
        expect(c.state.emailTaken, isTrue);
        expect(c.state.loading, isFalse);
        await c.close();
      });
    });

    test('another failure is kept for a snackbar', () async {
      signUpReturns(const NetworkFailure());
      final c = filled();
      await c.submitAccount();

      expect(c.state.step, SignUpCubit.firstStep);
      expect(c.state.toastFailure, const NetworkFailure());
    });
  });

  group('Verify email', () {
    Future<SignUpCubit> atVerify() async {
      signUpReturns();
      final c = filled();
      await c.submitAccount();
      return c;
    }

    testWidgets('Verify needs all 6 digits', (tester) async {
      final c = await atVerify();
      c.codeChanged('12345');
      expect(c.state.canVerify, isFalse);
      c.codeChanged('123456');
      expect(c.state.canVerify, isTrue);
      await c.close();
    });

    testWidgets('a right code moves on to About you and stops the cooldown', (
      tester,
    ) async {
      verifyReturns();
      final c = await atVerify();
      c.codeChanged('123456');
      await c.verify();

      expect(c.state.step, SignUpCubit.aboutYouStep);
      expect(c.state.resendIn, isNull);
      verify(
        () => auth.verifySignUpCode(email: 'ada@example.com', code: '123456'),
      ).called(1);
      await c.close();
    });

    testWidgets('a wrong code shows under the boxes until it is edited', (
      tester,
    ) async {
      verifyReturns(const AuthFailure(AuthFailureReason.invalidCode));
      final c = await atVerify();
      c.codeChanged('000000');
      await c.verify();

      expect(c.state.step, SignUpCubit.verifyStep);
      expect(c.state.wrongCode, isTrue);
      expect(c.state.toastFailure, isNotNull);
      expect(c.state.loading, isFalse);

      c.codeChanged('00000');
      expect(c.state.wrongCode, isFalse);
      await c.close();
    });

    testWidgets(
      'Resend is refused during the cooldown, then sends and restarts it',
      (tester) async {
        resendReturns();
        final c = await atVerify();
        await c.resend();
        verifyNever(() => auth.resendSignUpCode(any()));

        await tester.pump(cooldown);
        expect(c.state.resendIn, isNull);
        expect(c.state.canResend, isTrue);

        c.codeChanged('123');
        await c.resend();
        verify(() => auth.resendSignUpCode('ada@example.com')).called(1);
        expect(c.state.resendIn, cooldown);
        expect(c.state.code, isEmpty);
        await c.close();
      },
    );

    testWidgets('the cooldown counts down once a second', (tester) async {
      final c = await atVerify();
      await tester.pump(const Duration(seconds: 1));
      expect(c.state.resendIn, const Duration(seconds: 29));
      await c.close();
    });

    testWidgets('a failed resend keeps the cooldown off and reports it', (
      tester,
    ) async {
      resendReturns(const NetworkFailure());
      final c = await atVerify();
      await tester.pump(cooldown);
      await c.resend();

      expect(c.state.resendIn, isNull);
      expect(c.state.toastFailure, const NetworkFailure());
      await c.close();
    });

    testWidgets('back returns to Account with email and password kept', (
      tester,
    ) async {
      final c = await atVerify();
      c.codeChanged('123');
      c.backToAccount();

      expect(c.state.step, SignUpCubit.firstStep);
      expect(c.state.email, 'ada@example.com');
      expect(c.state.password, 'password1');
      expect(c.state.code, isEmpty);
      expect(c.state.resendIn, isNull);
      await c.close();
    });
  });

  group('open', () {
    testWidgets('Verify email with an address starts the cooldown', (
      tester,
    ) async {
      final c = cubit()..open(step: 2, email: 'ada@example.com');
      expect(c.state.step, SignUpCubit.verifyStep);
      expect(c.state.email, 'ada@example.com');
      expect(c.state.resendIn, cooldown);
      await c.close();
    });

    test('Verify email without an address falls back to Account', () {
      expect((cubit()..open(step: 2)).state.step, SignUpCubit.firstStep);
    });

    test('a resumed step is kept, and out-of-range ones are clamped', () {
      expect((cubit()..open(step: 4)).state.step, 4);
      expect((cubit()..open(step: 9)).state.step, SignUpCubit.lastStep);
      expect((cubit()..open(step: 0)).state.step, SignUpCubit.firstStep);
    });
  });

  group('About you', () {
    final birthday = DateTime(1999, 5, 20);

    void saveAboutReturns([Failure? failure]) =>
        when(
          () => saveAbout(
            fullName: any(named: 'fullName'),
            username: any(named: 'username'),
            birthday: any(named: 'birthday'),
            gender: any(named: 'gender'),
          ),
        ).thenAnswer((_) async {
          if (failure != null) throw failure;
        });

    SignUpCubit atAbout() => cubit()
      ..open(step: SignUpCubit.aboutYouStep)
      ..fullNameChanged('Ada Lovelace')
      ..usernameChanged('ada_l')
      ..birthdayPicked(birthday);

    test('Continue needs a name, a valid username and a birthday', () {
      final c = cubit()..open(step: 3);
      expect(c.state.canSubmitAbout, isFalse);
      c.fullNameChanged('Ada');
      c.usernameChanged('ad');
      c.birthdayPicked(birthday);
      expect(c.state.canSubmitAbout, isFalse);
      c.usernameChanged('ada.l_1');
      expect(c.state.canSubmitAbout, isTrue);
      c.fullNameChanged('  ');
      expect(c.state.canSubmitAbout, isFalse);
    });

    test('a username with other characters or over 30 is invalid', () {
      final c = cubit()..usernameLeft();
      for (final bad in ['ada l', 'ada-l', 'ada@l', 'a' * 31]) {
        c.usernameChanged(bad);
        expect(c.state.usernameInvalidShown, isTrue, reason: bad);
      }
      c.usernameChanged('a' * 30);
      expect(c.state.usernameInvalidShown, isFalse);
    });

    test('under 18 is refused, exactly 18 today is allowed', () {
      withClock(Clock.fixed(DateTime(2026, 10, 8)), () {
        final c = atAbout();
        c.birthdayPicked(DateTime(2008, 10, 9));
        expect(c.state.underage, isTrue);
        expect(c.state.canSubmitAbout, isFalse);
        c.birthdayPicked(DateTime(2008, 10, 8));
        expect(c.state.underage, isFalse);
        expect(c.state.canSubmitAbout, isTrue);
      });
    });

    test('tapping the chosen gender again clears it', () {
      final c = cubit()..genderToggled(Gender.male);
      expect(c.state.gender, Gender.male);
      c.genderToggled(Gender.female);
      expect(c.state.gender, Gender.female);
      c.genderToggled(Gender.female);
      expect(c.state.gender, isNull);
    });

    test('a saved step moves on to Profile', () async {
      saveAboutReturns();
      final c = atAbout()..genderToggled(Gender.female);
      await c.submitAbout();

      expect(c.state.step, SignUpCubit.profileStep);
      expect(c.state.loading, isFalse);
      verify(
        () => saveAbout(
          fullName: 'Ada Lovelace',
          username: 'ada_l',
          birthday: birthday,
          gender: Gender.female,
        ),
      ).called(1);
    });

    test('a taken username stays on the step until it is edited', () async {
      saveAboutReturns(const ConflictFailure());
      final c = atAbout();
      await c.submitAbout();

      expect(c.state.step, SignUpCubit.aboutYouStep);
      expect(c.state.usernameTaken, isTrue);
      expect(c.state.toastFailure, isNotNull);

      c.fullNameChanged('Ada');
      expect(c.state.usernameTaken, isTrue);
      c.usernameChanged('ada_l2');
      expect(c.state.usernameTaken, isFalse);
    });

    test('another failure is kept for a snackbar', () async {
      saveAboutReturns(const NetworkFailure());
      final c = atAbout();
      await c.submitAbout();

      expect(c.state.step, SignUpCubit.aboutYouStep);
      expect(c.state.toastFailure, const NetworkFailure());
    });

    test('submit does nothing while Continue is disabled', () async {
      await (cubit()..open(step: 3)).submitAbout();
      verifyNever(
        () => saveAbout(
          fullName: any(named: 'fullName'),
          username: any(named: 'username'),
          birthday: any(named: 'birthday'),
          gender: any(named: 'gender'),
        ),
      );
    });
  });

  group('Profile', () {
    final picked = PickedPhoto(
      bytes: Uint8List.fromList([1, 2]),
      contentType: 'image/png',
    );

    void saveProfileReturns([Failure? failure]) =>
        when(
          () => saveProfile(
            photo: any(named: 'photo'),
            photoContentType: any(named: 'photoContentType'),
            bio: any(named: 'bio'),
            city: any(named: 'city'),
            phone: any(named: 'phone'),
            removeAvatar: any(named: 'removeAvatar'),
          ),
        ).thenAnswer((_) async {
          if (failure != null) throw failure;
        });

    SignUpCubit atProfile() => cubit()..open(step: SignUpCubit.profileStep);

    test('Continue is enabled with nothing filled in', () {
      expect(atProfile().state.canSubmitProfile, isTrue);
    });

    test('a resumed sign-up brings back what was entered before', () async {
      when(() => getDraft()).thenAnswer(
        (_) async => ProfileEntity(
          fullName: 'Ada Lovelace',
          username: 'ada',
          birthday: DateTime(1990, 5, 1),
          bio: 'Hi',
          city: 'Cairo',
          phone: '+966 512345678',
          avatarUrl: 'https://x/a.png',
        ),
      );
      final c = cubit()..open(step: SignUpCubit.profileStep);
      expect(c.state.resuming, isTrue);
      await Future<void>.delayed(Duration.zero);

      expect(c.state.resuming, isFalse);
      expect(c.state.fullName, 'Ada Lovelace');
      expect(c.state.username, 'ada');
      expect(c.state.birthday, DateTime(1990, 5, 1));
      expect(c.state.bio, 'Hi');
      expect(c.state.city, 'Cairo');
      expect(c.state.phone, '+966 512345678');
      expect(c.state.avatarUrl, 'https://x/a.png');
    });

    test('a phone needs 7 to 15 digits once given, shown after it is left', () {
      final c = atProfile()..phoneChanged('12345');
      expect(c.state.phoneInvalidShown, isFalse);
      c.phoneLeft();
      expect(c.state.phoneInvalidShown, isTrue);
      expect(c.state.canSubmitProfile, isFalse);
      c.phoneChanged('+20 100 123 4567');
      expect(c.state.phoneInvalidShown, isFalse);
      expect(c.state.canSubmitProfile, isTrue);
      c.phoneChanged('1' * 16);
      expect(c.state.canSubmitProfile, isFalse);
      c.phoneChanged('');
      expect(c.state.canSubmitProfile, isTrue);
    });

    test('a picked photo is kept and can be removed', () async {
      when(() => photos.pick(PhotoSource.gallery))
          .thenAnswer((_) async => picked);
      final c = atProfile();
      await c.pickPhoto(PhotoSource.gallery);
      expect(c.state.photo, picked);
      c.removePhoto();
      expect(c.state.photo, isNull);
    });

    test('removing a restored photo deletes it when Continue saves', () async {
      when(() => getDraft()).thenAnswer(
        (_) async => const ProfileEntity(avatarUrl: 'https://x/a.png'),
      );
      saveProfileReturns();
      final c = atProfile();
      await Future<void>.delayed(Duration.zero);
      expect(c.state.avatarUrl, 'https://x/a.png');
      c.removePhoto();
      expect(c.state.avatarUrl, isNull);
      expect(c.state.avatarRemoved, isTrue);
      await c.submitProfile();

      verify(
        () => saveProfile(
          photo: null,
          photoContentType: null,
          bio: '',
          city: '',
          phone: '',
          removeAvatar: true,
        ),
      ).called(1);
    });

    test('a cancelled pick keeps the current photo', () async {
      when(() => photos.pick(PhotoSource.camera)).thenAnswer((_) async => null);
      final c = atProfile();
      await c.pickPhoto(PhotoSource.camera);
      expect(c.state.photo, isNull);
    });

    test('Continue saves what was given and moves to Interests', () async {
      saveProfileReturns();
      when(() => photos.pick(any())).thenAnswer((_) async => picked);
      final c = atProfile()
        ..bioChanged('Hi')
        ..cityChanged('Cairo')
        ..phoneChanged('+20 100 123 4567');
      await c.pickPhoto(PhotoSource.gallery);
      await c.submitProfile();

      expect(c.state.step, SignUpCubit.interestsStep);
      verify(
        () => saveProfile(
          photo: picked.bytes,
          photoContentType: 'image/png',
          bio: 'Hi',
          city: 'Cairo',
          phone: '+20 100 123 4567',
          removeAvatar: false,
        ),
      ).called(1);
    });

    test('Skip saves nothing and moves on', () async {
      saveProfileReturns();
      final c = atProfile()..bioChanged('typed but skipped');
      await c.skipProfile();

      expect(c.state.step, SignUpCubit.interestsStep);
      verify(
        () => saveProfile(
          photo: null,
          photoContentType: null,
          bio: null,
          city: null,
          phone: null,
          removeAvatar: false,
        ),
      ).called(1);
    });

    test('a failed save stays on the step with the failure', () async {
      saveProfileReturns(const NetworkFailure());
      final c = atProfile();
      await c.submitProfile();

      expect(c.state.step, SignUpCubit.profileStep);
      expect(c.state.loading, isFalse);
      expect(c.state.toastFailure, const NetworkFailure());
    });

    test('back goes to About you, and from About you nowhere', () {
      final c = atProfile()..backOneStep();
      expect(c.state.step, SignUpCubit.aboutYouStep);
      c.backOneStep();
      expect(c.state.step, SignUpCubit.aboutYouStep);
    });
  });

  group('Interests', () {
    Future<SignUpCubit> atInterests() async {
      when(
        () => saveProfile(
          photo: any(named: 'photo'),
          photoContentType: any(named: 'photoContentType'),
          bio: any(named: 'bio'),
          city: any(named: 'city'),
          phone: any(named: 'phone'),
        ),
      ).thenAnswer((_) async {});
      final c = cubit()..open(step: SignUpCubit.profileStep);
      await c.skipProfile();
      return c;
    }

    test('leaving Profile loads the topics and opens the step', () async {
      final c = await atInterests();

      expect(c.state.step, SignUpCubit.interestsStep);
      expect(c.state.interestsStatus, LoadStatus.loaded);
      expect(c.state.interests, [interest1, interest2]);
      expect(c.state.loading, isFalse);
    });

    test('no topics: the step is passed over and Follow opens', () async {
      when(() => getInterests()).thenAnswer((_) async => const []);
      final c = await atInterests();

      verify(() => saveInterests(const [])).called(1);
      expect(c.state.step, SignUpCubit.followStep);
    });

    test(
      'a failed load opens the step with Retry, which loads again',
      () async {
        when(() => getInterests()).thenThrow(const NetworkFailure());
        final c = await atInterests();

        expect(c.state.step, SignUpCubit.interestsStep);
        expect(c.state.interestsStatus, LoadStatus.failed);

        when(() => getInterests()).thenAnswer((_) async => const [interest1]);
        await c.retryInterests();
        expect(c.state.interestsStatus, LoadStatus.loaded);
        expect(c.state.interests, [interest1]);
      },
    );

    test('tapping a topic selects it, tapping again clears it', () async {
      final c = await atInterests();
      c.interestToggled(2);
      expect(c.state.selectedInterests, {2});
      c.interestToggled(1);
      expect(c.state.selectedInterests, {1, 2});
      c.interestToggled(2);
      expect(c.state.selectedInterests, {1});
    });

    test('Continue saves the picked topics and opens Follow', () async {
      final c = await atInterests();
      c.interestToggled(2);
      await c.submitInterests();

      verify(() => saveInterests([2])).called(1);
      expect(c.state.step, SignUpCubit.followStep);
      expect(c.state.people[SuggestionTab.suggested], [ada, bob]);
      expect(c.state.people[SuggestionTab.popular], [bob]);
    });

    test('Skip saves nothing and opens Follow', () async {
      final c = await atInterests();
      c.interestToggled(2);
      await c.skipInterests();

      verify(() => saveInterests(const [])).called(1);
      expect(c.state.step, SignUpCubit.followStep);
    });

    test('a failed save stays on the step with the failure', () async {
      when(() => saveInterests(any())).thenThrow(const NetworkFailure());
      final c = await atInterests();
      await c.submitInterests();

      expect(c.state.step, SignUpCubit.interestsStep);
      expect(c.state.loading, isFalse);
      expect(c.state.toastFailure, const NetworkFailure());
    });

    test(
      'both lists empty: Follow is passed over and sign-up ends at Home',
      () async {
        when(() => getPeople(any())).thenAnswer((_) async => const []);
        final c = await atInterests();
        final routes = <String>[];
        c.stream.listen((s) {
          if (s.route != null) routes.add(s.route!);
        });
        await c.skipInterests();
        await Future<void>.delayed(Duration.zero);

        verify(() => complete()).called(1);
        expect(routes, [AppRoutes.home]);
        expect(c.state.route, isNull);
      },
    );

    test('back from Interests goes to Profile', () async {
      final c = await atInterests();
      c.backOneStep();
      expect(c.state.step, SignUpCubit.profileStep);
    });

    test('a resumed sign-up at Interests loads the topics', () async {
      final c = cubit()..open(step: SignUpCubit.interestsStep);
      await Future<void>.delayed(Duration.zero);

      expect(c.state.step, SignUpCubit.interestsStep);
      expect(c.state.interestsStatus, LoadStatus.loaded);
    });
  });

  group('Follow', () {
    Future<SignUpCubit> atFollow() async {
      final c = cubit()..open(step: SignUpCubit.followStep);
      await Future<void>.delayed(Duration.zero);
      return c;
    }

    test('a resumed sign-up at Follow loads both lists', () async {
      final c = await atFollow();

      expect(c.state.step, SignUpCubit.followStep);
      expect(c.state.visiblePeople, [ada, bob]);
      expect(c.state.followStatus, LoadStatus.loaded);
    });

    test('a tab that fails to load shows Retry and loads again', () async {
      when(() => getPeople(SuggestionTab.popular))
          .thenThrow(const NetworkFailure());
      final c = await atFollow();
      c.tabSelected(FollowTab.popular);
      expect(c.state.followStatus, LoadStatus.failed);

      when(() => getPeople(SuggestionTab.popular))
          .thenAnswer((_) async => const [bob]);
      await c.retryPeople();
      expect(c.state.followStatus, LoadStatus.loaded);
      expect(c.state.visiblePeople, [bob]);
    });

    test('From contacts lists nobody', () async {
      final c = await atFollow();
      c.tabSelected(FollowTab.contacts);
      expect(c.state.visiblePeople, isEmpty);
      expect(c.state.followStatus, LoadStatus.loaded);
    });

    test('Follow shows Following at once, tapping again unfollows', () async {
      final c = await atFollow();
      await c.followToggled('u1');
      expect(c.state.following, {'u1'});
      verify(() => setFollowing('u1', following: true)).called(1);

      await c.followToggled('u1');
      expect(c.state.following, isEmpty);
      verify(() => setFollowing('u1', following: false)).called(1);
    });

    test('a failed follow puts the button back and reports it', () async {
      when(() => setFollowing(any(), following: any(named: 'following')))
          .thenThrow(const NetworkFailure());
      final c = await atFollow();
      await c.followToggled('u1');

      expect(c.state.following, isEmpty);
      expect(c.state.toastFailure, const NetworkFailure());
    });

    test(
      'Follow all follows the visible people who are not followed yet',
      () async {
        final c = await atFollow();
        await c.followToggled('u1');
        await c.followAll();

        verify(() => setFollowing.all(['u2'])).called(1);
        expect(c.state.following, {'u1', 'u2'});
      },
    );

    test('a failed Follow all undoes only its own follows', () async {
      when(() => setFollowing.all(any())).thenThrow(const NetworkFailure());
      final c = await atFollow();
      await c.followToggled('u1');
      await c.followAll();

      expect(c.state.following, {'u1'});
      expect(c.state.toastFailure, const NetworkFailure());
    });

    test('Continue and Skip finish sign-up and go Home', () async {
      final c = await atFollow();
      final routes = <String>[];
      c.stream.listen((s) {
        if (s.route != null) routes.add(s.route!);
      });
      await c.finishFollow();
      await Future<void>.delayed(Duration.zero);

      verify(() => complete()).called(1);
      expect(routes, [AppRoutes.home]);
    });

    test('a failed finish stays on Follow with the failure', () async {
      when(() => complete()).thenThrow(const NetworkFailure());
      final c = await atFollow();
      await c.finishFollow();

      expect(c.state.step, SignUpCubit.followStep);
      expect(c.state.loading, isFalse);
      expect(c.state.toastFailure, const NetworkFailure());
    });

    test(
      'back from Follow goes to Interests, or over it when it has no topics',
      () async {
        final c = await atFollow();
        c.backOneStep();
        await Future<void>.delayed(Duration.zero);
        expect(c.state.step, SignUpCubit.interestsStep);

        when(() => getInterests()).thenAnswer((_) async => const []);
        final empty = await atFollow();
        empty.backOneStep();
        await Future<void>.delayed(Duration.zero);
        expect(empty.state.step, SignUpCubit.profileStep);
      },
    );
  });

  group('Leave', () {
    test('forgets the local profile, signs out and goes to Sign in', () async {
      final c = cubit()..open(step: SignUpCubit.aboutYouStep);
      final routes = <String>[];
      c.stream.listen((s) {
        if (s.route != null) routes.add(s.route!);
      });
      await c.leave();
      await Future<void>.delayed(Duration.zero);

      verifyInOrder([() => clearLocal(), () => auth.signOut()]);
      expect(routes, [AppRoutes.signIn]);
    });

    test('goes to Sign in even when signing out fails', () async {
      when(() => auth.signOut(others: any(named: 'others')))
          .thenThrow(const NetworkFailure());
      final c = cubit();
      final routes = <String>[];
      c.stream.listen((s) {
        if (s.route != null) routes.add(s.route!);
      });
      await c.leave();
      await Future<void>.delayed(Duration.zero);

      expect(routes, [AppRoutes.signIn]);
    });
  });
}
