import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/reset_password_cubit.dart';
import '../cubit/reset_password_state.dart';
import '../utils/email_mask.dart';
import '../utils/password_policy.dart';
import '../utils/password_rule.dart';
import '../widgets/auth_close_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/icon_tile.dart';
import '../widgets/labeled_checkbox.dart';
import '../widgets/password_rules_list.dart';
import '../widgets/password_strength_meter.dart';

/// Set a new password's UI (docs/specs/auth/screens/s11-set-new-password.md): the form, or the
/// "link expired" message when there is no recovery session. The text controllers are local UI state;
/// each part of the form listens to the Cubit on its own, so typing rebuilds only what depends on it.
class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  ResetPasswordCubit get _cubit => context.read<ResetPasswordCubit>();

  bool _loadingChanged(ResetPasswordState before, ResetPasswordState state) =>
      before.loading != state.loading;

  bool _passwordChanged(ResetPasswordState before, ResetPasswordState state) =>
      before.password != state.password;

  bool _confirmFieldChanged(
    ResetPasswordState before,
    ResetPasswordState state,
  ) => before.loading != state.loading || before.mismatch != state.mismatch;

  bool _logoutOthersChanged(
    ResetPasswordState before,
    ResetPasswordState state,
  ) => before.logoutOthers != state.logoutOthers;

  bool _updateButtonChanged(
    ResetPasswordState before,
    ResetPasswordState state,
  ) => before.loading != state.loading || before.canSubmit != state.canSubmit;

  void _openForgotPassword() =>
      AppNavigator.push(context, AppRoutes.forgotPassword);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppSafeArea(
        bottomSpace: AppSpacing.s24,
        child: ContentWidth(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: AppSpacing.headerSide,
                  start: AppSpacing.headerBackSide,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AuthCloseButton(onPressed: _cubit.leave),
                ),
              ),
              // The recovery email (null: the link expired) is set when the screen opens.
              Expanded(
                child:
                    BlocSelector<
                      ResetPasswordCubit,
                      ResetPasswordState,
                      String?
                    >(
                      selector: (state) => state.email,
                      builder: (context, email) => email == null
                          ? _expired(context)
                          : _form(context, email),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expired(BuildContext context) {
    final l10n = context.l10n;
    return PinnedBottomCta(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.formSide,
          AuthDimens.forgotTileTopGap,
          AppSpacing.formSide,
          AppSpacing.s24,
        ),
        child: AuthHeader(
          leading: const Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconTile(icon: AppAssets.key),
          ),
          title: l10n.linkExpiredTitle,
          subtitle: l10n.linkExpiredBody,
        ),
      ),
      cta: PrimaryButton(
        label: l10n.requestNewLink,
        expand: true,
        onPressed: _openForgotPassword,
      ),
    );
  }

  Widget _form(BuildContext context, String email) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final masked = maskEmail(email);
    return PinnedBottomCta(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.formSide,
          AuthDimens.forgotTileTopGap,
          AppSpacing.formSide,
          AppSpacing.s24,
        ),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                leading: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconTile(icon: AppAssets.key),
                ),
                title: l10n.resetTitle,
                subtitle: l10n.resetSubtitle(masked),
                emphasis: masked,
              ),
              SizedBox(height: AuthDimens.headerToFormGap),
              BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                buildWhen: _loadingChanged,
                builder: (context, state) => AppTextField(
                  label: l10n.newPasswordLabel,
                  hint: l10n.passwordHintMin,
                  controller: _password,
                  isPassword: true,
                  readOnly: state.loading,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: _cubit.passwordChanged,
                  onSubmitted: (_) => _confirmFocus.requestFocus(),
                ),
              ),
              SizedBox(height: AppSpacing.s8),
              BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                buildWhen: _passwordChanged,
                builder: (context, state) =>
                    _passwordFeedback(l10n, state.password),
              ),
              SizedBox(height: AppSpacing.s16),
              BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                buildWhen: _confirmFieldChanged,
                builder: (context, state) => AppTextField(
                  label: l10n.confirmLabel,
                  hint: l10n.confirmHint,
                  controller: _confirm,
                  focusNode: _confirmFocus,
                  isPassword: true,
                  readOnly: state.loading,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: state.mismatch ? l10n.errorMismatch : null,
                  onChanged: _cubit.confirmChanged,
                  onSubmitted: (_) => _cubit.submit(),
                ),
              ),
              SizedBox(height: AppSpacing.s16),
              BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                buildWhen: _logoutOthersChanged,
                builder: (context, state) => LabeledCheckbox(
                  compact: true,
                  checked: state.logoutOthers,
                  onChanged: _cubit.logoutOthersChanged,
                  label: AppText(
                    l10n.logoutOthers,
                    style: context.text.caption,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      cta: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
        buildWhen: _updateButtonChanged,
        builder: (context, state) => PrimaryButton(
          label: l10n.updatePassword,
          expand: true,
          loading: state.loading,
          onPressed: state.canSubmit ? _cubit.submit : null,
        ),
      ),
    );
  }

  /// The strength meter and the three rules under the new-password field.
  Widget _passwordFeedback(AppLocalizations l10n, String password) {
    final rules = [
      PasswordRule(
        label: l10n.ruleLength,
        met: PasswordPolicy.hasMinLength(password),
      ),
      PasswordRule(
        label: l10n.ruleNumber,
        met: PasswordPolicy.hasDigit(password),
      ),
      PasswordRule(
        label: l10n.ruleCase,
        met: PasswordPolicy.hasMixedCase(password),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PasswordStrengthMeter(password: password, compact: true),
        SizedBox(height: AppSpacing.s12),
        PasswordRulesList(rules: rules),
      ],
    );
  }
}
