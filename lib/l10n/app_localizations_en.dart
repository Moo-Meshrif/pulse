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
  String get errorCredentials => 'Incorrect email/username or password';

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
  String get errorEmailSend =>
      'We couldn\'t send the email right now. Please try again in a few minutes.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorServer =>
      'We couldn\'t complete that right now. Please try again shortly.';

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

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpSubtitle => 'Start with just your email and a password.';

  @override
  String get passwordHintMin => 'At least 8 characters';

  @override
  String get agreePrefix => 'I agree to the';

  @override
  String get agreeAnd => 'and';

  @override
  String get orSignUpWith => 'or sign up with';

  @override
  String get continueButton => 'Continue';

  @override
  String get alreadyOnPulse => 'Already on Pulse?';

  @override
  String get errorPasswordShort => 'Password must be at least 8 characters';

  @override
  String get errorEmailExists => 'An account with this email already exists';

  @override
  String get errorAccountNotFound => 'No account found with this email';

  @override
  String get verifyTitle => 'Check your email';

  @override
  String verifySubtitle(String email) {
    return 'We sent a 6-digit code to $email. Enter it below to verify your account.';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeIn(String time) {
    return 'Resend code in $time';
  }

  @override
  String get verify => 'Verify';

  @override
  String get useDifferentEmail => 'Use a different email';

  @override
  String get errorWrongCode => 'Wrong code, try again';

  @override
  String get aboutTitle => 'About you';

  @override
  String get aboutSubtitle => 'This is how people will find you on Pulse.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Your name';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'username';

  @override
  String get usernameHelper =>
      'Letters, numbers, dots and underscores. At least 3 characters.';

  @override
  String get birthdayLabel => 'Birthday';

  @override
  String get birthdayHint => 'DD / MM / YYYY';

  @override
  String get birthdayHelper =>
      'Used to confirm your age. It isn\'t shown on your profile.';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderOptional => '(optional)';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderPreferNot => 'Prefer not to say';

  @override
  String get errorUsernameTaken => 'Username is taken';

  @override
  String get errorMinAge => 'You must be at least 18';

  @override
  String get profileTitle => 'Set up your profile';

  @override
  String get profileSubtitle =>
      'All optional. You can add these later in Settings.';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get addPhotoHint => 'Profiles with a photo get more follows.';

  @override
  String get bioLabel => 'Bio';

  @override
  String get bioHint => 'A few words about you';

  @override
  String get cityLabel => 'City';

  @override
  String get cityHint => 'Where are you based?';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '+20 ••• ••• ••••';

  @override
  String get phoneHelper =>
      'Helps friends find you and lets you recover your account. Kept private.';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get errorPhone => 'Enter a valid phone number';

  @override
  String get interestsTitle => 'What are you into?';

  @override
  String get interestsSubtitle =>
      'Pick a few topics so your feed and shorts feel like you.';

  @override
  String selectedCount(int n) {
    return '$n selected';
  }

  @override
  String get interestsError => 'Couldn\'t load topics';

  @override
  String get retry => 'Retry';

  @override
  String get followTitle => 'Follow people you know';

  @override
  String get followSubtitle =>
      'Their posts and shorts will show up in your feed. You can change this anytime.';

  @override
  String get tabSuggested => 'Suggested';

  @override
  String get tabContacts => 'From contacts';

  @override
  String get tabPopular => 'Popular';

  @override
  String get suggestedForYou => 'SUGGESTED FOR YOU';

  @override
  String get followAll => 'Follow all';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String followPerson(String name) {
    return 'Follow $name';
  }

  @override
  String unfollowPerson(String name) {
    return 'Unfollow $name';
  }

  @override
  String mutualFriends(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mutual friends',
      one: '1 mutual friend',
    );
    return '$_temp0';
  }

  @override
  String livesIn(String city) {
    return 'Lives in $city';
  }

  @override
  String get followHint => 'Follow at least 3 people for a better feed';

  @override
  String get noSuggestions => 'No suggestions yet';

  @override
  String get followError => 'Couldn\'t load people';

  @override
  String get leaveTitle => 'Leave sign-up?';

  @override
  String get leaveBody =>
      'Your progress is saved. You can pick up where you left off the next time you sign in.';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get leave => 'Leave';

  @override
  String get resetTitle => 'Set a new password';

  @override
  String resetSubtitle(String email) {
    return 'For $email. Use something you haven\'t used on Pulse before.';
  }

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get ruleLength => 'At least 8 characters';

  @override
  String get ruleNumber => 'Contains a number';

  @override
  String get ruleCase => 'Upper and lower case letters';

  @override
  String get confirmLabel => 'Confirm new password';

  @override
  String get confirmHint => 'Type it again';

  @override
  String get logoutOthers => 'Log out of all other devices';

  @override
  String get updatePassword => 'Update password';

  @override
  String get errorMismatch => 'Passwords don\'t match';

  @override
  String get linkExpiredTitle => 'This link has expired';

  @override
  String get linkExpiredBody => 'Request a new link to reset your password.';

  @override
  String get requestNewLink => 'Request a new link';

  @override
  String get updatedTitle => 'Password updated';

  @override
  String get updatedBodyOthers =>
      'You can now sign in with your new password. Other devices have been logged out.';

  @override
  String get updatedBody => 'You can now sign in with your new password.';

  @override
  String get close => 'Close';
}
