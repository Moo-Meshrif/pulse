// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'pulse';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get signIn => 'Sign in';

  @override
  String onboardingPageIndicator(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get onboarding1Title => 'Share the moments that move you';

  @override
  String get onboarding1Body =>
      'Post photos and stories from your day, and see what your friends are up to.';

  @override
  String get onboarding2Title => 'Swipe through short videos';

  @override
  String get onboarding2Body =>
      'Quick, full-screen clips from creators you follow and new ones picked for you.';

  @override
  String get onboarding3Title => 'Stay close with chat';

  @override
  String get onboarding3Body =>
      'Message friends one on one or in groups. Send photos, shorts and voice notes.';
}
