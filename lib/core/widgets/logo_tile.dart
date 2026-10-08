import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';

/// The app logo on a `primary` tile ([LogoTile.large] for the splash). The logo has its own fills: not
/// tinted, never flipped in RTL (docs/specs/auth/02-components.md C2).
class LogoTile extends StatelessWidget {
  const LogoTile({super.key}) : _large = false;

  /// The splash's 72 tile (docs/specs/auth/screens/s13-splash.md).
  const LogoTile.large({super.key}) : _large = true;

  final bool _large;

  @override
  Widget build(BuildContext context) {
    final size = _large ? SplashDimens.logoTile : AuthDimens.logoTile;
    final radius = _large ? SplashDimens.logoTileRadius : AppRadius.logoTile;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: context.appColors.primary,
          child: SvgPicture.asset(AppAssets.logo, width: size, height: size),
        ),
      ),
    );
  }
}
