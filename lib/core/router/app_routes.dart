abstract final class AppRoutes {
  /// Start route: resolved by the router to onboarding (first launch) or the splash screen, which picks Sign in, Home or a sign-up step.
  static const root = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';

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
  static const home = '/home';
}
