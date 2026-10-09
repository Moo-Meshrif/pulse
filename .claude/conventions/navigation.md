# Navigation
Covers: routes, router, start-up decision
Does not cover: state that triggers navigation (state.md)
Rule: built-in Navigator; `lib/core/router/` (`AppRoutes`, `AppRouter.onGenerateRoute`, `AppNavigator`). `/` -> `/onboarding` until `onboarding_seen`, then `SplashScreen` (features/splash) -> `/sign-in`, `/home` or `/register?step=N`. Leave flows with `AppNavigator.resetTo`. `/register[?step=N&email=…]` = `SignUpScreen` (one `SignUpCubit` for the whole flow, steps swapped in `SignUpView`; steps 3-6 About you / Profile / Interests / Follow; system back from step 3 on and the arrow on step 3 open the leave dialog (S10), Leave = clear local profile + sign out + resetTo /sign-in; end of Follow = resetTo /home). `/reset-password` = `ResetPasswordScreen` (no recovery session = "link expired" state). Unbuilt routes use `PlaceholderScreen`; `/terms`, `/privacy` use `LegalPlaceholderScreen`.
Never: routing package, `Navigator.of` / inline MaterialPageRoute in widgets.
Example: lib/core/router/app_router.dart
