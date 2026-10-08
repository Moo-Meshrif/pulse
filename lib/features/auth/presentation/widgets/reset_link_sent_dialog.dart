import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/utils/format_countdown.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../utils/bold_spans.dart';
import '../utils/email_mask.dart';

/// S9 (docs/specs/auth/screens/s9-forgot-password-sent-dialog.md): "Check your email", shown over
/// Forgot password once the link was sent. Custom content in the shared [AppDialogShell].
abstract final class ResetLinkSentDialog {
  /// The dialog is its own route, above the screen's providers, so it is handed the screen's [cubit]
  /// (the cooldown and the resend live there). "Change email" asks that cubit to focus the field.
  static Future<void> show(
    BuildContext context, {
    required ForgotPasswordCubit cubit,
  }) => AppDialogShell.show<void>(
    context,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _ResetLinkSentBody()),
  );
}

class _ResetLinkSentBody extends StatelessWidget {
  const _ResetLinkSentBody();

  @override
  Widget build(BuildContext context) => const ScaffoldMessenger(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(child: _ResetLinkSentCard()),
    ),
  );
}

class _ResetLinkSentCard extends StatelessWidget {
  const _ResetLinkSentCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (_, state) => state.message != null,
      listener: (context, state) =>
          context.showSnackBar(state.message?.l10n(context)),
      builder: (context, state) {
        final colors = context.appColors;
        final masked = maskEmail(state.email.trim());
        final base = context.text.bodySm.copyWith(color: colors.textSecondary);
        final cubit = context.read<ForgotPasswordCubit>();
        return AppDialogShell(
          semanticLabel: l10n.sentTitle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ExcludeSemantics(
                  child: Container(
                    width: DialogDimens.iconCircle,
                    height: DialogDimens.iconCircle,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: AppSvgIcon(
                      AppAssets.mail,
                      size: DialogDimens.icon,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: DialogDimens.iconToTitleGap),
              Semantics(
                header: true,
                child: AppText(
                  l10n.sentTitle,
                  style: context.text.titleSm,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: DialogDimens.titleToMessageGap),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: base,
                  children: boldSpans(l10n.sentBody(masked), masked, base),
                ),
              ),
              SizedBox(height: DialogDimens.messageToActionsGap),
              PrimaryButton(
                label: l10n.openEmailApp,
                expand: true,
                buttonHeight: AuthButtonDimens.pillHeight,
                onPressed: cubit.openEmailApp,
              ),
              SizedBox(height: DialogDimens.stackedActionGap),
              PillButton.soft(
                label: l10n.backToSignIn,
                onPressed: () =>
                    AppNavigator.resetTo(context, AppRoutes.signIn),
              ),
              SizedBox(height: AuthDimens.linkRowTopGap),
              _FooterLinks(
                state: state,
                onResend: cubit.resend,
                onChangeEmail: () {
                  cubit.editEmail();
                  AppNavigator.back(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// "Didn't get it? **Resend link** · **Change email**". While the cooldown runs, Resend reads "Resend
/// link in 0:30" in grey and does nothing.
class _FooterLinks extends StatelessWidget {
  const _FooterLinks({
    required this.state,
    required this.onResend,
    required this.onChangeEmail,
  });

  final ForgotPasswordState state;
  final VoidCallback onResend;
  final VoidCallback onChangeEmail;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final plain = context.text.bodySm.copyWith(color: colors.textSecondary);
    final link = context.text.bodySm.copyWith(
      fontWeight: FontWeight.w700,
      color: colors.primary,
    );
    final resendLabel = state.cooldown > Duration.zero
        ? l10n.resendLinkIn(formatCountdown(state.cooldown))
        : l10n.resendLink;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AuthDimens.linkRowGap,
      children: [
        Text(l10n.didntGetIt, style: plain),
        _LinkButton(
          label: resendLabel,
          style: state.canResend
              ? link
              : link.copyWith(color: colors.textSecondary),
          onPressed: state.canResend ? onResend : null,
        ),
        Text('·', style: plain),
        _LinkButton(
          label: l10n.changeEmail,
          style: link,
          onPressed: onChangeEmail,
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.style,
    required this.onPressed,
  });

  final String label;
  final TextStyle style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    excludeSemantics: true,
    label: label,
    child: InkWell(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AuthDimens.linkTapHeight),
        child: Center(widthFactor: 1, child: Text(label, style: style)),
      ),
    ),
  );
}
