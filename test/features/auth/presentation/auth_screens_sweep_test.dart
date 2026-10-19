import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/services/launch_service.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/core/utils/country_names_delegate.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/presentation/cubit/forgot_password/forgot_password_cubit.dart';
import 'package:pulse/features/auth/presentation/cubit/reset_password/reset_password_cubit.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_in/sign_in_cubit.dart';
import 'package:pulse/features/auth/presentation/cubit/sign_up/sign_up_cubit.dart';
import 'package:pulse/features/auth/presentation/screen/forgot_password_screen.dart';
import 'package:pulse/features/auth/presentation/screen/reset_password_screen.dart';
import 'package:pulse/features/auth/presentation/screen/sign_in_screen.dart';
import 'package:pulse/features/auth/presentation/screen/sign_up_screen.dart';
import 'package:pulse/features/follow/data/enums/suggestion_reason.dart';
import 'package:pulse/features/follow/data/enums/suggestion_tab.dart';
import 'package:pulse/features/follow/data/model/suggested_profile_model.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/interest_model.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../../helpers/pump_app.dart';

class _MockLaunchService extends Mock implements LaunchService {}

class _MockGetSignupStep extends Mock implements GetSignupStepUseCase {}

/// Every auth screen, EN and AR, on a small phone at the largest text scale: nothing overflows, every
/// tap target is at least 44 x 44 and every one has a label (plan Phase 11, accessibility pass).
void main() {
  late MockAuthDatasource auth;

  setUp(() async {
    auth = MockAuthDatasource();
    when(() => auth.currentEmail).thenReturn('ada.lovelace@example.com');
    when(() => auth.recoverySignals).thenAnswer((_) => const Stream.empty());
    when(() => auth.recoveryActive).thenReturn(false);
    when(() => auth.sessionEnded).thenAnswer((_) => const Stream.empty());
    final getDraft = MockGetSignupDraftUseCase();
    when(() => getDraft()).thenAnswer((_) async => const ProfileEntity());
    final getInterests = MockGetInterestsUseCase();
    when(() => getInterests()).thenAnswer(
      (_) async => const [
        InterestModel(id: 1, nameEn: 'Travel', nameAr: 'سفر'),
        InterestModel(id: 2, nameEn: 'Food', nameAr: 'طعام'),
      ],
    );
    final getPeople = MockGetSuggestedProfilesUseCase();
    registerFallbackValue(SuggestionTab.suggested);
    when(() => getPeople(any())).thenAnswer(
      (_) async => const [
        SuggestedProfileModel(
          id: 'u1',
          fullName: 'Ada Lovelace',
          reason: SuggestionReason.mutual,
          mutualCount: 12,
        ),
      ],
    );
    final getStep = _MockGetSignupStep();
    when(() => getStep()).thenAnswer((_) async => SignupStep.complete);
    await getIt.reset();
    getIt
      ..registerFactory<SignInCubit>(
        () => SignInCubit(
          auth,
          getStep,
          MockGetLastAccountUseCase(),
          MockForgetLastAccountUseCase(),
        ),
      )
      ..registerFactory<ForgotPasswordCubit>(
        () => ForgotPasswordCubit(auth, _MockLaunchService()),
      )
      ..registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(auth))
      ..registerFactory<SignUpCubit>(
        () => SignUpCubit(
          auth,
          MockSaveAboutYouUseCase(),
          MockSaveProfileDetailsUseCase(),
          MockPhotoPickerService(),
          getInterests,
          MockSaveInterestsUseCase(),
          getPeople,
          MockToggleFollowUseCase(),
          MockFollowAllUseCase(),
          MockCompleteSignupUseCase(),
          MockClearLocalProfileUseCase(),
          getStep,
          getDraft,
        ),
      );
    addTearDown(getIt.reset);
  });

  final screens = <String, Widget Function()>{
    'Sign in': () => const SignInScreen(),
    'Forgot password': () => const ForgotPasswordScreen(),
    'Set a new password': () => const ResetPasswordScreen(),
    'Sign-up Account': () => const SignUpScreen(step: 1),
    'Sign-up Verify': () =>
        const SignUpScreen(step: 2, email: 'ada@example.com'),
    'Sign-up About you': () => const SignUpScreen(step: 3),
    'Sign-up Profile': () => const SignUpScreen(step: 4),
    'Sign-up Interests': () => const SignUpScreen(step: 5),
    'Sign-up Follow': () => const SignUpScreen(step: 6),
  };

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final entry in screens.entries) {
      testWidgets(
        '${entry.key} (${locale.languageCode}) at 360 x 640, 2x text',
        (tester) async {
          setUpView(tester, size: const Size(360, 640), textScale: 2);
          final semantics = tester.ensureSemantics();
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
                home: entry.value(),
              ),
            ),
          );
          // Code boxes blink a cursor for ever, so never wait for "settled".
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(milliseconds: 500));

          expect(tester.takeException(), isNull);
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          semantics.dispose();
        },
      );
    }
  }
}
