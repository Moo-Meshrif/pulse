import 'package:pulse/core/utils/country_names_delegate.dart';

import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/photo_source.dart';
import 'package:pulse/core/services/photo_picker_service.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/auth/presentation/widgets/follow_row.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/data/enums/suggestion_reason.dart';
import 'package:pulse/features/follow/data/enums/suggestion_tab.dart';
import 'package:pulse/features/profile/data/model/interest_model.dart';
import 'package:pulse/features/follow/data/model/suggested_profile_model.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_up_cubit.dart';
import 'package:pulse/features/auth/presentation/screen/sign_up_screen.dart';
import 'package:pulse/features/auth/presentation/widgets/labeled_checkbox.dart';
import 'package:pulse/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:pulse/features/auth/presentation/widgets/terms_agreement_label.dart';
import 'package:pulse/features/auth/presentation/widgets/step_top_bar.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../../../helpers/pump_app.dart';

class MockGetSignupStepUseCase extends Mock implements GetSignupStepUseCase {}

/// The code boxes blink a cursor for ever, so a Verify email screen never "settles".
Future<void> flush(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 400));

/// The sign-up flow (Account, Verify email) with the real cubit over a mocked datasource, in an app whose
/// other routes show their own name.
/// A 1x1 transparent PNG, so `Image.memory` can decode it.
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0xf8, 0xff, 0xff, 0x3f,
  0x00, 0x05, 0xfe, 0x02, 0xfe, 0xa7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);

