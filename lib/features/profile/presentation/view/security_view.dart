import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/security/security_cubit.dart';
import '../cubit/security/security_state.dart';
import '../widgets/security_device_row.dart';
import '../widgets/security_password_form.dart';

/// The Password & security page: change password, login protection (coming soon), this device, and
/// Log out of all other devices.
class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  Future<void> _confirmLogOutOthers(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<SecurityCubit>();
    final confirmed = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.logout,
      title: l10n.securityLogOutOthersTitle,
      message: l10n.securityLogOutOthersBody,
      confirmLabel: l10n.settingsLogOut,
      cancelLabel: l10n.cancel,
    );
    if (confirmed == true) await cubit.logOutOthers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = NavClearance.of(context) + AppSpacing.s32;
    // TODO(profile-plan T4): two-factor, login alerts and the device list need server work
    void soon() => Notices.info(l10n.securityComingSoon);
    return AppPage(
      backgroundColor: context.appColors.background,
      title: l10n.settingsPasswordSecurity,
      bottomSpace: bottom,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(bottom: bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsGroup(
              label: l10n.securityChangeSection,
              children: const [SecurityPasswordForm()],
            ),
            SettingsGroup(
              label: l10n.securityLoginProtection,
              children: [
                SwitchRow(
                  title: l10n.securityTwoFactor,
                  subtitle: l10n.securityTwoFactorSub,
                  value: false,
                  onChanged: null,
                  onDisabledTap: soon,
                ),
                SwitchRow(
                  title: l10n.securityLoginAlerts,
                  subtitle: l10n.securityLoginAlertsSub,
                  value: false,
                  onChanged: null,
                  onDisabledTap: soon,
                ),
              ],
            ),
            SettingsGroup(
              label: l10n.securityWhereLoggedIn,
              children: const [SecurityDeviceRow()],
            ),
            SizedBox(height: AppSpacing.s24),
            BlocSelector<SecurityCubit, SecurityState, bool>(
              selector: (state) => state.isLoggingOutOthers,
              builder: (context, busy) => DangerButtonCard(
                label: l10n.logoutOthers,
                onPressed: busy ? () {} : () => _confirmLogOutOthers(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
