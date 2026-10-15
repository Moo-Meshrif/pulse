import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/enums/recovery_signal.dart';
import 'package:pulse/core/enums/signed_out_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/presentation/widgets/labeled_checkbox.dart';
import 'package:pulse/features/control/presentation/screen/control_screen.dart';
import 'package:pulse/features/follow/data/datasource/follows_datasource.dart';
import 'package:pulse/features/follow/data/enums/suggestion_tab.dart';
import 'package:pulse/features/follow/data/model/suggested_profile_model.dart';
import 'package:pulse/features/profile/data/datasource/interests_datasource.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/interest_model.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:pulse/features/profile/data/model/profile_update_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

/// The auth flows through the real app wiring (router, DI, cubits, use cases, repository) over mocked
/// datasources: start-up decisions, the whole sign-up, and the reset link.
void main() {
  late MockAuthDatasource auth;
  late MockProfileDatasource profiles;
  late StreamController<RecoverySignal> recovery;
  late StreamController<SignedOutReason> ended;

  setUpAll(() {
    registerFallbackValue(const ProfileUpdateModel());
    registerFallbackValue(SuggestionTab.suggested);
  });

  setUp(() {
    auth = MockAuthDatasource();
    profiles = MockProfileDatasource();
    recovery = StreamController<RecoverySignal>.broadcast();
    ended = StreamController<SignedOutReason>.broadcast();
    when(() => auth.hasSession).thenReturn(false);
    when(() => auth.currentEmail).thenReturn(null);
    when(() => auth.recoveryActive).thenReturn(false);
    when(() => auth.recoverySignals).thenAnswer((_) => recovery.stream);
    when(() => auth.sessionEnded).thenAnswer((_) => ended.stream);
    when(() => profiles.currentUserId).thenReturn('u1');
    addTearDown(recovery.close);
    addTearDown(ended.close);
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
      expect(find.byType(ControlScreen), findsOneWidget);
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

  group('a session that ended', () {
    const saved = {
      'profile_u1': '{"id":"u1","username":"nour.adel","full_name":"Nour Adel","signup_step":0}',
      'last_account_id': 'u1',
    };

    Future<void> bootWithDeadSession(
      WidgetTester tester,
      AuthFailureReason reason, {
      Map<String, Object> prefs = saved,
    }) {
      setUpView(tester);
      when(() => auth.hasSession).thenReturn(true);
      when(() => profiles.getProfile()).thenThrow(AuthFailure(reason));
      return tester.bootApp(
        prefs: {'onboarding_seen': true, ...prefs},
        auth: auth,
        profiles: profiles,
      );
    }

    testWidgets('an expired session shows the banner and the saved account', (
      tester,
    ) async {
      await bootWithDeadSession(tester, AuthFailureReason.sessionExpired);

      expect(find.text(l10nEn.signedOutTitle), findsOneWidget);
      expect(find.text(l10nEn.signedOutExpiredBody), findsOneWidget);
      expect(find.text(l10nEn.signedOutSubtitle), findsOneWidget);
      expect(find.text('Nour Adel'), findsOneWidget);
      expect(find.text('@nour.adel'), findsOneWidget);
      expect(find.text(l10nEn.identifierLabel), findsNothing);
    });

    testWidgets('a revoked session says it was ended elsewhere', (
      tester,
    ) async {
      await bootWithDeadSession(tester, AuthFailureReason.sessionRevoked);

      expect(find.text(l10nEn.signedOutRevokedBody), findsOneWidget);
      expect(find.text(l10nEn.signedOutExpiredBody), findsNothing);
    });

    testWidgets(
      'without a saved account the banner shows over the normal form',
      (tester) async {
        await bootWithDeadSession(
          tester,
          AuthFailureReason.sessionExpired,
          prefs: const {},
        );

        expect(find.text(l10nEn.signedOutExpiredBody), findsOneWidget);
        expect(find.text(l10nEn.identifierLabel), findsOneWidget);
        expect(find.text(l10nEn.signInSubtitle), findsOneWidget);
      },
    );

    testWidgets('"Not you?" forgets the account and shows the normal form', (
      tester,
    ) async {
      await bootWithDeadSession(tester, AuthFailureReason.sessionExpired);

      await tester.tap(find.text(l10nEn.notYou));
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.signedOutTitle), findsNothing);
      expect(find.text('Nour Adel'), findsNothing);
      expect(find.text(l10nEn.identifierLabel), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('profile_u1'), isFalse);
      expect(prefs.containsKey('last_account_id'), isFalse);
    });

    testWidgets(
      'the session ending while on Home opens Sign in with the banner',
      (tester) async {
        when(() => auth.hasSession).thenReturn(true);
        when(() => profiles.getProfile()).thenAnswer(
          (_) async => const ProfileModel(
            id: 'u1',
            username: 'nour.adel',
            fullName: 'Nour Adel',
            signupStep: SignupStep.complete,
          ),
        );
        await boot(tester);
        expect(find.byType(ControlScreen), findsOneWidget);

        ended.add(SignedOutReason.expired);
        await tester.pumpAndSettle();

        expect(find.text(l10nEn.signedOutExpiredBody), findsOneWidget);
        expect(find.text('Nour Adel'), findsOneWidget);
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
          isFalse,
        );
      },
    );

    testWidgets('the session ending on Sign in changes nothing', (
      tester,
    ) async {
      await boot(tester);
      ended.add(SignedOutReason.expired);
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.signedOutTitle), findsNothing);
      expect(find.text(l10nEn.signInTitle), findsOneWidget);
    });
  });

  group('reset link', () {
    testWidgets(
      'a refused link shows a snackbar and leaves the screen as it is',
      (tester) async {
        await boot(tester);
        final before = find.text(l10nEn.signInTitle);
        expect(before, findsOneWidget);

        recovery.add(RecoverySignal.linkFailed);
        await tester.pumpAndSettle();

        expect(find.text(l10nEn.linkExpiredSnackBar), findsOneWidget);
        expect(find.text(l10nEn.resetTitle), findsNothing);
        expect(before, findsOneWidget);
      },
    );

    testWidgets('the recovery event opens the reset screen on a clean stack', (
      tester,
    ) async {
      await boot(tester);
      when(() => auth.currentEmail).thenReturn('ada@example.com');
      when(() => auth.recoveryActive).thenReturn(true);
      recovery.add(RecoverySignal.started);
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
        when(() => auth.recoveryActive).thenReturn(true);
        recovery.add(RecoverySignal.started);
        await tester.pumpAndSettle();
        recovery.add(RecoverySignal.started);
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
      when(() => auth.recoveryActive).thenReturn(true);
      recovery.add(RecoverySignal.started);
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
    ).thenAnswer((_) async => false);
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

    // Follow -> Skip (Continue needs a follow) -> Home.
    expect(find.text(l10nEn.followTitle), findsOneWidget);
    await tester.tap(find.text(l10nEn.skip));
    await tester.pumpAndSettle();

    expect(find.byType(ControlScreen), findsOneWidget);
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
