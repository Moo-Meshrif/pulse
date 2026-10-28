import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/settings/settings_cubit.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/settings_cubit_rows.dart';

/// The Settings home: three groups of rows, Log out, Delete account and the version.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _confirmLogOut(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<SettingsCubit>();
    final confirmed = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.logout,
      title: l10n.settingsLogOutTitle,
      message: l10n.settingsLogOutBody,
      confirmLabel: l10n.settingsLogOut,
      cancelLabel: l10n.cancel,
    );
    if (confirmed == true) await cubit.logOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final cubit = context.read<SettingsCubit>();
    final bottom = NavClearance.of(context) + AppSpacing.s32;
    return AppPage(
      backgroundColor: colors.background,
      title: l10n.settingsTitle,
      bottomSpace: bottom,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsGroup(
              label: l10n.settingsAccount,
              children: [
                SettingsRow(
                  icon: AppAssets.user,
                  title: l10n.settingsPersonalInfo,
                  onTap: () => AppNavigator.push(
                    context,
                    AppRoutes.settingsPersonalInfo,
                  ),
                ),
                SettingsRow(
                  icon: AppAssets.lock,
                  title: l10n.settingsPasswordSecurity,
                  onTap: () =>
                      AppNavigator.push(context, AppRoutes.settingsSecurity),
                ),
                const SettingsPrivacyRow(),
                const SettingsBlockedRow(),
              ],
            ),
            SettingsGroup(
              label: l10n.settingsPreferences,
              children: [
                const SettingsNotificationsRow(),
                SettingsRow(
                  icon: AppAssets.globe,
                  title: l10n.settingsLanguage,
                  value: Localizations.localeOf(context).languageCode == 'ar'
                      ? l10n.settingsLanguageArabic
                      : l10n.settingsLanguageEnglish,
                  onTap: () =>
                      AppNavigator.push(context, AppRoutes.settingsLanguage),
                ),
                const SettingsAutoplayRow(),
                const SettingsDataSaverRow(),
                SwitchRow(
                  title: l10n.settingsDarkMode,
                  subtitle: l10n.settingsDarkModeSub,
                  value: false,
                  onChanged: null,
                  // TODO(profile-plan T5): dark mode needs a dark theme
                  onDisabledTap: () => Notices.info(l10n.settingsDarkModeSoon),
                ),
              ],
            ),
            SettingsGroup(
              label: l10n.settingsSupport,
              children: [
                SettingsRow(
                  icon: AppAssets.help,
                  title: l10n.settingsHelp,
                  onTap: () =>
                      AppNavigator.push(context, AppRoutes.settingsHelp),
                ),
                SettingsRow(
                  icon: AppAssets.flag,
                  title: l10n.settingsReport,
                  onTap: () =>
                      AppNavigator.push(context, AppRoutes.settingsReport),
                ),
                SettingsRow(
                  icon: AppAssets.document,
                  title: l10n.settingsTerms,
                  onTap: () =>
                      AppNavigator.push(context, AppRoutes.settingsTerms),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s24),
            DangerButtonCard(
              icon: AppAssets.logout,
              label: l10n.settingsLogOut,
              onPressed: () => _confirmLogOut(context),
            ),
            TextButton(
              onPressed: () => DeleteAccountDialog.show(context, cubit),
              child: AppText(
                l10n.settingsDelete,
                style: context.text.button,
                color: colors.textSecondary,
              ),
            ),
            const SettingsVersionLine(),
          ],
        ),
      ),
    );
  }
}
