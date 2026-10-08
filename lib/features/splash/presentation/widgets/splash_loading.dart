import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// The splash while it decides: the 72 logo tile with the wordmark under it, centered, and a small
/// spinner at the bottom (docs/specs/auth/screens/s13-splash.md).
class SplashLoading extends StatelessWidget {
  const SplashLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoTile.large(),
              SizedBox(height: SplashDimens.logoToWordmarkGap),
              AppText(
                context.l10n.appTitle,
                style: context.text.display,
                color: colors.textPrimary,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: SplashDimens.spinnerBottom),
            child: AppSpinner(
              size: SplashDimens.spinnerSize,
              strokeWidth: SplashDimens.spinnerStroke,
              color: colors.primary,
              trackColor: colors.switchOff,
              semanticsLabel: context.l10n.loading,
            ),
          ),
        ),
      ],
    );
  }
}
