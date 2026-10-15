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
  String get communityGuidelines => 'Community guidelines';

  @override
  String get cookiePolicy => 'Cookie policy';

  @override
  String get openSourceLicenses => 'Open-source licenses';

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
  String get noInternetTitle => 'No internet';

  @override
  String get noInternetBody =>
      'You\'re connected to a network, but it has no internet.';

  @override
  String get weakConnectionTitle => 'Weak connection';

  @override
  String get weakConnectionBody =>
      'Your connection is too slow. Try again in a moment.';

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
  String get errorWeakPassword =>
      'That password is too weak. Use a longer one with letters, numbers and symbols.';

  @override
  String get errorSamePassword =>
      'Your new password must be different from the old one.';

  @override
  String get errorSessionExpired =>
      'This link has expired. Request a new one and try again.';

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
  String get phoneHint => '••• ••• ••••';

  @override
  String get photoSheetTitle => 'Profile photo';

  @override
  String get countryPickerTitle => 'Select country';

  @override
  String get countrySearchHint => 'Search country or code';

  @override
  String get countryNoResults => 'No country found';

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
  String get requested => 'Requested';

  @override
  String cancelRequestPerson(String name) {
    return 'Cancel follow request to $name';
  }

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
  String get skipStepTitle => 'Skip this step?';

  @override
  String get skipStepBody =>
      'What you entered on this step will be cleared and not saved.';

  @override
  String get keepEditing => 'Keep editing';

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
  String get linkExpiredSnackBar =>
      'This link has expired. Request a new one to reset your password.';

  @override
  String get signedOutSubtitle => 'Enter your password to continue.';

  @override
  String get signedOutTitle => 'You\'ve been signed out';

  @override
  String get signedOutExpiredBody =>
      'Your session expired. Sign in again to pick up where you left off.';

  @override
  String get signedOutRevokedBody =>
      'Your session was ended on another device or after a password change. Sign in again to keep going.';

  @override
  String get accountLabel => 'Account';

  @override
  String get notYou => 'Not you?';

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

  @override
  String get failedPageTitle => 'Something went wrong';

  @override
  String get failedPageBody =>
      'We couldn\'t load this page. It\'s not you — please try again.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get notFoundPageTitle => 'This page isn\'t available';

  @override
  String get notFoundPageBody =>
      'The link may be broken, or the content was removed.';

  @override
  String get offlinePageTitle => 'You\'re offline';

  @override
  String get offlinePageBody =>
      'Connect to Wi-Fi or mobile data. We\'ll reload as soon as you\'re back.';

  @override
  String get navHome => 'Home';

  @override
  String get navShorts => 'Shorts';

  @override
  String get navCreate => 'Create';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String navUnread(int count) {
    return '$count unread';
  }

  @override
  String get createTitle => 'Create';

  @override
  String get createPost => 'Post';

  @override
  String get createPostSub => 'Share photos, videos or text in your feed';

  @override
  String get createShort => 'Short';

  @override
  String get createShortSub => 'Record or upload a vertical video, up to 60s';

  @override
  String get reportReasonSpam => 'Spam';

  @override
  String get reportReasonNudity => 'Nudity or sexual content';

  @override
  String get reportReasonHate => 'Hate speech or symbols';

  @override
  String get reportReasonBullying => 'Bullying or harassment';

  @override
  String get reportReasonViolence => 'Violence or dangerous acts';

  @override
  String get reportReasonFalseInfo => 'False information';

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get reportElseTitle => 'Something else';

  @override
  String get reportElseBody =>
      'Describe the problem in a few words. Your report is anonymous.';

  @override
  String get reportSend => 'Send report';

  @override
  String get reportSentTitle => 'Thanks for letting us know';

  @override
  String get reportDone => 'Done';

  @override
  String get storyReportTitle => 'Report story';

  @override
  String get storyReportBody =>
      'Why are you reporting this story? Your report is anonymous.';

  @override
  String get storyReportSent => 'We\'ll review this story.';

  @override
  String get storyReportNotePlaceholder =>
      'Tell us what\'s wrong with this story…';

  @override
  String reportNoteCounter(int count, int max) {
    return '$count / $max';
  }

  @override
  String get errorPermission =>
      'Pulse doesn\'t have access. Allow it in Settings and try again.';

  @override
  String get storyReplyHint => 'Send a message…';

  @override
  String get storyYourStory => 'Your story';

  @override
  String storyViewers(int count) {
    return '$count viewers';
  }

  @override
  String get storyMore => 'More options';

  @override
  String get storyLike => 'Like';

  @override
  String get storyUnlike => 'Remove like';

  @override
  String get storySend => 'Send';

  @override
  String get storyReplySoon => 'Replies are coming soon.';

  @override
  String get storyAgeNow => 'now';

  @override
  String storyAgeMinutes(int count) {
    return '${count}m';
  }

  @override
  String storyAgeHours(int count) {
    return '${count}h';
  }

  @override
  String storyAgeDays(int count) {
    return '${count}d';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get storyPaused => 'Paused';

  @override
  String storyMute(String username) {
    return 'Mute @$username';
  }

  @override
  String get storyMuteHint => 'Hide their stories from your rail';

  @override
  String storyMuted(String username) {
    return '@$username\'s stories are hidden';
  }

  @override
  String get storyGoToProfile => 'Go to profile';

  @override
  String get storySaveToDevice => 'Save to device';

  @override
  String get storySaved => 'Saved to your photos';

  @override
  String get storyWhoCanSee => 'Who can see this';

  @override
  String get storyAudienceFollowers => 'Followers';

  @override
  String get storyViewersItem => 'Viewers';

  @override
  String get storyViewersEmpty => 'No one has viewed this story yet';

  @override
  String get storyDelete => 'Delete story';

  @override
  String get storyDeleteTitle => 'Delete this story?';

  @override
  String storyDeleteBody(int count) {
    return 'It will be removed for everyone, along with its $count views. You can\'t undo this.';
  }

  @override
  String get storyDeleted => 'Story deleted';

  @override
  String get storyViewersLoadFailed => 'Couldn\'t load more viewers';

  @override
  String get permAllowTitle => 'Allow camera and microphone';

  @override
  String get permAllowBody =>
      'To take photos and record stories and shorts with sound.';

  @override
  String get permAllowAccess => 'Allow access';

  @override
  String get permNotNow => 'Not now';

  @override
  String get permCamera => 'Camera';

  @override
  String get permMicrophone => 'Microphone';

  @override
  String get permNeeded => 'Needed';

  @override
  String get permOff => 'Off';

  @override
  String get permAllowed => 'Allowed';

  @override
  String get permCameraOffTitle => 'Camera access is off';

  @override
  String get permCameraOffBody =>
      'Turn on Camera for Pulse in Settings to take photos and record videos.';

  @override
  String get permCameraRestrictedBody =>
      'Camera access is restricted on this device, so Pulse can\'t use it.';

  @override
  String get permMicOffPill => 'Microphone off · videos will be silent';

  @override
  String get permFix => 'Fix';

  @override
  String get permUnavailableTitle => 'Camera isn\'t available';

  @override
  String get permUnavailableBody =>
      'Another app may be using it. Close that app, then try again.';

  @override
  String get permOpenSettings => 'Open settings';

  @override
  String get permChooseGallery => 'Choose from gallery';

  @override
  String get permTryAgain => 'Try again';

  @override
  String get storyCameraTitle => 'Story';

  @override
  String get storyHint => 'Tap for photo, hold for video';

  @override
  String get storyShutter => 'Shutter';

  @override
  String get storyFlash => 'Flash';

  @override
  String get storyFlashOn => 'Flash on';

  @override
  String get storyFlipCamera => 'Flip camera';

  @override
  String get storyGallery => 'Choose from gallery';

  @override
  String storyRecordingTime(String time) {
    return 'Recording, $time';
  }

  @override
  String get storyVideoTooLong => 'Choose a video of 60 seconds or less';

  @override
  String get storyCaptureFailed => 'Couldn\'t capture. Try again.';

  @override
  String get storyShare => 'Share';

  @override
  String get storyYourStoryPill => 'Your story';

  @override
  String get storyToolText => 'Text';

  @override
  String get storyToolMute => 'Mute';

  @override
  String get storyToolUnmute => 'Unmute';

  @override
  String get storyTextHint => 'Type something…';

  @override
  String get storyTextDone => 'Done';

  @override
  String get storyRemoveSticker => 'Drag here to remove';

  @override
  String get storyDiscardTitle => 'Discard this story?';

  @override
  String get storyDiscardBody => 'Your photo or video won\'t be posted.';

  @override
  String get storyDiscard => 'Discard';

  @override
  String get storyKeepEditing => 'Keep editing';

  @override
  String get storyUploadBusy =>
      'Your last story is still posting. Try again in a moment.';

  @override
  String get storyShareFailed => 'Couldn\'t share your story. Try again.';

  @override
  String storyStickerLimit(int max) {
    return 'You can add up to $max stickers';
  }

  @override
  String get storyRailTitle => 'Stories';

  @override
  String get storyPosting => 'Posting…';

  @override
  String get storyAddToStory => 'Add to your story';

  @override
  String get storyRailFailed => 'Couldn\'t load stories';

  @override
  String get storyPostFailed => 'Couldn\'t post your story';

  @override
  String get storyAudienceBody =>
      'Changes apply to this story right away. People who already saw it keep it in their viewers list.';

  @override
  String get storyAudienceCloseFriends => 'Close friends';

  @override
  String get storyAudienceHideFrom => 'Hide story from';

  @override
  String storyAudiencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get storyAudienceEdit => 'Edit';

  @override
  String get storyAudienceDone => 'Done';

  @override
  String get storyAudienceSaveFailed => 'Couldn\'t save. Try again.';

  @override
  String get storyCloseFriendsTitle => 'Close friends';

  @override
  String get storyCloseFriendsHint =>
      'Only you can see this list. People aren\'t told when you add or remove them.';

  @override
  String get storyHiddenTitle => 'Hide story from';

  @override
  String get storyHiddenHint =>
      'These people won\'t see any of your stories. They aren\'t told.';

  @override
  String storyAudienceSelected(int count) {
    return '$count selected';
  }

  @override
  String get storyAudienceSearch => 'Search followers';

  @override
  String get storyAudienceTabSuggested => 'Suggested';

  @override
  String storyAudienceTabSelected(int count) {
    return 'Selected · $count';
  }

  @override
  String get storyAudienceEmpty => 'No followers found';

  @override
  String get storyAudienceLoadFailed => 'Couldn\'t load your followers';

  @override
  String storyAudienceSelectPerson(String name) {
    return 'Select $name';
  }

  @override
  String storyMoveToHiddenTitle(String name) {
    return 'Hide your stories from $name?';
  }

  @override
  String storyMoveToHiddenBody(String name) {
    return '$name is in your Close friends. Hiding your stories from them takes them off that list.';
  }

  @override
  String get storyMoveToHiddenConfirm => 'Hide';

  @override
  String storyMoveToCloseTitle(String name) {
    return 'Add $name to Close friends?';
  }

  @override
  String storyMoveToCloseBody(String name) {
    return '$name is in Hide story from. Adding them to Close friends takes them off that list.';
  }

  @override
  String get storyMoveToCloseConfirm => 'Add';

  @override
  String get postMore => 'more';

  @override
  String get postLess => 'less';

  @override
  String get postTimeNow => 'now';

  @override
  String postTimeMinutes(int count) {
    return '${count}m';
  }

  @override
  String postTimeHours(int count) {
    return '${count}h';
  }

  @override
  String postTimeDays(int count) {
    return '${count}d';
  }

  @override
  String postTimeWeeks(int count) {
    return '${count}w';
  }

  @override
  String get postLike => 'Like';

  @override
  String get postUnlike => 'Unlike';

  @override
  String get postComment => 'Comment';

  @override
  String get postShare => 'Share';

  @override
  String get postSave => 'Save';

  @override
  String get postUnsave => 'Unsave';

  @override
  String get postOptions => 'Post options';

  @override
  String get postMuteVideo => 'Mute';

  @override
  String get postUnmuteVideo => 'Unmute';

  @override
  String postMediaCounter(int number, int total) {
    return 'Photo $number of $total';
  }

  @override
  String get postMediaRetry => 'Couldn\'t load. Tap to retry';

  @override
  String get postSaved => 'Saved';

  @override
  String get postCopyLink => 'Copy link';

  @override
  String get postNotInterested => 'Not interested';

  @override
  String get postNotInterestedHint => 'See fewer posts like this';

  @override
  String postUnfollow(String username) {
    return 'Unfollow @$username';
  }

  @override
  String postMute(String username) {
    return 'Mute @$username';
  }

  @override
  String get postMuteHint => 'Hide their posts without unfollowing';

  @override
  String get postReportTitle => 'Report post';

  @override
  String get postReportBody =>
      'Why are you reporting this post? Your report is anonymous.';

  @override
  String get postReportSent =>
      'We\'ll review this post. You won\'t see it in your feed anymore.';

  @override
  String get postReportNotePlaceholder =>
      'Tell us what\'s wrong with this post…';

  @override
  String get postEditPost => 'Edit post';

  @override
  String get editPostTitle => 'Edit post';

  @override
  String get editPostSave => 'Save';

  @override
  String get postUpdated => 'Post updated';

  @override
  String get editPostSaveFailed => 'Couldn\'t save your changes';

  @override
  String get editPostDiscardTitle => 'Discard changes?';

  @override
  String get editPostDiscardBody =>
      'Your changes to this post won\'t be saved.';

  @override
  String get postChangeWhoCanSee => 'Change who can see';

  @override
  String get postCommentsOff => 'Turn off comments';

  @override
  String get postCommentsOn => 'Turn on comments';

  @override
  String get postDelete => 'Delete post';

  @override
  String get postDeleteTitle => 'Delete this post?';

  @override
  String get postDeleteBody =>
      'It will be removed from your profile and everyone\'s feed. You can\'t undo this.';

  @override
  String get postHidden => 'Post hidden';

  @override
  String get postHiddenHint => 'You\'ll see fewer posts like this.';

  @override
  String postUnfollowed(String username) {
    return 'Unfollowed @$username';
  }

  @override
  String postMuted(String username) {
    return '@$username muted';
  }

  @override
  String get postDeleted => 'Post deleted';

  @override
  String get newPostTitle => 'New post';

  @override
  String get newPostHint => 'What\'s on your mind?';

  @override
  String get newPostAdd => 'Add';

  @override
  String get newPostAddToPost => 'Add to your post';

  @override
  String get newPostPhotoVideo => 'Photo / video';

  @override
  String newPostAdded(int count) {
    return '$count added';
  }

  @override
  String get newPostTag => 'Tag people';

  @override
  String get newPostLocation => 'Location';

  @override
  String get newPostFeeling => 'Feeling / activity';

  @override
  String get newPostAllowComments => 'Allow comments';

  @override
  String get newPostShare => 'Share post';

  @override
  String get newPostShared => 'Post shared';

  @override
  String get newPostDiscardTitle => 'Discard post?';

  @override
  String get newPostDiscardBody => 'Your post won\'t be saved.';

  @override
  String get newPostKeepEditing => 'Keep editing';

  @override
  String get newPostDiscard => 'Discard';

  @override
  String get newPostShareFailed => 'Couldn\'t share your post.';

  @override
  String newPostVideoTooLong(int minutes) {
    return 'Videos can be up to $minutes minutes.';
  }

  @override
  String newPostVideoTooBig(int megabytes) {
    return 'Videos can be up to $megabytes MB.';
  }

  @override
  String newPostMediaLimit(int count) {
    return 'You can add up to $count photos and videos.';
  }

  @override
  String newPostRemoveMedia(int number) {
    return 'Remove photo $number';
  }

  @override
  String newPostCounterAtLimit(int count, int max) {
    return '$count of $max, limit reached';
  }

  @override
  String get postAudiencePublic => 'Public';

  @override
  String get postAudienceFollowers => 'Followers';

  @override
  String get postAudienceCloseFriends => 'Close friends';

  @override
  String get postAudienceOnlyMe => 'Only me';

  @override
  String newPostVisibilityLabel(String choice) {
    return 'Who can see this post: $choice';
  }

  @override
  String get postVisibilityTitle => 'Who can see this post?';

  @override
  String get postVisibilityChangeTitle => 'Change who can see';

  @override
  String postVisibilityCurrently(String choice) {
    return 'Currently: $choice';
  }

  @override
  String get postVisibilityPublicHint => 'Anyone on or off Pulse';

  @override
  String get postVisibilityPublicOff => 'Off while your account is private';

  @override
  String get postVisibilityOnlyMeHint =>
      'Saved to your profile, hidden from everyone';

  @override
  String postVisibilityPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get postVisibilityEdit => 'Edit';

  @override
  String get postVisibilityFuture => 'Use for future posts';

  @override
  String get postVisibilityFutureHint =>
      'You can change it in Settings → Privacy';

  @override
  String get postVisibilityPrivateNote =>
      'Your account is private, so only your followers can see your posts.';

  @override
  String get postVisibilityPrivacySettings => 'Privacy settings';

  @override
  String get postVisibilityKeptNote =>
      'Likes and comments from people who lose access are kept but hidden from them.';

  @override
  String get postVisibilityDone => 'Done';

  @override
  String get postVisibilitySave => 'Save';

  @override
  String get postVisibilityUpdated => 'Visibility updated';

  @override
  String get postVisibilityNoticeCloseFriendsTitle =>
      'Sharing with close friends';

  @override
  String postVisibilityNoticeCloseFriendsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people will see this post',
      one: '1 person will see this post',
    );
    return '$_temp0';
  }

  @override
  String get postVisibilityNoticeOnlyMeTitle => 'Only you can see this post';

  @override
  String get postVisibilityNoticeOnlyMeBody =>
      'It\'s saved to your profile, hidden from everyone';

  @override
  String get locationTitle => 'Add location';

  @override
  String get locationRemove => 'Remove';

  @override
  String get locationSearchHint => 'Search places';

  @override
  String get locationUseCurrent => 'Use current location';

  @override
  String get locationNearby => 'Nearby';

  @override
  String get locationRecent => 'Recent';

  @override
  String get locationResults => 'Results';

  @override
  String get locationNoResults => 'No places found';

  @override
  String get locationOffline => 'Search needs a connection';

  @override
  String get locationSearchFailed => 'Couldn\'t search. Try again.';

  @override
  String get locationPrimerTitle => 'Allow location access';

  @override
  String get locationPrimerBody =>
      'See places near you when you add a location. Pulse only uses it while you\'re choosing a place.';

  @override
  String get locationAllow => 'Allow location';

  @override
  String get locationNotNow => 'Not now';

  @override
  String get locationOpenSettings => 'Open settings';

  @override
  String locationDistance(String km) {
    return '$km km';
  }

  @override
  String get locationKindCity => 'City';

  @override
  String get locationKindTown => 'Town';

  @override
  String get locationKindNeighborhood => 'Neighborhood';

  @override
  String get locationSelected => 'Selected';

  @override
  String get locationClearSearch => 'Clear search';

  @override
  String get homeSearch => 'Search';

  @override
  String get homeActivity => 'Activity';

  @override
  String get homeEmptyTitle => 'Your feed is quiet';

  @override
  String get homeEmptyBody => 'Follow people to see their posts here.';

  @override
  String get homeFindPeople => 'Find people';

  @override
  String get homeLoadMoreError => 'Couldn\'t load more · Retry';

  @override
  String get homeCaughtUp => 'You\'re all caught up';
}
