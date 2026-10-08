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
  String get terms => 'Terms';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get comingSoon => 'Coming soon';

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

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String stepOf(int n) {
    return 'Step $n of 6';
  }

  @override
  String get required => 'Required';

  @override
  String get optional => 'Optional';

  @override
  String get strengthWeak => 'Weak';

  @override
  String get strengthFair => 'Fair';

  @override
  String get strengthGood => 'Good';

  @override
  String get strengthStrong => 'Strong';

  @override
  String passwordStrength(String strength) {
    return 'Password strength: $strength';
  }

  @override
  String otpDigit(int n) {
    return 'Digit $n of 6';
  }

  @override
  String ruleMet(String rule) {
    return '$rule, met';
  }

  @override
  String ruleNotMet(String rule) {
    return '$rule, not met';
  }

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get loading => 'Loading';

  @override
  String get offlineTitle => 'You\'re offline';

  @override
  String get offlineBody =>
      'Check your Wi-Fi or mobile data. We\'ll try again as soon as you\'re back online.';

  @override
  String get cantReachTitle => 'Can\'t reach Pulse';

  @override
  String get cantReachBody =>
      'Something went wrong on our side. Your account is safe — please try again in a moment.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to catch up on your feed.';

  @override
  String get identifierLabel => 'Email or username';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signInButton => 'Sign in';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get newToPulse => 'New to Pulse?';

  @override
  String get createAccount => 'Create account';

  @override
  String get errorCredentials => 'Incorrect email or password';

  @override
  String get errorIdentifierRequired => 'Enter your email or username';

  @override
  String get errorPasswordRequired => 'Enter your password';

  @override
  String errorTooManyAttempts(String time) {
    return 'Too many attempts. Try again in $time.';
  }

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get forgotTitle => 'Forgot password?';

  @override
  String get forgotSubtitle =>
      'Enter the email linked to your account and we\'ll send you a reset link.';

  @override
  String get emailLabel => 'Email';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get errorInvalidEmail => 'Enter a valid email';

  @override
  String get sentTitle => 'Check your email';

  @override
  String sentBody(String email) {
    return 'We sent a reset link to $email. Open it to set a new password.';
  }

  @override
  String get openEmailApp => 'Open email app';

  @override
  String get noEmailApp => 'No email app found';

  @override
  String get didntGetIt => 'Didn\'t get it?';

  @override
  String get resendLink => 'Resend link';

  @override
  String resendLinkIn(String time) {
    return 'Resend link in $time';
  }

  @override
  String get changeEmail => 'Change email';

  @override
  String get linkResent => 'Link sent again';
}
