import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/security/security_cubit.dart';
import '../cubit/security/security_state.dart';
import '../utils/enums/security_notice.dart';

/// The three password fields with Forgot password? and Update. The fields clear once the password changed.
class SecurityPasswordForm extends StatefulWidget {
  const SecurityPasswordForm({super.key});

  @override
  State<SecurityPasswordForm> createState() => _SecurityPasswordFormState();
}

class _SecurityPasswordFormState extends State<SecurityPasswordForm> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _clear() {
    _current.clear();
    _next.clear();
    _confirm.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final cubit = context.read<SecurityCubit>();
    return BlocListener<SecurityCubit, SecurityState>(
      listenWhen: (before, now) =>
          now.notice == SecurityNotice.passwordUpdated &&
          before.notice != now.notice,
      listener: (_, _) => _clear(),
      child: Padding(
        padding: EdgeInsets.all(SettingsDimens.rowSide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s16,
          children: [
            BlocSelector<SecurityCubit, SecurityState, bool>(
              selector: (state) => state.currentWrong,
              builder: (context, wrong) => AppTextField(
                label: l10n.securityCurrentPassword,
                controller: _current,
                isPassword: true,
                fillColor: colors.surfaceMuted,
                textInputAction: TextInputAction.next,
                errorText: wrong ? l10n.securityWrongCurrent : null,
                onChanged: cubit.currentChanged,
              ),
            ),
            AppTextField(
              label: l10n.newPasswordLabel,
              hint: l10n.passwordHintMin,
              controller: _next,
              isPassword: true,
              fillColor: colors.surfaceMuted,
              textInputAction: TextInputAction.next,
              onChanged: cubit.nextChanged,
            ),
            BlocSelector<SecurityCubit, SecurityState, bool>(
              selector: (state) => state.mismatch,
              builder: (context, mismatch) => AppTextField(
                label: l10n.confirmLabel,
                hint: l10n.confirmHint,
                controller: _confirm,
                isPassword: true,
                fillColor: colors.surfaceMuted,
                textInputAction: TextInputAction.done,
                errorText: mismatch ? l10n.errorMismatch : null,
                onChanged: cubit.confirmChanged,
                onSubmitted: (_) => cubit.update(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: cubit.sendReset,
                      child: AppText(
                        l10n.forgotPassword,
                        style: context.text.button,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<SecurityCubit, SecurityState>(
                  buildWhen: (before, now) =>
                      before.canUpdate != now.canUpdate ||
                      before.isUpdating != now.isUpdating,
                  builder: (context, state) => PrimaryButton(
                    label: l10n.securityUpdate,
                    loading: state.isUpdating,
                    horizontalPadding: AppSpacing.s24,
                    onPressed: state.canUpdate ? cubit.update : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
