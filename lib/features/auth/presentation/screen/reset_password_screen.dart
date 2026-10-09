import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/widgets/confirmation_dialog/confirmation_dialog.dart';
import '../cubit/reset_password_cubit.dart';
import '../cubit/reset_password_state.dart';
import '../view/reset_password_view.dart';

/// `/reset-password`: provides [ResetPasswordCubit], shows the "Password updated" dialog and leaves to
/// Sign in (docs/specs/auth/screens/s11-set-new-password.md, s12-password-updated-dialog.md).
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ResetPasswordCubit>(),
    child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
      listenWhen: _hasRouteOrUpdateOrNewFailure,
      listener: _leaveOrShowUpdatedOrShowFailure,
      child: const ResetPasswordView(),
    ),
  );

  // One-shot effects; typing must not trigger them again.
  bool _hasRouteOrUpdateOrNewFailure(
    ResetPasswordState before,
    ResetPasswordState state,
  ) =>
      state.route != null ||
      (state.updated && !before.updated) ||
      (state.failure != null && state.failure != before.failure);

  void _leaveOrShowUpdatedOrShowFailure(
    BuildContext context,
    ResetPasswordState state,
  ) {
    final route = state.route;
    if (route != null) {
      AppNavigator.resetTo(context, route);
    } else if (state.updated) {
      _showUpdated(
        context,
        context.read<ResetPasswordCubit>(),
        othersLoggedOut: state.othersLoggedOut,
      );
    } else {
      context.showFailure(state.failure);
    }
  }

  /// S12: not dismissible; its only button signs in again.
  Future<void> _showUpdated(
    BuildContext context,
    ResetPasswordCubit cubit, {
    required bool othersLoggedOut,
  }) async {
    final l10n = context.l10n;
    await ConfirmationDialog.info(
      context,
      icon: AppAssets.check,
      title: l10n.updatedTitle,
      message: othersLoggedOut ? l10n.updatedBodyOthers : l10n.updatedBody,
      okLabel: l10n.signIn,
      dismissible: false,
    );
    await cubit.leave();
  }
}
