import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../dimens/splash_dimens.dart';

/// The splash while it decides: the 72 logo tile with the wordmark under it, and the heartbeat line under
/// that (docs/specs/auth/screens/s13-splash.md). The tile and wordmark stay centered in the screen: a
/// spacer as tall as the line and its gap sits above them.
class SplashLoading extends StatelessWidget {
  const SplashLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final lineHeight = SplashDimens.lineWidth * PulseLineLoader.aspect;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: SplashDimens.wordmarkToLineGap + lineHeight),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          SizedBox(height: SplashDimens.wordmarkToLineGap),
          Semantics(
            liveRegion: true,
            label: context.l10n.loading,
            child: PulseLineLoader(
              color: colors.primary,
              width: SplashDimens.lineWidth,
            ),
          ),
        ],
      ),
    );
  }
}