void main() {
  late MockAuthDatasource auth;
  late MockSaveAboutYouUseCase saveAbout;
  late MockSaveProfileDetailsUseCase saveProfile;
  late MockPhotoPickerService photos;
  late MockGetInterestsUseCase getInterests;
  late MockSaveInterestsUseCase saveInterests;
  late MockGetSuggestedProfilesUseCase getPeople;
  late MockToggleFollowUseCase toggleFollow;
  late MockFollowAllUseCase followAll;
  late MockCompleteSignupUseCase complete;
  late MockClearLocalProfileUseCase clearLocal;
  late MockGetSignupDraftUseCase getDraft;

  const travel = InterestModel(id: 1, nameEn: 'Travel', nameAr: 'سفر');
  const food = InterestModel(id: 2, nameEn: 'Food', nameAr: 'طعام');
  const ada = SuggestedProfileModel(
    id: 'u1',
    fullName: 'Ada Lovelace',
    reason: SuggestionReason.mutual,
    mutualCount: 12,
  );
  const bob = SuggestedProfileModel(
    id: 'u2',
    fullName: 'Bob Roy',
    reason: SuggestionReason.city,
    city: 'Kolkata',
  );
  const nobody = SuggestedProfileModel(id: 'u3', fullName: 'Cy');

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(PhotoSource.camera);
    registerFallbackValue(<int>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(SuggestionTab.suggested);
  });

  setUp(() async {
    auth = MockAuthDatasource();
    saveAbout = MockSaveAboutYouUseCase();
    saveProfile = MockSaveProfileDetailsUseCase();
    photos = MockPhotoPickerService();
    getInterests = MockGetInterestsUseCase();
    saveInterests = MockSaveInterestsUseCase();
    getPeople = MockGetSuggestedProfilesUseCase();
    toggleFollow = MockToggleFollowUseCase();
    followAll = MockFollowAllUseCase();
    complete = MockCompleteSignupUseCase();
    clearLocal = MockClearLocalProfileUseCase();
    getDraft = MockGetSignupDraftUseCase();
    when(() => getDraft()).thenAnswer((_) async => const ProfileEntity());
    when(() => getInterests()).thenAnswer((_) async => const [travel, food]);
    when(() => saveInterests(any())).thenAnswer((_) async {});
    when(() => getPeople(SuggestionTab.suggested))
        .thenAnswer((_) async => const [ada, bob, nobody]);
    when(() => getPeople(SuggestionTab.popular))
        .thenAnswer((_) async => const [bob]);
    when(() => toggleFollow(any(), follow: any(named: 'follow'))).thenAnswer(
      (invocation) async => invocation.namedArguments[#follow] == true
          ? FollowStatus.accepted
          : FollowStatus.none,
    );
    when(() => followAll(any())).thenAnswer((_) async => 0);
    when(() => complete()).thenAnswer((_) async {});
    when(() => clearLocal()).thenAnswer((_) async {});
    when(() => auth.signOut(others: any(named: 'others')))
        .thenAnswer((_) async {});
    when(
      () => saveAbout(
        fullName: any(named: 'fullName'),
        username: any(named: 'username'),
        birthday: any(named: 'birthday'),
        gender: any(named: 'gender'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => saveProfile(
        photo: any(named: 'photo'),
        photoContentType: any(named: 'photoContentType'),
        bio: any(named: 'bio'),
        city: any(named: 'city'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer((_) async {});
    when(() => photos.pick(any())).thenAnswer(
      (_) async => PickedPhoto(bytes: _png, contentType: 'image/png'),
    );
    when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => auth.verifySignUpCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenAnswer((_) async {});
    when(() => auth.resendSignUpCode(any())).thenAnswer((_) async {});
    await getIt.reset();
    getIt.registerFactory<SignUpCubit>(
      () => SignUpCubit(
        auth,
        saveAbout,
        saveProfile,
        photos,
        getInterests,
        saveInterests,
        getPeople,
        toggleFollow,
        followAll,
        complete,
        clearLocal,
        MockGetSignupStepUseCase(),
        getDraft,
      ),
    );
    addTearDown(getIt.reset);
  });

  Future<void> open(
    WidgetTester tester, {
    Locale? locale,
    int step = 1,
    String? email,
  }) async {
    await tester.pumpWidget(
      AppScaleScope(
        builder: (context) => MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            CountryNamesDelegate(),
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignUpScreen(step: step, email: email),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Text('route: ${settings.name}'),
          ),
        ),
      ),
    );
    step >= 2 ? await flush(tester) : await tester.pumpAndSettle();
  }

  Finder field(int index) => find
      .descendant(
        of: find.byType(AppTextField),
        matching: find.byType(TextField),
      )
      .at(index);

  PrimaryButton button(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byType(PrimaryButton));

  Future<void> fillAccount(WidgetTester tester) async {
    await tester.enterText(field(0), 'ada@example.com');
    await tester.enterText(field(1), 'Password1!');
    await tester.tap(find.byType(LabeledCheckbox));
    await tester.pump();
  }

  Future<void> toVerify(WidgetTester tester) async {
    await fillAccount(tester);
    await tester.tap(find.text(l10nEn.continueButton));
    await flush(tester);
  }

  group('Account', () {
    testView('shows the S3 content with Continue disabled', (tester) async {
      await open(tester);

      expect(find.text(l10nEn.signUpTitle), findsOneWidget);
      expect(find.text(l10nEn.signUpSubtitle), findsOneWidget);
      expect(find.text(l10nEn.stepOf(1)), findsOneWidget);
      expect(find.text(l10nEn.required), findsWidgets);
      expect(
        find.textContaining(l10nEn.emailLabel, findRichText: true),
        findsOneWidget,
      );
      expect(find.text(l10nEn.orSignUpWith), findsOneWidget);
      expect(
        find.textContaining(l10nEn.alreadyOnPulse, findRichText: true),
        findsOneWidget,
      );
      expect(button(tester).onPressed, isNull);
      expect(find.byType(PasswordStrengthMeter), findsNothing);
    });

    testView('the strength meter appears once the password has text', (
      tester,
    ) async {
      await open(tester);
      await tester.enterText(field(1), 'abc');
      await tester.pump();

      expect(find.byType(PasswordStrengthMeter), findsOneWidget);
    });

    testView('Continue enables with a valid email, password and the terms', (
      tester,
    ) async {
      await open(tester);
      await fillAccount(tester);

      expect(button(tester).onPressed, isNotNull);
    });

    testView('a short password shows its error after the field is left', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(field(1));
      await tester.enterText(field(1), 'abc');
      await tester.tap(field(0));
      await tester.pump();

      expect(find.text(l10nEn.errorPasswordShort), findsOneWidget);
    });

    testView('a taken email is flagged under the field', (tester) async {
      when(
        () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthFailure(AuthFailureReason.emailTaken));
      when(
        () => auth.signIn(
          identifier: any(named: 'identifier'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthFailure(AuthFailureReason.invalidCredentials));
      await open(tester);
      await fillAccount(tester);
      await tester.tap(find.text(l10nEn.continueButton));
      await tester.pumpAndSettle();

      expect(
        find.text(l10nEn.errorEmailExists),
        findsOneWidget,
      ); // snackbar only
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(l10nEn.signUpTitle), findsOneWidget);
    });

    testView('the Terms and Privacy Policy links open their pages', (
      tester,
    ) async {
      await open(tester);

      void tapLink(String text) {
        final rich = tester.widget<RichText>(
          find.descendant(
            of: find.byType(TermsAgreementLabel),
            matching: find.byType(RichText),
          ),
        );
        late TextSpan link;
        rich.text.visitChildren((span) {
          if (span is TextSpan && span.text == text) link = span;
          return true;
        });
        (link.recognizer! as TapGestureRecognizer).onTap!();
      }

      tapLink(l10nEn.terms);
      await tester.pumpAndSettle();
      expect(find.text('route: /terms'), findsOneWidget);
    });

    testView('"Sign in" opens Sign in', (tester) async {
      await open(tester);
      await tester.tap(find.textContaining(l10nEn.signIn, findRichText: true));
      await tester.pumpAndSettle();

      expect(find.text('route: /sign-in'), findsOneWidget);
    });

    testView('the social buttons say "Coming soon"', (tester) async {
      await open(tester);
      await tester.tap(find.text(l10nEn.google));
      await tester.pump();

      expect(find.text(l10nEn.comingSoon), findsOneWidget);
    });
  });

  group('Verify email', () {
    testView('Continue moves to Verify email with the masked address', (
      tester,
    ) async {
      await open(tester);
      await toVerify(tester);

      expect(find.text(l10nEn.verifyTitle), findsOneWidget);
      expect(find.text(l10nEn.stepOf(2)), findsOneWidget);
      expect(
        find.textContaining('ada•••@example.com', findRichText: true),
        findsOneWidget,
      );
      expect(button(tester).onPressed, isNull);
      expect(find.text(l10nEn.resendCodeIn('0:30')), findsOneWidget);
    });

    testView('Verify enables with 6 digits and moves on to step 3', (
      tester,
    ) async {
      await open(tester);
      await toVerify(tester);
      await tester.enterText(find.byType(EditableText), '12345');
      await tester.pump();
      expect(button(tester).onPressed, isNull);

      await tester.enterText(find.byType(EditableText), '123456');
      await tester.pump();
      expect(button(tester).onPressed, isNotNull);

      await tester.tap(find.text(l10nEn.verify));
      await flush(tester);
      expect(find.text(l10nEn.stepOf(3)), findsWidgets);
    });

    testView('a wrong code shows its message', (tester) async {
      when(
        () => auth.verifySignUpCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenThrow(const AuthFailure(AuthFailureReason.invalidCode));
      await open(tester);
      await toVerify(tester);
      await tester.enterText(find.byType(EditableText), '000000');
      await tester.pump();
      await tester.tap(find.text(l10nEn.verify));
      await flush(tester);

      expect(find.text(l10nEn.errorWrongCode), findsOneWidget); // snackbar only
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testView('"Resend code" works after the cooldown', (tester) async {
      await open(tester);
      await toVerify(tester);
      await tester.pump(const Duration(seconds: 30));

      expect(find.text(l10nEn.resendCode), findsOneWidget);
      await tester.tap(find.text(l10nEn.resendCode));
      await tester.pump();

      verify(() => auth.resendSignUpCode('ada@example.com')).called(1);
      expect(find.text(l10nEn.resendCodeIn('0:30')), findsOneWidget);
    });

    testView('"Use a different email" returns to Account with the email kept', (
      tester,
    ) async {
      await open(tester);
      await toVerify(tester);
      await tester.tap(find.text(l10nEn.useDifferentEmail));
      await flush(tester);

      expect(find.text(l10nEn.signUpTitle), findsOneWidget);
      expect(
        tester.widget<TextField>(field(0)).controller!.text,
        'ada@example.com',
      );
    });

    testView('the system back button returns to Account too', (tester) async {
      await open(tester);
      await toVerify(tester);
      await tester.binding.handlePopRoute();
      await flush(tester);

      expect(find.text(l10nEn.signUpTitle), findsOneWidget);
    });

    testView('opened for an unverified account it starts on Verify email', (
      tester,
    ) async {
      await open(tester, step: 2, email: 'ada@example.com');

      expect(find.text(l10nEn.verifyTitle), findsOneWidget);
      expect(find.text(l10nEn.resendCodeIn('0:30')), findsOneWidget);
    });
  });

  testView('the step bar moves with the step', (tester) async {
    await open(tester);
    expect(tester.widget<StepTopBar>(find.byType(StepTopBar)).step, 1);
    await toVerify(tester);
    expect(tester.widget<StepTopBar>(find.byType(StepTopBar)).step, 2);
  });

  testView('Arabic: texts come from the Arabic file and the layout mirrors', (
    tester,
  ) async {
    await open(tester, locale: const Locale('ar'));

    expect(find.text(l10nAr.signUpTitle), findsOneWidget);
    expect(find.text(l10nAr.continueButton), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(StepTopBar))),
      TextDirection.rtl,
    );
    final emailField = tester.widget<TextField>(field(0));
    expect(emailField.textDirection, TextDirection.ltr);
  });

  testView('Arabic: Verify email keeps the code boxes left-to-right', (
    tester,
  ) async {
    await open(
      tester,
      locale: const Locale('ar'),
      step: 2,
      email: 'ada@example.com',
    );

    expect(find.text(l10nAr.verifyTitle), findsOneWidget);
    final pinput = find.byType(EditableText);
    expect(Directionality.of(tester.element(pinput)), TextDirection.ltr);
  });

  testWidgets('at 320 dp and 1.5x text nothing overflows', (tester) async {
    setUpView(tester, size: const Size(320, 640), textScale: 1.5);
    await open(tester);
    expect(tester.takeException(), isNull);
    await tester.enterText(field(0), 'ada@example.com');
    await tester.enterText(field(1), 'Password1!');
    await tester.pump();
    expect(tester.takeException(), isNull);

    await open(tester, step: 2, email: 'ada@example.com');
    expect(tester.takeException(), isNull);
  });

  group('About you', () {
    Future<void> pickBirthday(WidgetTester tester) async {
      await tester.tap(field(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    Future<void> fillAbout(WidgetTester tester) async {
      await tester.enterText(field(0), 'Ada Lovelace');
      await tester.enterText(field(1), 'Ada_L');
      await pickBirthday(tester);
    }

    testView('shows the S5 content with Continue disabled', (tester) async {
      await open(tester, step: 3);

      expect(find.text(l10nEn.aboutTitle), findsOneWidget);
      expect(find.text(l10nEn.stepOf(3)), findsOneWidget);
      expect(find.text(l10nEn.usernameHelper), findsOneWidget);
      expect(find.text(l10nEn.birthdayHelper), findsOneWidget);
      expect(find.text(l10nEn.genderFemale), findsOneWidget);
      expect(find.text(l10nEn.genderMale), findsOneWidget);
      expect(find.text(l10nEn.genderPreferNot), findsOneWidget);
      expect(button(tester).onPressed, isNull);
    });

    testView('the date picker fills the birthday as DD / MM / YYYY', (
      tester,
    ) async {
      await open(tester, step: 3);
      await pickBirthday(tester);

      final text = tester.widget<TextField>(field(2)).controller!.text;
      expect(text, matches(RegExp(r'^\d{2} / \d{2} / \d{4}$')));
    });

    testView('Continue enables once name, username and birthday are set', (
      tester,
    ) async {
      await open(tester, step: 3);
      await fillAbout(tester);

      expect(button(tester).onPressed, isNotNull);
    });

    testView('a bad username turns its helper into the error after leaving', (
      tester,
    ) async {
      await open(tester, step: 3);
      await tester.tap(field(1));
      await tester.enterText(field(1), 'a b');
      await tester.tap(field(0));
      await tester.pump();

      expect(find.text(l10nEn.usernameHelper), findsOneWidget);
      final helper = tester.widget<AppText>(
        find.widgetWithText(AppText, l10nEn.usernameHelper),
      );
      expect(helper.color, AppTheme.light.extension<AppColors>()!.danger);
    });

    testView('Continue saves the lowercase fields and opens Profile', (
      tester,
    ) async {
      await open(tester, step: 3);
      await fillAbout(tester);
      await tester.tap(find.text(l10nEn.genderFemale));
      await tester.pump();
      await tester.tap(find.text(l10nEn.continueButton));
      await tester.pumpAndSettle();

      verify(
        () => saveAbout(
          fullName: 'Ada Lovelace',
          username: 'Ada_L',
          birthday: any(named: 'birthday'),
          gender: Gender.female,
        ),
      ).called(1);
      expect(find.text(l10nEn.profileTitle), findsOneWidget);
      expect(find.text(l10nEn.stepOf(4)), findsOneWidget);
    });

    testView('a taken username is flagged under the field', (tester) async {
      when(
        () => saveAbout(
          fullName: any(named: 'fullName'),
          username: any(named: 'username'),
          birthday: any(named: 'birthday'),
          gender: any(named: 'gender'),
        ),
      ).thenThrow(const ConflictFailure());
      await open(tester, step: 3);
      await fillAbout(tester);
      await tester.tap(find.text(l10nEn.continueButton));
      await tester.pumpAndSettle();

      expect(
        find.text(l10nEn.errorUsernameTaken),
        findsOneWidget,
      ); // snackbar only
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(l10nEn.aboutTitle), findsOneWidget);
    });
  });

  group('Profile', () {
    testView('shows the S6 content with Optional, Skip and Continue enabled', (
      tester,
    ) async {
      await open(tester, step: 4);

      expect(find.text(l10nEn.profileTitle), findsOneWidget);
      expect(find.text(l10nEn.optional), findsOneWidget);
      expect(find.text(l10nEn.skip), findsOneWidget);
      expect(find.text(l10nEn.addPhoto), findsWidgets);
      expect(find.text('0/150'), findsOneWidget);
      expect(find.text(l10nEn.phoneHelper), findsOneWidget);
      expect(button(tester).onPressed, isNotNull);
    });

    testView('the bio counter follows the text and stops at 150', (
      tester,
    ) async {
      await open(tester, step: 4);
      await tester.enterText(field(0), 'a' * 200);
      await tester.pump();

      expect(find.text('150/150'), findsOneWidget);
    });

    testView('the phone field keeps digits and spaces only', (tester) async {
      await open(tester, step: 4);
      await tester.enterText(field(2), '20 abc +100');
      await tester.pump();

      expect(tester.widget<TextField>(field(2)).controller!.text, '20  100');
    });

    testView('the phone country code can be changed', (tester) async {
      await open(tester, step: 4);
      await tester.ensureVisible(field(2));
      await tester.tap(find.text('+20'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Saudi');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saudi Arabia'));
      await tester.pumpAndSettle();

      expect(find.text('+966'), findsOneWidget);
      expect(find.text('+20'), findsNothing);
    });

    testView('the country list holds every country, searchable by name', (
      tester,
    ) async {
      await open(tester, step: 4);
      await tester.ensureVisible(field(2));
      await tester.tap(find.text('+20'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Iceland');
      await tester.pumpAndSettle();

      expect(find.text('+354'), findsOneWidget);
    });

    testView('the country list is searchable in Arabic', (tester) async {
      await open(tester, step: 4, locale: const Locale('ar'));
      await tester.ensureVisible(field(2));
      await tester.tap(find.text('+20'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'آيسلندا');
      await tester.pumpAndSettle();

      expect(find.text('+354'), findsOneWidget);
    });

    testView('a short phone shows its error after the field is left', (
      tester,
    ) async {
      await open(tester, step: 4);
      await tester.ensureVisible(field(2));
      await tester.pump();
      await tester.tap(field(2));
      await tester.enterText(field(2), '123');
      await tester.tap(field(1));
      await tester.pump();

      expect(find.text(l10nEn.errorPhone), findsOneWidget);
      expect(button(tester).onPressed, isNull);
    });

    testView('the photo sheet offers two choices, then Remove once set', (
      tester,
    ) async {
      await open(tester, step: 4);
      await tester.tap(find.byType(PhotoPickerAvatar));
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.takePhoto), findsOneWidget);
      expect(find.text(l10nEn.chooseGallery), findsOneWidget);
      expect(find.text(l10nEn.removePhoto), findsNothing);

      await tester.tap(find.text(l10nEn.chooseGallery));
      await tester.pumpAndSettle();
      verify(() => photos.pick(PhotoSource.gallery)).called(1);
      expect(find.byType(Image), findsOneWidget);

      await tester.tap(find.byType(PhotoPickerAvatar));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.removePhoto), findsOneWidget);
      await tester.tap(find.text(l10nEn.removePhoto));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
    });

    testView('Continue saves and opens step 5', (tester) async {
      await open(tester, step: 4);
      await tester.enterText(field(1), 'Cairo');
      await tester.pump();
      await tester.tap(find.text(l10nEn.continueButton));
      await tester.pumpAndSettle();

      verify(
        () => saveProfile(
          photo: null,
          photoContentType: null,
          bio: '',
          city: 'Cairo',
          phone: '',
        ),
      ).called(1);
      expect(find.text(l10nEn.stepOf(5)), findsWidgets);
    });

    testView('Skip saves nothing and opens step 5', (tester) async {
      await open(tester, step: 4);
      await tester.tap(find.text(l10nEn.skip));
      await tester.pumpAndSettle();

      verify(
        () => saveProfile(
          photo: null,
          photoContentType: null,
          bio: null,
          city: null,
          phone: null,
        ),
      ).called(1);
      expect(find.text(l10nEn.stepOf(5)), findsWidgets);
    });

    testView('the back arrow returns to About you', (tester) async {
      await open(tester, step: 4);
      await tester.tap(find.bySemanticsLabel(l10nEn.back));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.aboutTitle), findsOneWidget);
    });

    testView('Arabic: the phone stays left-to-right and texts are Arabic', (
      tester,
    ) async {
      await open(tester, locale: const Locale('ar'), step: 4);

      expect(find.text(l10nAr.profileTitle), findsOneWidget);
      expect(find.text(l10nAr.skip), findsOneWidget);
      expect(
        tester.widget<TextField>(field(2)).textDirection,
        TextDirection.ltr,
      );
    });

    testView('Arabic: About you keeps the username left-to-right', (
      tester,
    ) async {
      await open(tester, locale: const Locale('ar'), step: 3);

      expect(find.text(l10nAr.aboutTitle), findsOneWidget);
      expect(
        tester.widget<TextField>(field(1)).textDirection,
        TextDirection.ltr,
      );
    });
  });

  testWidgets('steps 3 and 4 at 320 dp and 1.5x text do not overflow', (
    tester,
  ) async {
    setUpView(tester, size: const Size(320, 640), textScale: 1.5);
    await open(tester, step: 3);
    expect(tester.takeException(), isNull);
    await open(tester, step: 4);
    expect(tester.takeException(), isNull);
  });

  group('Interests', () {
    testView('shows the topics with Continue and no count at first', (
      tester,
    ) async {
      await open(tester, step: 5);

      expect(find.text(l10nEn.interestsTitle), findsOneWidget);
      expect(find.text(l10nEn.stepOf(5)), findsOneWidget);
      expect(find.text(l10nEn.optional), findsOneWidget);
      expect(find.text(l10nEn.skip), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.textContaining('selected'), findsNothing);
      expect(button(tester).onPressed, isNotNull);
    });

    testView('the count follows the picked topics and hides at 0', (
      tester,
    ) async {
      await open(tester, step: 5);
      await tester.tap(find.text('Travel'));
      await tester.pump();
      expect(find.text(l10nEn.selectedCount(1)), findsOneWidget);
      await tester.tap(find.text('Food'));
      await tester.pump();
      expect(find.text(l10nEn.selectedCount(2)), findsOneWidget);
      await tester.tap(find.text('Travel'));
      await tester.tap(find.text('Food'));
      await tester.pump();
      expect(find.textContaining('selected'), findsNothing);
    });

    testView('Continue saves the picked ids and opens Follow', (tester) async {
      await open(tester, step: 5);
      await tester.tap(find.text('Food'));
      await tester.pump();
      await tester.tap(find.text(l10nEn.continueButton));
      await tester.pumpAndSettle();

      verify(() => saveInterests([2])).called(1);
      expect(find.text(l10nEn.followTitle), findsOneWidget);
    });

    testView('Skip saves nothing and opens Follow', (tester) async {
      await open(tester, step: 5);
      await tester.tap(find.text(l10nEn.skip));
      await tester.pumpAndSettle();

      verify(() => saveInterests(const [])).called(1);
      expect(find.text(l10nEn.followTitle), findsOneWidget);
    });

    testView('a failed load shows the message and Retry loads again', (
      tester,
    ) async {
      when(() => getInterests()).thenThrow(const NetworkFailure());
      await open(tester, step: 5);

      expect(find.text(l10nEn.interestsError), findsOneWidget);
      when(() => getInterests()).thenAnswer((_) async => const [travel]);
      await tester.tap(find.text(l10nEn.retry));
      await tester.pumpAndSettle();

      expect(find.text('Travel'), findsOneWidget);
      expect(find.text(l10nEn.interestsError), findsNothing);
    });

    testView('Arabic: topic names come from the Arabic column', (tester) async {
      await open(tester, locale: const Locale('ar'), step: 5);

      expect(find.text('سفر'), findsOneWidget);
      expect(find.text(l10nAr.interestsTitle), findsOneWidget);
    });

    testView('Follow\'s back arrow returns to the topics', (tester) async {
      await open(tester, step: 6);
      await tester.tap(find.bySemanticsLabel(l10nEn.back));
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.interestsTitle), findsOneWidget);
    });
  });

  group('Follow', () {
    /// The test font is wide, so the tab row scrolls: bring the tab into view first.
    Future<void> selectTab(WidgetTester tester, String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.pump();
      await tester.tap(find.text(label));
      await tester.pump();
    }

    testView('shows the tabs, the heading and the people', (tester) async {
      await open(tester, step: 6);

      expect(find.text(l10nEn.followTitle), findsOneWidget);
      expect(find.text(l10nEn.stepOf(6)), findsOneWidget);
      expect(find.text(l10nEn.tabSuggested), findsOneWidget);
      expect(find.text(l10nEn.tabContacts), findsOneWidget);
      expect(find.text(l10nEn.tabPopular), findsOneWidget);
      expect(find.text(l10nEn.suggestedForYou), findsOneWidget);
      expect(find.text(l10nEn.followAll), findsOneWidget);
      expect(find.text(l10nEn.followHint), findsOneWidget);
      expect(find.byType(FollowRow), findsNWidgets(3));
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text(l10nEn.mutualFriends(12)), findsOneWidget);
      expect(find.text(l10nEn.livesIn('Kolkata')), findsOneWidget);
      expect(find.text('AL'), findsOneWidget);
    });

    testView('a person with no known reason shows no meta line', (
      tester,
    ) async {
      await open(tester, step: 6);
      final row = find.widgetWithText(FollowRow, 'Cy');
      expect(
        find.descendant(of: row, matching: find.textContaining('mutual')),
        findsNothing,
      );
    });

    testView('Follow turns into Following and back', (tester) async {
      await open(tester, step: 6);
      final first = find.descendant(
        of: find.widgetWithText(FollowRow, 'Ada Lovelace'),
        matching: find.text(l10nEn.follow),
      );
      await tester.tap(first);
      await tester.pump();

      expect(find.text(l10nEn.following), findsOneWidget);
      verify(() => toggleFollow('u1', follow: true)).called(1);

      await tester.tap(find.text(l10nEn.following));
      await tester.pump();
      expect(find.text(l10nEn.following), findsNothing);
      verify(() => toggleFollow('u1', follow: false)).called(1);
    });

    testView('Follow all follows everybody listed', (tester) async {
      await open(tester, step: 6);
      await tester.tap(find.text(l10nEn.followAll));
      await tester.pump();

      expect(find.text(l10nEn.following), findsNWidgets(3));
      verify(() => followAll(['u1', 'u2', 'u3'])).called(1);
    });

    testView('Popular shows its list; From contacts says "Coming soon"', (
      tester,
    ) async {
      await open(tester, step: 6);
      await selectTab(tester, l10nEn.tabPopular);
      expect(find.byType(FollowRow), findsOneWidget);

      await selectTab(tester, l10nEn.tabContacts);
      expect(find.byType(FollowRow), findsNothing);
      expect(find.text(l10nEn.comingSoon), findsOneWidget);
      expect(find.text(l10nEn.followAll), findsNothing);
    });

    testView('an empty tab shows a message only; Continue stays enabled', (
      tester,
    ) async {
      when(() => getPeople(SuggestionTab.popular))
          .thenAnswer((_) async => const []);
      await open(tester, step: 6);
      await selectTab(tester, l10nEn.tabPopular);

      expect(find.text(l10nEn.noSuggestions), findsOneWidget);
      expect(button(tester).onPressed, isNotNull);
    });

    testView('a tab that failed shows Retry', (tester) async {
      when(() => getPeople(SuggestionTab.popular))
          .thenThrow(const NetworkFailure());
      await open(tester, step: 6);
      await selectTab(tester, l10nEn.tabPopular);

      expect(find.text(l10nEn.followError), findsOneWidget);
      when(() => getPeople(SuggestionTab.popular))
          .thenAnswer((_) async => const [bob]);
      await tester.tap(find.text(l10nEn.retry));
      await tester.pumpAndSettle();
      expect(find.byType(FollowRow), findsOneWidget);
    });

    testView('Continue finishes sign-up and goes Home', (tester) async {
      await open(tester, step: 6);
      await tester.tap(find.text(l10nEn.continueButton));
      await tester.pumpAndSettle();

      verify(() => complete()).called(1);
      expect(find.text('route: ${AppRoutes.home}'), findsOneWidget);
    });

    testView('Skip finishes sign-up and goes Home', (tester) async {
      await open(tester, step: 6);
      await tester.tap(find.text(l10nEn.skip));
      await tester.pumpAndSettle();

      verify(() => complete()).called(1);
      expect(find.text('route: ${AppRoutes.home}'), findsOneWidget);
    });

    testView('Arabic: the Follow pill and texts are Arabic', (tester) async {
      await open(tester, locale: const Locale('ar'), step: 6);

      expect(find.text(l10nAr.followTitle), findsOneWidget);
      expect(find.text(l10nAr.follow), findsWidgets);
      expect(find.text(l10nAr.mutualFriends(12)), findsOneWidget);
    });

    testWidgets('at 320 dp and 1.5x text nothing overflows', (tester) async {
      setUpView(tester, size: const Size(320, 640), textScale: 1.5);
      await open(tester, step: 5);
      expect(tester.takeException(), isNull);
      await open(tester, step: 6);
      expect(tester.takeException(), isNull);
    });
  });

  group('Leave dialog', () {
    testView('the arrow on About you asks first; Keep going stays', (
      tester,
    ) async {
      await open(tester, step: 3);
      await tester.tap(find.bySemanticsLabel(l10nEn.back));
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.leaveTitle), findsOneWidget);
      expect(find.text(l10nEn.leaveBody), findsOneWidget);
      await tester.tap(find.text(l10nEn.keepGoing));
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.leaveTitle), findsNothing);
      expect(find.text(l10nEn.aboutTitle), findsOneWidget);
      verifyNever(() => auth.signOut(others: any(named: 'others')));
    });

    for (final step in [3, 4, 5, 6]) {
      testView('the system back on step $step opens it', (tester) async {
        await open(tester, step: step);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text(l10nEn.leaveTitle), findsOneWidget);
      });
    }

    testView('Leave signs out and goes to Sign in', (tester) async {
      await open(tester, step: 4);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.leave));
      await tester.pumpAndSettle();

      verifyInOrder([() => clearLocal(), () => auth.signOut()]);
      expect(find.text('route: ${AppRoutes.signIn}'), findsOneWidget);
    });

    testView('the Leave button is on the end side and mirrors in Arabic', (
      tester,
    ) async {
      await open(tester, step: 3);
      await tester.tap(find.bySemanticsLabel(l10nEn.back));
      await tester.pumpAndSettle();
      final leaveEn = tester.getCenter(find.text(l10nEn.leave));
      final keepEn = tester.getCenter(find.text(l10nEn.keepGoing));
      expect(leaveEn.dx, greaterThan(keepEn.dx));
    });

    testView('Arabic: Leave is on the left', (tester) async {
      await open(tester, locale: const Locale('ar'), step: 3);
      await tester.tap(find.bySemanticsLabel(l10nAr.back));
      await tester.pumpAndSettle();
      final leave = tester.getCenter(find.text(l10nAr.leave));
      final keep = tester.getCenter(find.text(l10nAr.keepGoing));
      expect(leave.dx, lessThan(keep.dx));
    });
  });
}
