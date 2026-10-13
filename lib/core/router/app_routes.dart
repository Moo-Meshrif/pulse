import '../enums/signed_out_reason.dart';

abstract final class AppRoutes {
  /// Start route: resolved by the router to onboarding (first launch) or the splash screen, which picks Sign in, Home or a sign-up step.
  static const root = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';

  /// Sign in after a session ended: names the saved account and says why (S14).
  static String signInWith(SignedOutReason reason) =>
      Uri(path: signIn, queryParameters: {'reason': reason.name}).toString();

  /// Registration step 1 (Account).
  static const register = '/register';

  /// The sign-up flow opened at [step] (3 to 6), to resume it after the app was closed.
  static String registerAt(int step) =>
      Uri(path: register, queryParameters: {'step': '$step'}).toString();

  /// The sign-up flow at the Verify email step (2) for [email], e.g. when a sign-in finds the account
  /// unverified.
  static String verifyEmailAt(String email) => Uri(
    path: register,
    queryParameters: {'step': '2', 'email': email},
  ).toString();
  static const forgotPassword = '/forgot-password';

  /// Set a new password; opened by the emailed recovery link.
  static const resetPassword = '/reset-password';
  static const terms = '/terms';
  static const privacy = '/privacy';
  static const communityGuidelines = '/community-guidelines';
  static const cookiePolicy = '/cookie-policy';
  static const openSourceLicenses = '/open-source-licenses';
  static const home = '/home';

  /// Full-screen create flows pushed over the shell (the Create sheet's Post and Short rows).
  static const createPost = '/create/post';
  static const createShort = '/create/short';
}
