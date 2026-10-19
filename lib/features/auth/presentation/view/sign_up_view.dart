import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/sign_up/sign_up_cubit.dart';
import '../cubit/sign_up/sign_up_state.dart';
import '../widgets/step_top_bar.dart';
import 'sign_up_about_view.dart';
import 'sign_up_account_view.dart';
import 'sign_up_follow_view.dart';
import 'sign_up_interests_view.dart';
import 'sign_up_profile_view.dart';
import 'sign_up_verify_view.dart';

/// The sign-up flow's UI: the shared step bar over the current step (swapped in place, never swiped).
/// Each step reads the Cubit itself; this shell only follows the step number and the back button.
class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SignUpCubit, SignUpState, int>(
        selector: (state) => state.step,
        builder: (context, step) => PopScope(
          canPop: step == SignUpCubit.firstStep,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleSystemBack(context, step);
          },
          child: AppPage(
            showTopBar: false,
            bottomSpace: AppSpacing.s24,
            child: Column(
              children: [
                _stepTopBar(context, step),
                Expanded(
                  child: BlocSelector<SignUpCubit, SignUpState, bool>(
                    selector: (state) => state.resuming,
                    builder: (context, resuming) =>
                        resuming ? const AppLoadingView() : _stepContent(step),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /// The step bar; "Skip" is on Profile, Interests and Follow and stays visible while a request runs
  /// (it just ignores taps).
  Widget _stepTopBar(BuildContext context, int step) {
    final cubit = context.read<SignUpCubit>();
    return BlocSelector<SignUpCubit, SignUpState, bool>(
      selector: (state) => state.loading,
      builder: (context, loading) => StepTopBar(
        step: step,
        isRequired: step <= SignUpCubit.aboutYouStep,
        onBack: () => _handleArrowBack(context, step),
        showSkip: switch (step) {
          SignUpCubit.profileStep ||
          SignUpCubit.interestsStep ||
          SignUpCubit.followStep => true,
          _ => false,
        },
        onSkip: loading
            ? null
            : switch (step) {
                SignUpCubit.profileStep => () => _skip(
                  context,
                  cubit.skipProfile,
                ),
                SignUpCubit.interestsStep => () => _skip(
                  context,
                  cubit.skipInterests,
                ),
                SignUpCubit.followStep => () => _wait(
                  context,
                  cubit.skipFollow,
                ),
                _ => null,
              },
      ),
    );
  }

  Widget _stepContent(int step) => switch (step) {
    SignUpCubit.firstStep => const SignUpAccountView(),
    SignUpCubit.verifyStep => const SignUpVerifyView(),
    SignUpCubit.aboutYouStep => const SignUpAboutView(),
    SignUpCubit.profileStep => const SignUpProfileView(),
    SignUpCubit.interestsStep => const SignUpInterestsView(),
    _ => const SignUpFollowView(),
  };

  /// The step bar's arrow.
  void _handleArrowBack(BuildContext context, int step) {
    final cubit = context.read<SignUpCubit>();
    switch (step) {
      case SignUpCubit.firstStep:
        _leaveFlow(context);
      case SignUpCubit.verifyStep:
        cubit.backToAccount();
      case SignUpCubit.aboutYouStep:
        _confirmLeave(context, cubit);
      default:
        cubit.backOneStep();
    }
  }

  /// The system back button: from About you on it always asks before leaving.
  void _handleSystemBack(BuildContext context, int step) {
    final cubit = context.read<SignUpCubit>();
    // The overlay sits above the routes, so it cannot stop the system back button itself.
    if (cubit.state.loading) return;
    switch (step) {
      case SignUpCubit.verifyStep:
        cubit.backToAccount();
      case >= SignUpCubit.aboutYouStep:
        _confirmLeave(context, cubit);
      default:
        _leaveFlow(context);
    }
  }

  /// Opened by `resetTo` (onboarding) there is nothing below to return to.
  void _leaveFlow(BuildContext context) => AppNavigator.canBack(context)
      ? AppNavigator.back(context)
      : AppNavigator.resetTo(context, AppRoutes.signIn);

  /// "Skip": a step with entries asks first, since skipping drops them; confirmed, they are cleared here
  /// and erased on the server too.
  Future<void> _skip(
    BuildContext context,
    Future<void> Function({bool discard}) skip,
  ) async {
    final cubit = context.read<SignUpCubit>();
    if (!cubit.skipLosesData) return _wait(context, skip);
    final l10n = context.l10n;
    final confirmed = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.warning,
      title: l10n.skipStepTitle,
      message: l10n.skipStepBody,
      confirmLabel: l10n.skip,
      cancelLabel: l10n.keepEditing,
    );
    if ((confirmed ?? false) && context.mounted) {
      await _wait(context, () => skip(discard: true));
    }
  }

  /// A request the user caused by pressing Skip: the screen frosts over until the response comes.
  Future<void> _wait(BuildContext context, Future<void> Function() task) =>
      runWithLoadingOverlay(context, task);

  /// The leave dialog (S10): progress is saved, so leaving only signs out.
  Future<void> _confirmLeave(BuildContext context, SignUpCubit cubit) async {
    final l10n = context.l10n;
    final leave = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.warning,
      title: l10n.leaveTitle,
      message: l10n.leaveBody,
      confirmLabel: l10n.leave,
      cancelLabel: l10n.keepGoing,
    );
    if (leave ?? false) await cubit.leave();
  }
}
