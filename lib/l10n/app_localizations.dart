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

  /// No description provided for @communityGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Community guidelines'**
  String get communityGuidelines;

  /// No description provided for @cookiePolicy.
  ///
  /// In en, this message translates to:
  /// **'Cookie policy'**
  String get cookiePolicy;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

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

  /// Splash: title when a network is on but the backend cannot be reached
  ///
  /// In en, this message translates to:
  /// **'No internet'**
  String get noInternetTitle;

  /// Splash: body of the no-internet screen
  ///
  /// In en, this message translates to:
  /// **'You\'re connected to a network, but it has no internet.'**
  String get noInternetBody;

  /// Splash: title when the backend answers too slowly
  ///
  /// In en, this message translates to:
  /// **'Weak connection'**
  String get weakConnectionTitle;

  /// Splash: body of the weak-connection screen
  ///
  /// In en, this message translates to:
  /// **'Your connection is too slow. Try again in a moment.'**
  String get weakConnectionBody;

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

  /// Snackbar: the server rejected the new password as too weak
  ///
  /// In en, this message translates to:
  /// **'That password is too weak. Use a longer one with letters, numbers and symbols.'**
  String get errorWeakPassword;

  /// Snackbar: the new password equals the current one
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from the old one.'**
  String get errorSamePassword;

  /// Snackbar: the reset session is missing or expired
  ///
  /// In en, this message translates to:
  /// **'This link has expired. Request a new one and try again.'**
  String get errorSessionExpired;

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
  /// **'If an account exists for {email}, we sent a reset link. Open it to set a new password.'**
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
  /// **'••• ••• ••••'**
  String get phoneHint;

  /// Photo sheet / country picker
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get photoSheetTitle;

  /// Photo sheet / country picker
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get countryPickerTitle;

  /// Photo sheet / country picker
  ///
  /// In en, this message translates to:
  /// **'Search country or code'**
  String get countrySearchHint;

  /// Photo sheet / country picker
  ///
  /// In en, this message translates to:
  /// **'No country found'**
  String get countryNoResults;

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

  /// Follow button once a follow request to a private profile is sent
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// Requested button's screen-reader label
  ///
  /// In en, this message translates to:
  /// **'Cancel follow request to {name}'**
  String cancelRequestPerson(String name);

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

  /// Skip dialog on an optional sign-up step with entries: title
  ///
  /// In en, this message translates to:
  /// **'Skip this step?'**
  String get skipStepTitle;

  /// Skip dialog: body
  ///
  /// In en, this message translates to:
  /// **'What you entered on this step will be cleared and not saved.'**
  String get skipStepBody;

  /// Skip dialog: stays on the step
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

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

  /// Snackbar when an emailed reset link is opened but is no longer valid
  ///
  /// In en, this message translates to:
  /// **'This link has expired. Request a new one to reset your password.'**
  String get linkExpiredSnackBar;

  /// Sign in subtitle after a session ended and the account is known
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue.'**
  String get signedOutSubtitle;

  /// Sign in banner title after a session ended
  ///
  /// In en, this message translates to:
  /// **'You\'ve been signed out'**
  String get signedOutTitle;

  /// Sign in banner body when the session ran out
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again to pick up where you left off.'**
  String get signedOutExpiredBody;

  /// Sign in banner body when the session was ended elsewhere
  ///
  /// In en, this message translates to:
  /// **'Your session was ended on another device or after a password change. Sign in again to keep going.'**
  String get signedOutRevokedBody;

  /// Sign in: label above the saved account card
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// Sign in: forgets the saved account and shows the normal form
  ///
  /// In en, this message translates to:
  /// **'Not you?'**
  String get notYou;

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

  /// Empty page: title of the generic failure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get failedPageTitle;

  /// Empty page: body of the generic failure
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this page. It\'s not you — please try again.'**
  String get failedPageBody;

  /// Empty page: link that leaves to the Home tab
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// Empty page: title for a broken link or removed content
  ///
  /// In en, this message translates to:
  /// **'This page isn\'t available'**
  String get notFoundPageTitle;

  /// Empty page: body for a broken link or removed content
  ///
  /// In en, this message translates to:
  /// **'The link may be broken, or the content was removed.'**
  String get notFoundPageBody;

  /// Empty page: title when the connection is lost
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlinePageTitle;

  /// Empty page: body when the connection is lost
  ///
  /// In en, this message translates to:
  /// **'Connect to Wi-Fi or mobile data. We\'ll reload as soon as you\'re back.'**
  String get offlinePageBody;

  /// Bottom nav: Home tab (screen-reader label, the bar has no visible text)
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav: Shorts tab (screen-reader label)
  ///
  /// In en, this message translates to:
  /// **'Shorts'**
  String get navShorts;

  /// Bottom nav: Create button (screen-reader label)
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// Bottom nav: Chat tab (screen-reader label)
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// Bottom nav: Profile tab (screen-reader label)
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom nav: unread count announced on the Chat tab
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String navUnread(int count);

  /// Create sheet: title
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createTitle;

  /// Create sheet: Post option title
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get createPost;

  /// Create sheet: Post option description
  ///
  /// In en, this message translates to:
  /// **'Share photos, videos or text in your feed'**
  String get createPostSub;

  /// Create sheet: Short option title
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get createShort;

  /// Create sheet: Short option description
  ///
  /// In en, this message translates to:
  /// **'Record or upload a vertical video, up to 60s'**
  String get createShortSub;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Nudity or sexual content'**
  String get reportReasonNudity;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Hate speech or symbols'**
  String get reportReasonHate;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Bullying or harassment'**
  String get reportReasonBullying;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Violence or dangerous acts'**
  String get reportReasonViolence;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'False information'**
  String get reportReasonFalseInfo;

  /// Report reason that opens the note step
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonOther;

  /// Report note step title
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportElseTitle;

  /// Report note step body
  ///
  /// In en, this message translates to:
  /// **'Describe the problem in a few words. Your report is anonymous.'**
  String get reportElseBody;

  /// Report note step button
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSend;

  /// Report sent step title
  ///
  /// In en, this message translates to:
  /// **'Thanks for letting us know'**
  String get reportSentTitle;

  /// Report sent step button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reportDone;

  /// Story report sheet title
  ///
  /// In en, this message translates to:
  /// **'Report story'**
  String get storyReportTitle;

  /// Story report sheet body
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this story? Your report is anonymous.'**
  String get storyReportBody;

  /// Story report sent body [estimated]
  ///
  /// In en, this message translates to:
  /// **'We\'ll review this story.'**
  String get storyReportSent;

  /// Story report note field hint [estimated]
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s wrong with this story…'**
  String get storyReportNotePlaceholder;

  /// Report note counter
  ///
  /// In en, this message translates to:
  /// **'{count} / {max}'**
  String reportNoteCounter(int count, int max);

  /// Snackbar when the device refused access (photo library)
  ///
  /// In en, this message translates to:
  /// **'Pulse doesn\'t have access. Allow it in Settings and try again.'**
  String get errorPermission;

  /// Story viewer reply field hint
  ///
  /// In en, this message translates to:
  /// **'Send a message…'**
  String get storyReplyHint;

  /// Story viewer header name for your own story
  ///
  /// In en, this message translates to:
  /// **'Your story'**
  String get storyYourStory;

  /// Story viewer: your story view count label
  ///
  /// In en, this message translates to:
  /// **'{count} viewers'**
  String storyViewers(int count);

  /// Story viewer: more button label
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get storyMore;

  /// Story viewer: like button label
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get storyLike;

  /// Story viewer: liked button label
  ///
  /// In en, this message translates to:
  /// **'Remove like'**
  String get storyUnlike;

  /// Story viewer: send button label
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get storySend;

  /// Notice when Send is tapped in the story reply bar [estimated]
  ///
  /// In en, this message translates to:
  /// **'Replies are coming soon.'**
  String get storyReplySoon;

  /// Story age under a minute
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get storyAgeNow;

  /// Story age in minutes
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String storyAgeMinutes(int count);

  /// Story age in hours
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String storyAgeHours(int count);

  /// Story age in days
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String storyAgeDays(int count);

  /// Cancel button of a dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button of a dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Notice action that reverses the last change
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Story viewer: chip shown while a sheet or dialog is open
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get storyPaused;

  /// Story options: mute a person's stories
  ///
  /// In en, this message translates to:
  /// **'Mute @{username}'**
  String storyMute(String username);

  /// Story options: mute row subtitle
  ///
  /// In en, this message translates to:
  /// **'Hide their stories from your rail'**
  String get storyMuteHint;

  /// Notice after muting a person's stories
  ///
  /// In en, this message translates to:
  /// **'@{username}\'s stories are hidden'**
  String storyMuted(String username);

  /// Story options: open the author's profile
  ///
  /// In en, this message translates to:
  /// **'Go to profile'**
  String get storyGoToProfile;

  /// Story options: save your story
  ///
  /// In en, this message translates to:
  /// **'Save to device'**
  String get storySaveToDevice;

  /// Notice after saving a story to the device
  ///
  /// In en, this message translates to:
  /// **'Saved to your photos'**
  String get storySaved;

  /// Story options: audience row (read-only for now)
  ///
  /// In en, this message translates to:
  /// **'Who can see this'**
  String get storyWhoCanSee;

  /// Story audience: followers only
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get storyAudienceFollowers;

  /// Story options: viewers row
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get storyViewersItem;

  /// Viewers sheet: empty state
  ///
  /// In en, this message translates to:
  /// **'No one has viewed this story yet'**
  String get storyViewersEmpty;

  /// Story options: delete your story
  ///
  /// In en, this message translates to:
  /// **'Delete story'**
  String get storyDelete;

  /// Delete story dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete this story?'**
  String get storyDeleteTitle;

  /// Delete story dialog body
  ///
  /// In en, this message translates to:
  /// **'It will be removed for everyone, along with its {count} views. You can\'t undo this.'**
  String storyDeleteBody(int count);

  /// Notice after deleting a story
  ///
  /// In en, this message translates to:
  /// **'Story deleted'**
  String get storyDeleted;

  /// Viewers sheet: paging failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more viewers'**
  String get storyViewersLoadFailed;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Allow camera and microphone'**
  String get permAllowTitle;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'To take photos and record stories and shorts with sound.'**
  String get permAllowBody;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get permAllowAccess;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permNotNow;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permCamera;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get permMicrophone;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Needed'**
  String get permNeeded;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get permOff;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permAllowed;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get permCameraOffTitle;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Turn on Camera for Pulse in Settings to take photos and record videos.'**
  String get permCameraOffBody;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Camera access is restricted on this device, so Pulse can\'t use it.'**
  String get permCameraRestrictedBody;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Microphone off · videos will be silent'**
  String get permMicOffPill;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get permFix;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Camera isn\'t available'**
  String get permUnavailableTitle;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Another app may be using it. Close that app, then try again.'**
  String get permUnavailableBody;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get permOpenSettings;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get permChooseGallery;

  /// Camera and microphone permission screens
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get permTryAgain;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get storyCameraTitle;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Tap for photo, hold for video'**
  String get storyHint;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Shutter'**
  String get storyShutter;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get storyFlash;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Flash on'**
  String get storyFlashOn;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Flip camera'**
  String get storyFlipCamera;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get storyGallery;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Recording, {time}'**
  String storyRecordingTime(String time);

  /// Story edit screen: under the trim bar of a video longer than 60 seconds
  ///
  /// In en, this message translates to:
  /// **'Drag to choose the part to share'**
  String get storyTrimHint;

  /// Story camera screen
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t capture. Try again.'**
  String get storyCaptureFailed;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get storyShare;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Your story'**
  String get storyYourStoryPill;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get storyToolText;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get storyToolLocation;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get storyToolMute;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get storyToolUnmute;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Type something…'**
  String get storyTextHint;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get storyTextDone;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Drag here to remove'**
  String get storyRemoveSticker;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Discard this story?'**
  String get storyDiscardTitle;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Your photo or video won\'t be posted.'**
  String get storyDiscardBody;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get storyDiscard;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get storyKeepEditing;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Your last story is still posting. Try again in a moment.'**
  String get storyUploadBusy;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share your story. Try again.'**
  String get storyShareFailed;

  /// Story edit screen
  ///
  /// In en, this message translates to:
  /// **'You can add up to {max} stickers'**
  String storyStickerLimit(int max);

  /// Story rail on the Home tab
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get storyRailTitle;

  /// Story rail on the Home tab
  ///
  /// In en, this message translates to:
  /// **'Posting…'**
  String get storyPosting;

  /// Story rail on the Home tab
  ///
  /// In en, this message translates to:
  /// **'Add to your story'**
  String get storyAddToStory;

  /// Story rail on the Home tab
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load stories'**
  String get storyRailFailed;

  /// Notice on Home: posting a story paused because the connection is lost; it goes on by itself
  ///
  /// In en, this message translates to:
  /// **'No connection. Your story will post when you\'re back online.'**
  String get storyPostOffline;

  /// Story edit screen: shown over the screen while a video is saved to the device
  ///
  /// In en, this message translates to:
  /// **'Saving video… {percent}%'**
  String storySavingVideo(int percent);

  /// Story rail on the Home tab
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post your story'**
  String get storyPostFailed;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Changes apply to this story right away. People who already saw it keep it in their viewers list.'**
  String get storyAudienceBody;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Close friends'**
  String get storyAudienceCloseFriends;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Hide story from'**
  String get storyAudienceHideFrom;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String storyAudiencePeople(int count);

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get storyAudienceEdit;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get storyAudienceDone;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Try again.'**
  String get storyAudienceSaveFailed;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Close friends'**
  String get storyCloseFriendsTitle;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Only you can see this list. People aren\'t told when you add or remove them.'**
  String get storyCloseFriendsHint;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Hide story from'**
  String get storyHiddenTitle;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'These people won\'t see any of your stories. They aren\'t told.'**
  String get storyHiddenHint;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String storyAudienceSelected(int count);

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Search followers'**
  String get storyAudienceSearch;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get storyAudienceTabSuggested;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Selected · {count}'**
  String storyAudienceTabSelected(int count);

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'No followers found'**
  String get storyAudienceEmpty;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your followers'**
  String get storyAudienceLoadFailed;

  /// Story audience: Who can see this and its lists
  ///
  /// In en, this message translates to:
  /// **'Select {name}'**
  String storyAudienceSelectPerson(String name);

  /// Story audience: confirm moving a person between the two lists
  ///
  /// In en, this message translates to:
  /// **'Hide your stories from {name}?'**
  String storyMoveToHiddenTitle(String name);

  /// Story audience: confirm moving a person between the two lists
  ///
  /// In en, this message translates to:
  /// **'{name} is in your Close friends. Hiding your stories from them takes them off that list.'**
  String storyMoveToHiddenBody(String name);

  /// Story audience: confirm moving a person between the two lists
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get storyMoveToHiddenConfirm;

  /// Story audience: confirm moving a person between the two lists
  ///
  /// In en, this message translates to:
  /// **'Add {name} to Close friends?'**
  String storyMoveToCloseTitle(String name);

  /// Story audience: confirm moving a person between the two lists
  ///
  /// In en, this message translates to:
  /// **'{name} is in Hide story from. Adding them to Close friends takes them off that list.'**
  String storyMoveToCloseBody(String name);

  /// Story audience: confirm moving a person between the two lists
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get storyMoveToCloseConfirm;

  /// The caption's expand link
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get postMore;

  /// The caption's collapse link
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get postLess;

  /// Post age under a minute
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get postTimeNow;

  /// Post age in minutes
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String postTimeMinutes(int count);

  /// Post age in hours
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String postTimeHours(int count);

  /// Post age in days
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String postTimeDays(int count);

  /// Post age in weeks
  ///
  /// In en, this message translates to:
  /// **'{count}w'**
  String postTimeWeeks(int count);

  /// Semantics: like button
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get postLike;

  /// Semantics: liked button
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get postUnlike;

  /// Semantics: comment button
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get postComment;

  /// Semantics: share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get postShare;

  /// Semantics: save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get postSave;

  /// Semantics: saved button
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get postUnsave;

  /// Semantics: the ... button
  ///
  /// In en, this message translates to:
  /// **'Post options'**
  String get postOptions;

  /// Semantics: mute a video
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get postMuteVideo;

  /// Semantics: unmute a video
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get postUnmuteVideo;

  /// Semantics: position in a post's media pager
  ///
  /// In en, this message translates to:
  /// **'Photo {number} of {total}'**
  String postMediaCounter(int number, int total);

  /// Semantics: a post picture that failed to load
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load. Tap to retry'**
  String get postMediaRetry;

  /// Options sheet: save tile once saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get postSaved;

  /// Options sheet: copy link tile
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get postCopyLink;

  /// Options sheet: hide this post
  ///
  /// In en, this message translates to:
  /// **'Not interested'**
  String get postNotInterested;

  /// Options sheet: hint under Not interested
  ///
  /// In en, this message translates to:
  /// **'See fewer posts like this'**
  String get postNotInterestedHint;

  /// Options sheet: unfollow the author
  ///
  /// In en, this message translates to:
  /// **'Unfollow @{username}'**
  String postUnfollow(String username);

  /// Options sheet: mute the author's posts
  ///
  /// In en, this message translates to:
  /// **'Mute @{username}'**
  String postMute(String username);

  /// Options sheet: hint under Mute
  ///
  /// In en, this message translates to:
  /// **'Hide their posts without unfollowing'**
  String get postMuteHint;

  /// Report sheet title for a post
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get postReportTitle;

  /// Report sheet reasons step, post
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this post? Your report is anonymous.'**
  String get postReportBody;

  /// Report sheet thanks step, post
  ///
  /// In en, this message translates to:
  /// **'We\'ll review this post. You won\'t see it in your feed anymore.'**
  String get postReportSent;

  /// Report sheet note field hint, post
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s wrong with this post…'**
  String get postReportNotePlaceholder;

  /// Options sheet (own post)
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get postEditPost;

  /// Edit post screen title
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get editPostTitle;

  /// Edit post save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editPostSave;

  /// Notice after saving an edited post
  ///
  /// In en, this message translates to:
  /// **'Post updated'**
  String get postUpdated;

  /// Notice when saving an edited post failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes'**
  String get editPostSaveFailed;

  /// Edit post: confirm leaving with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get editPostDiscardTitle;

  /// Edit post: confirm leaving with unsaved changes
  ///
  /// In en, this message translates to:
  /// **'Your changes to this post won\'t be saved.'**
  String get editPostDiscardBody;

  /// Options sheet (own post)
  ///
  /// In en, this message translates to:
  /// **'Change who can see'**
  String get postChangeWhoCanSee;

  /// Options sheet (own post)
  ///
  /// In en, this message translates to:
  /// **'Turn off comments'**
  String get postCommentsOff;

  /// Options sheet (own post)
  ///
  /// In en, this message translates to:
  /// **'Turn on comments'**
  String get postCommentsOn;

  /// Options sheet (own post)
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get postDelete;

  /// Delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get postDeleteTitle;

  /// Delete dialog body
  ///
  /// In en, this message translates to:
  /// **'It will be removed from your profile and everyone\'s feed. You can\'t undo this.'**
  String get postDeleteBody;

  /// Hidden post row title
  ///
  /// In en, this message translates to:
  /// **'Post hidden'**
  String get postHidden;

  /// Hidden post row hint
  ///
  /// In en, this message translates to:
  /// **'You\'ll see fewer posts like this.'**
  String get postHiddenHint;

  /// Notice after unfollowing
  ///
  /// In en, this message translates to:
  /// **'Unfollowed @{username}'**
  String postUnfollowed(String username);

  /// Notice after muting
  ///
  /// In en, this message translates to:
  /// **'@{username} muted'**
  String postMuted(String username);

  /// Notice after deleting
  ///
  /// In en, this message translates to:
  /// **'Post deleted'**
  String get postDeleted;

  /// New post screen title
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get newPostTitle;

  /// New post caption hint
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get newPostHint;

  /// New post: the add-media tile
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get newPostAdd;

  /// New post section label
  ///
  /// In en, this message translates to:
  /// **'Add to your post'**
  String get newPostAddToPost;

  /// New post option row
  ///
  /// In en, this message translates to:
  /// **'Photo / video'**
  String get newPostPhotoVideo;

  /// New post: how many photos and videos are added
  ///
  /// In en, this message translates to:
  /// **'{count} added'**
  String newPostAdded(int count);

  /// New post option row
  ///
  /// In en, this message translates to:
  /// **'Tag people'**
  String get newPostTag;

  /// New post option row
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get newPostLocation;

  /// New post option row
  ///
  /// In en, this message translates to:
  /// **'Feeling / activity'**
  String get newPostFeeling;

  /// New post option switch
  ///
  /// In en, this message translates to:
  /// **'Allow comments'**
  String get newPostAllowComments;

  /// New post share button
  ///
  /// In en, this message translates to:
  /// **'Share post'**
  String get newPostShare;

  /// Notice after sharing a post
  ///
  /// In en, this message translates to:
  /// **'Post shared'**
  String get newPostShared;

  /// New post close dialog title (something was written)
  ///
  /// In en, this message translates to:
  /// **'Save as draft?'**
  String get newPostDraftTitle;

  /// New post close dialog body
  ///
  /// In en, this message translates to:
  /// **'You can finish it the next time you open New post.'**
  String get newPostDraftBody;

  /// New post close dialog: keep the draft and close
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get newPostSaveDraft;

  /// New post close dialog: delete the draft and close
  ///
  /// In en, this message translates to:
  /// **'Discard post'**
  String get newPostDiscardPost;

  /// Discard dialog: stay
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get newPostKeepEditing;

  /// Discard dialog: leave
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get newPostDiscard;

  /// Notice when sharing fails (Retry action)
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share your post.'**
  String get newPostShareFailed;

  /// Notice: a picked video is too long
  ///
  /// In en, this message translates to:
  /// **'Videos can be up to {minutes} minutes.'**
  String newPostVideoTooLong(int minutes);

  /// Notice: a picked video is too big
  ///
  /// In en, this message translates to:
  /// **'Videos can be up to {megabytes} MB.'**
  String newPostVideoTooBig(int megabytes);

  /// Notice: the media limit
  ///
  /// In en, this message translates to:
  /// **'You can add up to {count} photos and videos.'**
  String newPostMediaLimit(int count);

  /// Semantics: a picked photo or video whose upload failed; a tap tries again
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Tap to retry'**
  String get newPostUploadFailed;

  /// Semantics: remove a picked photo or video
  ///
  /// In en, this message translates to:
  /// **'Remove photo {number}'**
  String newPostRemoveMedia(int number);

  /// Semantics: the caption counter at its limit
  ///
  /// In en, this message translates to:
  /// **'{count} of {max}, limit reached'**
  String newPostCounterAtLimit(int count, int max);

  /// Who can see a post
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get postAudiencePublic;

  /// Who can see a post
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get postAudienceFollowers;

  /// Who can see a post
  ///
  /// In en, this message translates to:
  /// **'Close friends'**
  String get postAudienceCloseFriends;

  /// Who can see a post
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get postAudienceOnlyMe;

  /// Semantics: the visibility chip
  ///
  /// In en, this message translates to:
  /// **'Who can see this post: {choice}'**
  String newPostVisibilityLabel(String choice);

  /// Visibility picker title (New post)
  ///
  /// In en, this message translates to:
  /// **'Who can see this post?'**
  String get postVisibilityTitle;

  /// Visibility picker title (own post)
  ///
  /// In en, this message translates to:
  /// **'Change who can see'**
  String get postVisibilityChangeTitle;

  /// Visibility picker: the audience the post has now
  ///
  /// In en, this message translates to:
  /// **'Currently: {choice}'**
  String postVisibilityCurrently(String choice);

  /// Visibility picker: under Public
  ///
  /// In en, this message translates to:
  /// **'Anyone on or off Pulse'**
  String get postVisibilityPublicHint;

  /// Visibility picker: under Public when the account is private
  ///
  /// In en, this message translates to:
  /// **'Off while your account is private'**
  String get postVisibilityPublicOff;

  /// Visibility picker: under Only me
  ///
  /// In en, this message translates to:
  /// **'Saved to your profile, hidden from everyone'**
  String get postVisibilityOnlyMeHint;

  /// Visibility picker: how many people an audience reaches
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String postVisibilityPeople(int count);

  /// Visibility picker: opens the close friends list
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get postVisibilityEdit;

  /// Visibility picker toggle
  ///
  /// In en, this message translates to:
  /// **'Use for future posts'**
  String get postVisibilityFuture;

  /// Visibility picker: under the toggle
  ///
  /// In en, this message translates to:
  /// **'You can change it in Settings → Privacy'**
  String get postVisibilityFutureHint;

  /// Visibility picker: note for a private account
  ///
  /// In en, this message translates to:
  /// **'Your account is private, so only your followers can see your posts.'**
  String get postVisibilityPrivateNote;

  /// Visibility picker: link in the private note
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get postVisibilityPrivacySettings;

  /// Visibility picker footer when changing a post
  ///
  /// In en, this message translates to:
  /// **'Likes and comments from people who lose access are kept but hidden from them.'**
  String get postVisibilityKeptNote;

  /// Visibility picker button (New post)
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get postVisibilityDone;

  /// Visibility picker button (own post)
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get postVisibilitySave;

  /// Notice after changing who can see a post
  ///
  /// In en, this message translates to:
  /// **'Visibility updated'**
  String get postVisibilityUpdated;

  /// One-time notice after choosing Close friends
  ///
  /// In en, this message translates to:
  /// **'Sharing with close friends'**
  String get postVisibilityNoticeCloseFriendsTitle;

  /// One-time notice body
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person will see this post} other{{count} people will see this post}}'**
  String postVisibilityNoticeCloseFriendsBody(int count);

  /// One-time notice after choosing Only me
  ///
  /// In en, this message translates to:
  /// **'Only you can see this post'**
  String get postVisibilityNoticeOnlyMeTitle;

  /// One-time notice body
  ///
  /// In en, this message translates to:
  /// **'It\'s saved to your profile, hidden from everyone'**
  String get postVisibilityNoticeOnlyMeBody;

  /// Add location screen title
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get locationTitle;

  /// Add location: clear the location
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get locationRemove;

  /// Add location search field hint
  ///
  /// In en, this message translates to:
  /// **'Search places'**
  String get locationSearchHint;

  /// Add location: the row that uses where you are
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get locationUseCurrent;

  /// Add location section
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get locationNearby;

  /// Add location section
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get locationRecent;

  /// Add location section
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get locationResults;

  /// Add location: nothing matches the search
  ///
  /// In en, this message translates to:
  /// **'No places found'**
  String get locationNoResults;

  /// Add location: shown instead of search when offline
  ///
  /// In en, this message translates to:
  /// **'Search needs a connection'**
  String get locationOffline;

  /// Add location: the search failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search. Try again.'**
  String get locationSearchFailed;

  /// Add location permission primer title
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get locationPrimerTitle;

  /// Add location permission primer body
  ///
  /// In en, this message translates to:
  /// **'See places near you when you add a location. Pulse only uses it while you\'re choosing a place.'**
  String get locationPrimerBody;

  /// Add location primer button
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get locationAllow;

  /// Add location primer link
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get locationNotNow;

  /// Add location primer button when location is blocked
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get locationOpenSettings;

  /// Distance in kilometres
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String locationDistance(String km);

  /// Kind of place
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get locationKindCity;

  /// Kind of place
  ///
  /// In en, this message translates to:
  /// **'Town'**
  String get locationKindTown;

  /// Kind of place
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get locationKindNeighborhood;

  /// Semantics: the place already on the post
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get locationSelected;

  /// Semantics: the clear button of the Add location search
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get locationClearSearch;

  /// Home header search button (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearch;

  /// Home header bell button (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get homeActivity;

  /// Home feed empty state title
  ///
  /// In en, this message translates to:
  /// **'Your feed is quiet'**
  String get homeEmptyTitle;

  /// Home feed empty state body
  ///
  /// In en, this message translates to:
  /// **'Follow people to see their posts here.'**
  String get homeEmptyBody;

  /// Home feed empty state button
  ///
  /// In en, this message translates to:
  /// **'Find people'**
  String get homeFindPeople;

  /// Home feed footer when loading the next page failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more · Retry'**
  String get homeLoadMoreError;

  /// Home feed footer at the end of the feed
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get homeCaughtUp;

  /// Pill over the feed when one new post is waiting above what you are reading
  ///
  /// In en, this message translates to:
  /// **'New posts'**
  String get homeNewPosts;

  /// Pill over the feed when 2 to 9 new posts are waiting
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new post} other{{count} new posts}}'**
  String homeNewPostsCount(int count);

  /// Pill over the feed when more than 9 new posts are waiting
  ///
  /// In en, this message translates to:
  /// **'9+ new posts'**
  String get homeNewPostsMany;

  /// Screen reader label of the new posts pill
  ///
  /// In en, this message translates to:
  /// **'Show {count, plural, =1{1 new post} other{{count} new posts}} and scroll to top'**
  String homeNewPostsOpen(int count);

  /// Screen reader label of the round button that scrolls the feed to the top
  ///
  /// In en, this message translates to:
  /// **'Back to top'**
  String get homeBackToTop;

  /// Banner above the feed while a new post is being sent
  ///
  /// In en, this message translates to:
  /// **'Posting…'**
  String get postPublishing;

  /// Banner above the feed while an edited post is being saved
  ///
  /// In en, this message translates to:
  /// **'Saving changes…'**
  String get postPublishSaving;

  /// Banner above the feed when sending a new post failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post'**
  String get postPublishFailed;

  /// Banner action that drops a post that failed to send
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get postPublishDiscard;

  /// Notice when Discard reached the server after the post had already gone out
  ///
  /// In en, this message translates to:
  /// **'Your post was already shared, so it wasn\'t discarded.'**
  String get postDiscardTooLate;

  /// Notice when sharing while another post is still being sent
  ///
  /// In en, this message translates to:
  /// **'You already have 3 posts waiting. Try again when one is out.'**
  String get newPostPublishBusy;

  /// Banner title while several posts are being sent
  ///
  /// In en, this message translates to:
  /// **'Posting {count} posts…'**
  String postPublishingMany(int count);

  /// Banner line under the title while several posts are being sent
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done · {percent}%'**
  String postPublishProgress(int done, int total, int percent);

  /// Banner line when every post in the line is out
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String postPublishDoneOf(int done, int total);

  /// Name of a post in the expanded banner list
  ///
  /// In en, this message translates to:
  /// **'Post {n}'**
  String postPublishRowTitle(int n);

  /// Expanded banner row: this post is out
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get postPublishRowPosted;

  /// Expanded banner row: this post waits for the ones before it
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get postPublishRowWaiting;

  /// Banner title when every post in the line is out
  ///
  /// In en, this message translates to:
  /// **'All posted'**
  String get postPublishAllPosted;

  /// Banner title when posts wait for the internet
  ///
  /// In en, this message translates to:
  /// **'Waiting for connection'**
  String get postPublishOffline;

  /// Banner line when posts wait for the internet
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 post paused} other{{count} posts paused}} · resumes automatically'**
  String postPublishOfflineSub(int count);

  /// Banner title when some posts are out and one failed
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} posted'**
  String postPublishSomePosted(int done, int total);

  /// Banner line when posts failed to send
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 post didn\'t upload} other{{count} posts didn\'t upload}}'**
  String postPublishSomeFailed(int count);

  /// Label of the button that opens the list of posts being sent
  ///
  /// In en, this message translates to:
  /// **'Show all posts'**
  String get postPublishShowAll;

  /// Label of the button that closes the list of posts being sent
  ///
  /// In en, this message translates to:
  /// **'Hide the list'**
  String get postPublishHideAll;

  /// Post headline: the signed-in author
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get postHeadlineYou;

  /// Post headline: the author feeling something; Arabic uses a noun, no verb
  ///
  /// In en, this message translates to:
  /// **'is feeling {emoji}{word}'**
  String postHeadlineFeeling(String emoji, String word);

  /// Post headline: before the tagged people
  ///
  /// In en, this message translates to:
  /// **'with '**
  String get postHeadlineWith;

  /// Post headline: between the tagged people
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get postHeadlineAnd;

  /// Post headline: how many more people are tagged
  ///
  /// In en, this message translates to:
  /// **'{count} others'**
  String postHeadlineOthers(int count);

  /// Screen reader label of the framed post inside a share
  ///
  /// In en, this message translates to:
  /// **'Shared post by {name}'**
  String postSharedSemantics(String name);

  /// Title of the tile that replaces a shared post you can't see
  ///
  /// In en, this message translates to:
  /// **'This post isn\'t available'**
  String get postUnavailableTitle;

  /// Body of the tile that replaces a shared post you can't see
  ///
  /// In en, this message translates to:
  /// **'It was deleted, or its audience changed and you can\'t see it.'**
  String get postUnavailableBody;

  /// Screen reader label of the tile that replaces a shared post you can't see
  ///
  /// In en, this message translates to:
  /// **'Post unavailable'**
  String get postUnavailableSemantics;

  /// Title of the share sheet
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTitle;

  /// Hint of the words field in the share sheet
  ///
  /// In en, this message translates to:
  /// **'Say something about this...'**
  String get shareFieldHint;

  /// Screen reader label of the tag people tool in the share sheet
  ///
  /// In en, this message translates to:
  /// **'Tag people'**
  String get shareTagPeople;

  /// Screen reader label of the feeling tool in the share sheet
  ///
  /// In en, this message translates to:
  /// **'Feeling'**
  String get shareFeeling;

  /// Screen reader label of the location tool in the share sheet
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get shareLocation;

  /// Button that shares the post to your feed
  ///
  /// In en, this message translates to:
  /// **'Share now'**
  String get shareNow;

  /// Characters written in the share words field
  ///
  /// In en, this message translates to:
  /// **'{count} / 2000'**
  String shareCounter(int count);

  /// Share sheet: put the post on your story
  ///
  /// In en, this message translates to:
  /// **'Add to story'**
  String get shareAddToStory;

  /// Share sheet: copy the post link
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get shareCopyLink;

  /// Share sheet: send the post with WhatsApp
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// Share sheet: other apps
  ///
  /// In en, this message translates to:
  /// **'More...'**
  String get shareMore;

  /// Notice after a post was shared to your feed
  ///
  /// In en, this message translates to:
  /// **'Shared to your feed'**
  String get sharedToFeedTitle;

  /// Notice line when the share is public
  ///
  /// In en, this message translates to:
  /// **'Everyone can see it now.'**
  String get sharedToFeedPublic;

  /// Notice line when the share is for followers
  ///
  /// In en, this message translates to:
  /// **'Your followers can see it now.'**
  String get sharedToFeedFollowers;

  /// Notice line when the share is for close friends
  ///
  /// In en, this message translates to:
  /// **'Your close friends can see it now.'**
  String get sharedToFeedCloseFriends;

  /// Notice line when the share is only for you
  ///
  /// In en, this message translates to:
  /// **'Only you can see it.'**
  String get sharedToFeedOnlyMe;

  /// Notice action that shows the new share at the top of the feed
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get sharedToFeedView;

  /// Notice when sharing failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share. Try again.'**
  String get shareFailed;

  /// Notice when the comment button of a post with comments off is tapped
  ///
  /// In en, this message translates to:
  /// **'Comments are off'**
  String get postCommentsOffTitle;

  /// Notice body
  ///
  /// In en, this message translates to:
  /// **'{name} turned off comments for this post.'**
  String postCommentsOffNotice(String name);

  /// Line under the action bar of a post with comments off
  ///
  /// In en, this message translates to:
  /// **'Comments are turned off'**
  String get postCommentsOffLine;

  /// Options sheet hint on Turn on comments
  ///
  /// In en, this message translates to:
  /// **'Comments are off for this post'**
  String get postCommentsOffHint;

  /// Options sheet hint on Edit post
  ///
  /// In en, this message translates to:
  /// **'Caption, feeling, location, tags'**
  String get postEditHint;

  /// A feeling a post can show (happy)
  ///
  /// In en, this message translates to:
  /// **'happy'**
  String get postFeelingHappy;

  /// A feeling a post can show (excited)
  ///
  /// In en, this message translates to:
  /// **'excited'**
  String get postFeelingExcited;

  /// A feeling a post can show (loved)
  ///
  /// In en, this message translates to:
  /// **'loved'**
  String get postFeelingLoved;

  /// A feeling a post can show (relaxed)
  ///
  /// In en, this message translates to:
  /// **'relaxed'**
  String get postFeelingRelaxed;

  /// A feeling a post can show (grateful)
  ///
  /// In en, this message translates to:
  /// **'grateful'**
  String get postFeelingGrateful;

  /// A feeling a post can show (motivated)
  ///
  /// In en, this message translates to:
  /// **'motivated'**
  String get postFeelingMotivated;

  /// A feeling a post can show (cool)
  ///
  /// In en, this message translates to:
  /// **'cool'**
  String get postFeelingCool;

  /// A feeling a post can show (amazed)
  ///
  /// In en, this message translates to:
  /// **'amazed'**
  String get postFeelingAmazed;

  /// A feeling a post can show (tired)
  ///
  /// In en, this message translates to:
  /// **'tired'**
  String get postFeelingTired;

  /// A feeling a post can show (sad)
  ///
  /// In en, this message translates to:
  /// **'sad'**
  String get postFeelingSad;

  /// A feeling a post can show (determined)
  ///
  /// In en, this message translates to:
  /// **'determined'**
  String get postFeelingDetermined;

  /// A feeling a post can show (sick)
  ///
  /// In en, this message translates to:
  /// **'sick'**
  String get postFeelingSick;

  /// A feeling a post can show (funny)
  ///
  /// In en, this message translates to:
  /// **'funny'**
  String get postFeelingFunny;

  /// A feeling a post can show (blessed)
  ///
  /// In en, this message translates to:
  /// **'blessed'**
  String get postFeelingBlessed;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'You\'re tagged in this post'**
  String get postTagYoureTagged;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Remove me from this post'**
  String get postTagRemoveMe;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'You won\'t be tagged anymore'**
  String get postTagRemoveMeHint;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Remove tag'**
  String get postTagRemoveLabel;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Remove your tag?'**
  String get postTagRemoveTitle;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'You\'ll no longer be tagged in {name}\'s post or its photos. The post itself stays.'**
  String postTagRemoveBody(String name);

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get postTagRemoveConfirm;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Tag removed'**
  String get postTagRemoved;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'You\'re no longer tagged in this post.'**
  String get postTagRemovedBody;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove your tag'**
  String get postTagRemoveError;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Tagged people'**
  String get postTaggedPeopleTitle;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get postTaggedFollow;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get postTaggedFollowing;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get postTaggedRequested;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load people'**
  String get postTaggedLoadError;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'People tagged in this photo'**
  String get postTagBadge;

  /// Post tags (S10, S11)
  ///
  /// In en, this message translates to:
  /// **'{name}, {state}'**
  String postTaggedPerson(String name, String state);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Tag people'**
  String get postTagPeopleTitle;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get postTagPeopleSearch;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get postTagPeopleClear;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get postTagPeopleSuggested;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get postTagPeopleDone;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t allow tags'**
  String get postTagPeopleNoTags;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'You can tag up to {max} people'**
  String postTagPeopleMax(int max);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'No people found'**
  String get postTagPeopleEmpty;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Tag in photo'**
  String get postTagPeopleInPhoto;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load people. Retry'**
  String get postTagPeopleError;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'{count} / {max}'**
  String postTagPeopleCounter(int count, int max);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String postTagPeopleRemoveChip(String name);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'{name}, tagged'**
  String postTagPersonTagged(String name);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'{name}, not tagged'**
  String postTagPersonNotTagged(String name);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Tag in photo'**
  String get postTagInPhotoTitle;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Tap where someone is, then pick them. Drag a label to move it.'**
  String get postTagInPhotoHint;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'{name} tagged in the post, not in a photo'**
  String postTagInPhotoNoSpot(String name);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'{count} people tagged in the post, not in a photo'**
  String postTagInPhotoNoSpotMany(int count);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Everyone is placed'**
  String get postTagInPhotoAllPlaced;

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Tag {name}, drag to move'**
  String postTagInPhotoLabel(String name);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Remove {name}\'s spot'**
  String postTagInPhotoRemoveSpot(String name);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'Photo {number}, {count} tagged'**
  String postTagInPhotoThumb(int number, int count);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'{a}, {b}'**
  String postTagValueTwo(String a, String b);

  /// Tag people (S6) and Tag in photo (S7)
  ///
  /// In en, this message translates to:
  /// **'{a}, {b} and {count, plural, =1{1 other} other{{count} others}}'**
  String postTagValueMore(String a, String b, int count);

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get postFeelingTitle;

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get postFeelingRemove;

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'Feelings'**
  String get postFeelingTabFeelings;

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get postFeelingTabActivities;

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'Search feelings'**
  String get postFeelingSearch;

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get postFeelingClear;

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get postFeelingNoMatches;

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'{word}, selected'**
  String postFeelingSelected(String word);

  /// Feeling page (S8) and the New post feeling row
  ///
  /// In en, this message translates to:
  /// **'{emoji}feeling {word}'**
  String postFeelingValue(String emoji, String word);

  /// Story editor for a post
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get storyToolBackground;

  /// Story editor for a post
  ///
  /// In en, this message translates to:
  /// **'Tap the post to change its style · pinch to resize'**
  String get storyPostStickerHint;

  /// Story editor for a post
  ///
  /// In en, this message translates to:
  /// **'Background {number}'**
  String storyBackgroundOption(int number);

  /// Story editor for a post
  ///
  /// In en, this message translates to:
  /// **'Post by {username}: {caption}'**
  String storyPostSemantics(String username, String caption);

  /// Story editor for a post
  ///
  /// In en, this message translates to:
  /// **'Post by {username}'**
  String storyPostSemanticsNoCaption(String username);

  /// Pill under a post sticker in the story viewer
  ///
  /// In en, this message translates to:
  /// **'View post'**
  String get storyViewPost;

  /// Card that replaces a story's post sticker when the post is gone
  ///
  /// In en, this message translates to:
  /// **'Post unavailable'**
  String get storyPostUnavailableTitle;

  /// Under the Post unavailable title
  ///
  /// In en, this message translates to:
  /// **'It was deleted, or you can\'t see it.'**
  String get storyPostUnavailableBody;

  /// Comments sheet title
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// Comments sort option
  ///
  /// In en, this message translates to:
  /// **'Most relevant'**
  String get commentsSortRelevant;

  /// Comments sort option
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get commentsSortNewest;

  /// Semantics: sort chip of the comments sheet
  ///
  /// In en, this message translates to:
  /// **'Sort comments'**
  String get commentsSortLabel;

  /// Badge on a comment by the post's author
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get commentsAuthorBadge;

  /// Reply link under a comment
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get commentReply;

  /// Likes under a comment
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 like} other{{count} likes}}'**
  String commentLikes(int count);

  /// Line that loads the rest of a thread
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{View 1 more reply} other{View {count} more replies}}'**
  String commentsViewMoreReplies(int count);

  /// After the time of an edited comment
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get commentsEdited;

  /// Semantics: a comment row
  ///
  /// In en, this message translates to:
  /// **'Comment by {name}'**
  String commentBy(String name);

  /// Comments sheet with no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get commentsEmptyTitle;

  /// Under No comments yet
  ///
  /// In en, this message translates to:
  /// **'Start the conversation.'**
  String get commentsEmptyBody;

  /// Comments sheet footer when a page or replies failed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more · Retry'**
  String get commentsLoadMoreFailed;

  /// Comment field hint
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get commentsAddHint;

  /// Strip above the comment field; name is the @username
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String commentsReplyingTo(String name);

  /// Semantics: the X on the replying strip
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get commentsReplyCancel;

  /// Semantics: the list of people suggested while typing @ in a comment
  ///
  /// In en, this message translates to:
  /// **'People to mention'**
  String get commentsMentionSuggestions;

  /// Semantics: the send button of the comment field
  ///
  /// In en, this message translates to:
  /// **'Send comment'**
  String get commentsSend;

  /// Under your comment while it is being sent
  ///
  /// In en, this message translates to:
  /// **'Posting…'**
  String get commentsPosting;

  /// Start of the failed line under your comment
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t post'**
  String get commentsCouldntPost;

  /// Failed comment: send it again
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commentsRetry;

  /// Failed comment: drop it
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commentsDelete;

  /// Character counter of the comment field
  ///
  /// In en, this message translates to:
  /// **'{count} / 1000'**
  String commentsCounter(int count);

  /// Bar that replaces the comment field
  ///
  /// In en, this message translates to:
  /// **'Comments are turned off for this post'**
  String get commentsOff;

  /// Strip above the comment field while editing
  ///
  /// In en, this message translates to:
  /// **'Editing comment'**
  String get commentsEditing;

  /// Semantics: close the editing strip
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get commentsEditCancel;

  /// Comment menu
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get commentsCopyText;

  /// Comment menu, your comment
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commentsEdit;

  /// Comment menu, post owner
  ///
  /// In en, this message translates to:
  /// **'Hide comment'**
  String get commentsHide;

  /// Comment menu, and report sheet title
  ///
  /// In en, this message translates to:
  /// **'Report comment'**
  String get commentsReport;

  /// Delete comment dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete comment?'**
  String get commentsDeleteTitle;

  /// Delete comment dialog body
  ///
  /// In en, this message translates to:
  /// **'This also deletes its replies.'**
  String get commentsDeleteBody;

  /// Notice after hiding a comment
  ///
  /// In en, this message translates to:
  /// **'Comment hidden'**
  String get commentsHidden;

  /// Notice after copying a comment
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get commentsCopied;

  /// Report sheet reasons step, comment
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this comment? Your report is anonymous.'**
  String get commentsReportBody;

  /// Report sheet thanks step, comment
  ///
  /// In en, this message translates to:
  /// **'We\'ll review this comment.'**
  String get commentsReportSent;

  /// Report sheet note field hint, comment
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s wrong with this comment…'**
  String get commentsReportNotePlaceholder;
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
