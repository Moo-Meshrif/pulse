import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name and header wordmark
  ///
  /// In en, this message translates to:
  /// **'pulse'**
  String get appTitle;

  /// Accessibility label of the back arrow
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Accessibility label of the onboarding page dots
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String onboardingPageIndicator(int current, int total);

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Share the moments that move you'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Post photos and stories from your day, and see what your friends are up to.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Swipe through short videos'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Quick, full-screen clips from creators you follow and new ones picked for you.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Stay close with chat'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Message friends one on one or in groups. Send photos, shorts and voice notes.'**
  String get onboarding3Body;

  /// Accessibility label of the eye button while the password is hidden
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Accessibility label of the eye button while the password is visible
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of 6'**
  String stepOf(int n);

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get strengthFair;

  /// No description provided for @strengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get strengthGood;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// Accessibility label of the password strength meter
  ///
  /// In en, this message translates to:
  /// **'Password strength: {strength}'**
  String passwordStrength(String strength);

  /// Accessibility label of one verification-code box
  ///
  /// In en, this message translates to:
  /// **'Digit {n} of 6'**
  String otpDigit(int n);

  /// Accessibility label of a satisfied password rule
  ///
  /// In en, this message translates to:
  /// **'{rule}, met'**
  String ruleMet(String rule);

  /// Accessibility label of an unmet password rule
  ///
  /// In en, this message translates to:
  /// **'{rule}, not met'**
  String ruleNotMet(String rule);

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// Accessibility label of the loading indicator
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Splash: title when the first request failed because the connection is lost
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineTitle;

  /// Splash: body of the offline screen
  ///
  /// In en, this message translates to:
  /// **'Check your Wi-Fi or mobile data. We\'ll try again as soon as you\'re back online.'**
  String get offlineBody;

  /// Splash: title when the first request failed for another reason
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach Pulse'**
  String get cantReachTitle;

  /// Splash: body of the can't-reach screen
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Your account is safe — please try again in a moment.'**
  String get cantReachBody;

  /// Button that runs the failed request again
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Sign in: title
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// Sign in: subtitle under the title
  ///
  /// In en, this message translates to:
  /// **'Sign in to catch up on your feed.'**
  String get signInSubtitle;

  /// Sign in: label of the first field
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get identifierLabel;

  /// Hint of an email field
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// Label of a password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Sign in: hint of the password field
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get passwordHint;

  /// Sign in: link to the password reset
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Sign in: primary button
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// Divider above the Google and Apple buttons
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// Sign in: footer prompt before the Create account link
  ///
  /// In en, this message translates to:
  /// **'New to Pulse?'**
  String get newToPulse;

  /// Sign in: footer link to the sign-up flow
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Sign in: snackbar when the credentials are wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect email/username or password'**
  String get errorCredentials;

  /// Sign in: snackbar while sign-in is throttled; {time} is a m:ss countdown
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {time}.'**
  String errorTooManyAttempts(String time);

  /// Snackbar when a request failed because the device is offline or timed out
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errorNetwork;

  /// Forgot password: title
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotTitle;

  /// Forgot password: subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter the email linked to your account and we\'ll send you a reset link.'**
  String get forgotSubtitle;

  /// Label of an email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Forgot password: primary button
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// Button that returns to the Sign in screen
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// Snackbar: the verification or reset email could not be sent
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send the email right now. Please try again in a few minutes.'**
  String get errorEmailSend;

  /// Snackbar: the server rate-limited the request
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorRateLimited;

  /// Snackbar: the server answered with an error
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete that right now. Please try again shortly.'**
  String get errorServer;

  /// Snackbar when a request failed
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// Shown under an email field whose text is not an address
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get errorInvalidEmail;

  /// Reset link sent dialog: title
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get sentTitle;

  /// Reset link sent dialog: body; {email} is the masked address, set in bold
  ///
  /// In en, this message translates to:
  /// **'We sent a reset link to {email}. Open it to set a new password.'**
  String sentBody(String email);

  /// Reset link sent dialog: opens the mail app
  ///
  /// In en, this message translates to:
  /// **'Open email app'**
  String get openEmailApp;

  /// Snackbar when the mail app could not be opened
  ///
  /// In en, this message translates to:
  /// **'No email app found'**
  String get noEmailApp;

  /// Reset link sent dialog: prompt before Resend and Change email
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get didntGetIt;

  /// Reset link sent dialog: sends the link again
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get resendLink;

  /// Reset link sent dialog: Resend while the cooldown runs; {time} is m:ss
  ///
  /// In en, this message translates to:
  /// **'Resend link in {time}'**
  String resendLinkIn(String time);

  /// Reset link sent dialog: closes it and focuses the email field
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// Snackbar after the reset link was sent again
  ///
  /// In en, this message translates to:
  /// **'Link sent again'**
  String get linkResent;

  /// Sign-up Account step: title
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// Sign-up Account step: subtitle
  ///
  /// In en, this message translates to:
  /// **'Start with just your email and a password.'**
  String get signUpSubtitle;

  /// Sign-up Account step: password field hint
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHintMin;

  /// Sign-up Account step: before the Terms link in the checkbox line
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get agreePrefix;

  /// Sign-up Account step: between the Terms and Privacy Policy links
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get agreeAnd;

  /// Sign-up Account step: divider above the social buttons
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get orSignUpWith;

  /// Sign-up Account step: primary button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Sign-up Account step: prompt before the Sign in link
  ///
  /// In en, this message translates to:
  /// **'Already on Pulse?'**
  String get alreadyOnPulse;

  /// Shown under the password field when it is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errorPasswordShort;

  /// Shown under the email field when sign-up finds the address registered
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get errorEmailExists;

  /// Shown under the email field when forgot password finds no account with the address
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get errorAccountNotFound;

  /// Sign-up Verify email step: title
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get verifyTitle;

  /// Sign-up Verify email step: subtitle; {email} is the masked address, set in bold
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. Enter it below to verify your account.'**
  String verifySubtitle(String email);

  /// Sign-up Verify email step: sends the code again
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// Sign-up Verify email step: Resend while the cooldown runs; {time} is m:ss
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String resendCodeIn(String time);

  /// Sign-up Verify email step: primary button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Sign-up Verify email step: goes back to the Account step
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get useDifferentEmail;

  /// Shown under the code boxes when the code is wrong or expired
  ///
  /// In en, this message translates to:
  /// **'Wrong code, try again'**
  String get errorWrongCode;

  /// Sign-up About you step: title
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get aboutTitle;

  /// Sign-up About you step: subtitle
  ///
  /// In en, this message translates to:
  /// **'This is how people will find you on Pulse.'**
  String get aboutSubtitle;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// Full name field hint
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get fullNameHint;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// Username field hint, after the @
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get usernameHint;

  /// Username field helper; red when the format is wrong
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers, dots and underscores. At least 3 characters.'**
  String get usernameHelper;

  /// Birthday field label
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthdayLabel;

  /// Birthday field hint
  ///
  /// In en, this message translates to:
  /// **'DD / MM / YYYY'**
  String get birthdayHint;

  /// Birthday field helper
  ///
  /// In en, this message translates to:
  /// **'Used to confirm your age. It isn\'t shown on your profile.'**
  String get birthdayHelper;

  /// Gender chips label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// Gender chips label suffix
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get genderOptional;

  /// Gender chip
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// Gender chip
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// Gender chip
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNot;

  /// Shown under the username field when somebody has it
  ///
  /// In en, this message translates to:
  /// **'Username is taken'**
  String get errorUsernameTaken;

  /// Shown under the birthday field for a younger user
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18'**
  String get errorMinAge;

  /// Sign-up Profile step: title
  ///
  /// In en, this message translates to:
  /// **'Set up your profile'**
  String get profileTitle;

  /// Sign-up Profile step: subtitle
  ///
  /// In en, this message translates to:
  /// **'All optional. You can add these later in Settings.'**
  String get profileSubtitle;

  /// Profile photo picker title
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// Profile photo picker caption
  ///
  /// In en, this message translates to:
  /// **'Profiles with a photo get more follows.'**
  String get addPhotoHint;

  /// Bio field label
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// Bio field hint
  ///
  /// In en, this message translates to:
  /// **'A few words about you'**
  String get bioHint;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// City field hint
  ///
  /// In en, this message translates to:
  /// **'Where are you based?'**
  String get cityHint;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// Phone field hint
  ///
  /// In en, this message translates to:
  /// **'+20 ••• ••• ••••'**
  String get phoneHint;

  /// Phone field helper
  ///
  /// In en, this message translates to:
  /// **'Helps friends find you and lets you recover your account. Kept private.'**
  String get phoneHelper;

  /// Photo sheet: opens the camera
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// Photo sheet: opens the photo library
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseGallery;

  /// Photo sheet: clears the chosen photo
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// Shown under the phone field
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get errorPhone;

  /// Interests step: title
  ///
  /// In en, this message translates to:
  /// **'What are you into?'**
  String get interestsTitle;

  /// Interests step: subtitle
  ///
  /// In en, this message translates to:
  /// **'Pick a few topics so your feed and shorts feel like you.'**
  String get interestsSubtitle;

  /// Interests step: caption above Continue; {n} is how many topics are picked
  ///
  /// In en, this message translates to:
  /// **'{n} selected'**
  String selectedCount(int n);

  /// Interests step: shown when the topics could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load topics'**
  String get interestsError;

  /// Button that loads a list again
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Follow step: title
  ///
  /// In en, this message translates to:
  /// **'Follow people you know'**
  String get followTitle;

  /// Follow step: subtitle
  ///
  /// In en, this message translates to:
  /// **'Their posts and shorts will show up in your feed. You can change this anytime.'**
  String get followSubtitle;

  /// Follow step: tab
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get tabSuggested;

  /// Follow step: tab
  ///
  /// In en, this message translates to:
  /// **'From contacts'**
  String get tabContacts;

  /// Follow step: tab
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get tabPopular;

  /// Follow step: heading over the suggested list
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED FOR YOU'**
  String get suggestedForYou;

  /// Follow step: follows everyone listed
  ///
  /// In en, this message translates to:
  /// **'Follow all'**
  String get followAll;

  /// Follow button
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// Follow button once followed
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// Follow button's screen-reader label
  ///
  /// In en, this message translates to:
  /// **'Follow {name}'**
  String followPerson(String name);

  /// Following button's screen-reader label
  ///
  /// In en, this message translates to:
  /// **'Unfollow {name}'**
  String unfollowPerson(String name);

  /// Follow step: meta line under a name
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 mutual friend} other{{n} mutual friends}}'**
  String mutualFriends(int n);

  /// Follow step: meta line under a name
  ///
  /// In en, this message translates to:
  /// **'Lives in {city}'**
  String livesIn(String city);

  /// Follow step: hint under Continue
  ///
  /// In en, this message translates to:
  /// **'Follow at least 3 people for a better feed'**
  String get followHint;

  /// Follow step: an empty tab
  ///
  /// In en, this message translates to:
  /// **'No suggestions yet'**
  String get noSuggestions;

  /// Follow step: shown when a tab could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load people'**
  String get followError;

  /// Leave dialog: title
  ///
  /// In en, this message translates to:
  /// **'Leave sign-up?'**
  String get leaveTitle;

  /// Leave dialog: body
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved. You can pick up where you left off the next time you sign in.'**
  String get leaveBody;

  /// Leave dialog: stays in sign-up
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// Leave dialog: leaves sign-up
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Set new password screen: title
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get resetTitle;

  /// Set new password screen: subtitle; {email} is the masked address, set in bold
  ///
  /// In en, this message translates to:
  /// **'For {email}. Use something you haven\'t used on Pulse before.'**
  String resetSubtitle(String email);

  /// Set new password screen: field label
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// Password rule
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get ruleLength;

  /// Password rule
  ///
  /// In en, this message translates to:
  /// **'Contains a number'**
  String get ruleNumber;

  /// Password rule
  ///
  /// In en, this message translates to:
  /// **'Upper and lower case letters'**
  String get ruleCase;

  /// Set new password screen: field label
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmLabel;

  /// Set new password screen: field hint
  ///
  /// In en, this message translates to:
  /// **'Type it again'**
  String get confirmHint;

  /// Set new password screen: checkbox
  ///
  /// In en, this message translates to:
  /// **'Log out of all other devices'**
  String get logoutOthers;

  /// Set new password screen: primary button
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// Shown under the confirm field
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get errorMismatch;

  /// Set new password screen: title when the reset link is no longer valid
  ///
  /// In en, this message translates to:
  /// **'This link has expired'**
  String get linkExpiredTitle;

  /// Set new password screen: body when the reset link is no longer valid
  ///
  /// In en, this message translates to:
  /// **'Request a new link to reset your password.'**
  String get linkExpiredBody;

  /// Set new password screen: opens Forgot password
  ///
  /// In en, this message translates to:
  /// **'Request a new link'**
  String get requestNewLink;

  /// Password updated dialog: title
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get updatedTitle;

  /// Password updated dialog: body when other devices were logged out
  ///
  /// In en, this message translates to:
  /// **'You can now sign in with your new password. Other devices have been logged out.'**
  String get updatedBodyOthers;

  /// Password updated dialog: body
  ///
  /// In en, this message translates to:
  /// **'You can now sign in with your new password.'**
  String get updatedBody;

  /// Screen-reader label of an X button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
