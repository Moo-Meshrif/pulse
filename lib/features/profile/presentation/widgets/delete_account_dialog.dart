import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/settings/settings_cubit.dart';
import '../cubit/settings/settings_state.dart';

/// Delete account: the warning and a password field. A wrong password shows under the field and the
/// dialog stays; success leaves to Sign in, which also removes it.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  /// Shows the dialog over the app. It sits on the root Navigator, outside the screen's provider, so
  /// the screen's [cubit] is handed in.
  static Future<void> show(BuildContext context, SettingsCubit cubit) =>
      AppDialogShell.show<void>(
        context,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const DeleteAccountDialog(),
        ),
      );

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() => context.read<SettingsCubit>().deleteAccount(_password.text);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    return AppDialogShell(
      semanticLabel: l10n.settingsDeleteTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            l10n.settingsDeleteTitle,
            style: context.text.titleSm,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DialogDimens.titleToMessageGap),
          AppText(
            l10n.settingsDeleteBody,
            style: context.text.bodySm,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DialogDimens.messageToActionsGap),
          BlocSelector<SettingsCubit, SettingsState, bool>(
            selector: (state) => state.passwordWrong,
            builder: (context, wrong) => AppTextField(
              label: l10n.settingsDeletePasswordLabel,
              hint: l10n.settingsDeletePasswordHint,
              controller: _password,
              isPassword: true,
              autofocus: true,
              textInputAction: TextInputAction.done,
              errorText: wrong ? l10n.settingsDeleteWrongPassword : null,
              onChanged: (_) => context.read<SettingsCubit>().passwordEdited(),
              onSubmitted: (_) => _submit(),
            ),
          ),
          SizedBox(height: DialogDimens.messageToActionsGap),
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (before, now) => before.isDeleting != now.isDeleting,
            builder: (context, state) => Row(
              spacing: DialogDimens.actionGap,
              children: [
                Expanded(
                  child: PillButton.soft(
                    label: l10n.cancel,
                    onPressed: state.isDeleting
                        ? null
                        : () => AppNavigator.back(context),
                  ),
                ),
                Expanded(
                  child: PillButton.danger(
                    label: l10n.settingsDelete,
                    onPressed: state.isDeleting ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
