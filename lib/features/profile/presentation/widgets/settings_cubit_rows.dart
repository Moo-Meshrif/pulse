import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/settings/settings_cubit.dart';
import '../cubit/settings/settings_state.dart';

class SettingsPrivacyRow extends StatelessWidget {
  const SettingsPrivacyRow({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsCubit, SettingsState, bool?>(
        selector: (state) => state.summary?.isPrivate,
        builder: (context, isPrivate) => SettingsRow(
          icon: AppAssets.eye,
          title: context.l10n.settingsPrivacy,
          value: switch (isPrivate) {
            null => null,
            true => context.l10n.valuePrivate,
            false => context.l10n.valuePublic,
          },
          onTap: () => AppNavigator.push(context, AppRoutes.settingsPrivacy),
        ),
      );
}

class SettingsBlockedRow extends StatelessWidget {
  const SettingsBlockedRow({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsCubit, SettingsState, int?>(
        selector: (state) => state.summary?.blockedCount,
        builder: (context, count) => SettingsRow(
          icon: AppAssets.block,
          title: context.l10n.settingsBlocked,
          value: count?.toString(),
          onTap: () => AppNavigator.push(context, AppRoutes.settingsBlocked),
        ),
      );
}

class SettingsNotificationsRow extends StatelessWidget {
  const SettingsNotificationsRow({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsCubit, SettingsState, bool?>(
        selector: (state) => state.summary?.pushEnabled,
        builder: (context, pushEnabled) => SettingsRow(
          icon: AppAssets.bell,
          title: context.l10n.settingsNotifications,
          value: switch (pushEnabled) {
            null => null,
            true => context.l10n.valueOn,
            false => context.l10n.valueOff,
          },
          onTap: () =>
              AppNavigator.push(context, AppRoutes.settingsNotifications),
        ),
      );
}

class SettingsAutoplayRow extends StatelessWidget {
  const SettingsAutoplayRow({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsCubit, SettingsState, bool>(
        selector: (state) => state.autoplayShorts,
        builder: (context, value) => SwitchRow(
          title: context.l10n.settingsAutoplay,
          subtitle: context.l10n.settingsAutoplaySub,
          value: value,
          onChanged: context.read<SettingsCubit>().setAutoplayShorts,
        ),
      );
}

class SettingsDataSaverRow extends StatelessWidget {
  const SettingsDataSaverRow({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsCubit, SettingsState, bool>(
        selector: (state) => state.dataSaver,
        builder: (context, value) => SwitchRow(
          title: context.l10n.settingsDataSaver,
          subtitle: context.l10n.settingsDataSaverSub,
          value: value,
          onChanged: context.read<SettingsCubit>().setDataSaver,
        ),
      );
}

class SettingsVersionLine extends StatelessWidget {
  const SettingsVersionLine({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<SettingsCubit, SettingsState, String?>(
        selector: (state) => state.version,
        builder: (context, version) => version == null
            ? const SizedBox.shrink()
            : Center(
                child: AppText(
                  context.l10n.settingsVersion(version),
                  style: context.text.caption,
                  color: context.appColors.textSecondary,
                ),
              ),
      );
}
