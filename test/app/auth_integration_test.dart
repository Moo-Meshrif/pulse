import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/presentation/widgets/labeled_checkbox.dart';
import 'package:pulse/features/profile/data/datasource/follows_datasource.dart';
import 'package:pulse/features/profile/data/datasource/interests_datasource.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/enums/suggestion_tab.dart';
import 'package:pulse/features/profile/data/model/interest_model.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:pulse/features/profile/data/model/profile_update_model.dart';
import 'package:pulse/features/profile/data/model/suggested_profile_model.dart';

import '../helpers/pump_app.dart';

/// The auth flows through the real app wiring (router, DI, cubits, use cases, repository) over mocked
/// datasources: start-up decisions, the whole sign-up, and the reset link.
void main() {
  late MockAuthDatasource auth;
  late MockProfileDatasource profiles;
  late StreamController<void> recovery;

  setUpAll(() {
    registerFallbackValue(const ProfileUpdateModel());
    registerFallbackValue(SuggestionTab.suggested);
  });

  setUp(() {
    auth = MockAuthDatasource();
    profiles = MockProfileDatasource();
    recovery = StreamController<void>.broadcast();
    when(() => auth.hasSession).thenReturn(false);
    when(() => auth.currentEmail).thenReturn(null);
    when(() => auth.passwordRecovery).thenAnswer((_) => recovery.stream);
    when(() => profiles.currentUserId).thenReturn('u1');
    addTearDown(recovery.close);
  });

  Future<void> boot(WidgetTester tester, {bool seen = true}) {
    setUpView(tester);
    return tester.bootApp(
      prefs: {if (seen) 'onboarding_seen': true},
      auth: auth,
      profiles: profiles,
    );
  }

  Finder field(int index) => find
      .descendant(
        of: find.byType(AppTextField),
        matching: find.byType(TextField),
      )
      .at(index);

  group('start-up', () {
    testWidgets('first launch opens onboarding', (tester) async {
      await boot(tester, seen: false);
      expect(find.text(l10nEn.next), findsOneWidget);
    });

    testWidgets('no session opens Sign in', (tester) async {
      await boot(tester);
      expect(find.text(l10nEn.signInTitle), findsOneWidget);
    });

    testWidgets('a complete account opens Home', (tester) async {
      when(() => auth.hasSession).thenReturn(true);
      when(() => profiles.getProfile()).thenAnswer(
        (_) async =>
            const ProfileModel(id: 'u1', signupStep: SignupStep.complete),
      );
      await boot(tester);
      expect(find.text(AppRoutes.home), findsOneWidget);
    });

    testWidgets('an unfinished sign-up resumes at its saved step', (
      tester,
    ) async {
      when(() => auth.hasSession).thenReturn(true);
      when(() => profiles.getProfile()).thenAnswer(
        (_) async =>
            const ProfileModel(id: 'u1', signupStep: SignupStep.profile),
      );
      await boot(tester);

      expect(find.text(l10nEn.profileTitle), findsOneWidget);
      expect(find.text(l10nEn.stepOf(4)), findsOneWidget);
    });
  });

  group('reset link', () {
    testWidgets('the recovery event opens the reset screen on a clean stack', (
      tester,
    ) async {
      await boot(tester);
      when(() => auth.currentEmail).thenReturn('ada@example.com');
      recovery.add(null);
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.resetTitle), findsOneWidget);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
    });

    testWidgets(
      'a second event while the screen is open does not stack another',
      (tester) async {
        await boot(tester);
        when(() => auth.currentEmail).thenReturn('ada@example.com');
        recovery.add(null);
        await tester.pumpAndSettle();
        recovery.add(null);
        await tester.pumpAndSettle();

        expect(find.text(l10nEn.resetTitle), findsOneWidget);
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
          isFalse,
        );
      },
    );

    testWidgets('update, Password updated, Sign in ends on Sign in', (
      tester,
    ) async {
      when(() => auth.updatePassword(any())).thenAnswer((_) async {});
      when(() => auth.signOut(others: any(named: 'others')))
          .thenAnswer((_) async {});
      await boot(tester);
      when(() => auth.currentEmail).thenReturn('ada@example.com');
      recovery.add(null);
      await tester.pumpAndSettle();

      await tester.enterText(field(0), 'Password1');
      await tester.enterText(field(1), 'Password1');
      await tester.pump();
      await tester.tap(find.text(l10nEn.updatePassword));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.updatedTitle), findsOneWidget);

      await tester.tap(find.text(l10nEn.signIn));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.signInTitle), findsOneWidget);
    });
  });

  testWidgets('a new user registers through step 6 and lands on Home', (
    tester,
  ) async {
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
    when(() => profiles.isUsernameAvailable(any()))
        .thenAnswer((_) async => true);
    when(() => profiles.updateProfile(any()))
        .thenAnswer((_) async => const ProfileModel(id: 'u1'));
    await boot(tester);
    final interests = getIt<InterestsDatasource>();
    final follows = getIt<FollowsDatasource>();
    when(() => interests.getInterests())
        .thenAnswer((_) async => [InterestModel(id: 1, nameEn: 'Travel')]);
    when(() => interests.saveInterests(any())).thenAnswer((_) async {});
    when(
      () => follows.getSuggestedProfiles(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer(
      (_) async => [SuggestedProfileModel(id: 'p1', fullName: 'Salma Kamal')],
    );

    // Sign in -> Create account -> Account.
    await tester.tap(
      find.textContaining(l10nEn.createAccount, findRichText: true),
    );
    await tester.pumpAndSettle();
    await tester.enterText(field(0), 'ada@example.com');
    await tester.enterText(field(1), 'Password1!');
    await tester.tap(find.byType(LabeledCheckbox));
    await tester.pump();
    await tester.tap(find.text(l10nEn.continueButton));
    await tester.pump(const Duration(milliseconds: 400));

    // Verify email (the code boxes blink for ever, so the screen never settles).
    expect(find.text(l10nEn.verifyTitle), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pump();
    await tester.tap(find.text(l10nEn.verify));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // About you.
    expect(find.text(l10nEn.aboutTitle), findsOneWidget);
    await tester.enterText(field(0), 'Ada Lovelace');
    await tester.enterText(field(1), 'ada_l');
    await tester.tap(field(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10nEn.continueButton));
    await tester.pumpAndSettle();

    // Profile -> Skip.
    expect(find.text(l10nEn.profileTitle), findsOneWidget);
    await tester.tap(find.text(l10nEn.skip));
    await tester.pumpAndSettle();

    // Interests -> Skip.
    expect(find.text(l10nEn.interestsTitle), findsOneWidget);
    await tester.tap(find.text(l10nEn.skip));
    await tester.pumpAndSettle();

    // Follow -> Continue -> Home.
    expect(find.text(l10nEn.followTitle), findsOneWidget);
    await tester.tap(find.text(l10nEn.continueButton));
    await tester.pumpAndSettle();

    expect(find.text(AppRoutes.home), findsOneWidget);
    verify(
      () => profiles.updateProfile(
        const ProfileUpdateModel(signupStep: SignupStep.complete),
      ),
    ).called(1);
    verify(
      () => follows.getSuggestedProfiles(
        SuggestionTab.popular,
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).called(1);
  });
}
