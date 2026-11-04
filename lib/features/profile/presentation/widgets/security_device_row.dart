import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/security/security_cubit.dart';
import '../cubit/security/security_state.dart';

/// The one device row: this phone, active now (the other sessions are not listed yet, T4).
class SecurityDeviceRow extends StatelessWidget {
  const SecurityDeviceRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    return BlocSelector<SecurityCubit, SecurityState, String?>(
      selector: (state) => state.deviceName,
      builder: (context, name) => ConstrainedBox(
        constraints: BoxConstraints(minHeight: SettingsDimens.rowMinHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SettingsDimens.rowSide),
          child: Row(
            children: [
              Container(
                width: SettingsDimens.deviceTile,
                height: SettingsDimens.deviceTile,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.settingsTile),
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(
                  AppAssets.phone,
                  size: SettingsDimens.tileIcon,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(width: SettingsDimens.rowGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      name == null
                          ? l10n.securityThisDeviceFallback
                          : l10n.securityThisDevice(name),
                      style: context.text.body,
                      color: colors.textPrimary,
                    ),
                    AppText(
                      l10n.securityActiveNow,
                      style: context.text.bodyXs,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
