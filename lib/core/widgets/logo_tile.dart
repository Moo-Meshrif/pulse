import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';

/// The app logo on a `primary` tile ([LogoTile.large] for the splash). The logo has its own fills: not
/// tinted, never flipped in RTL (docs/specs/auth/02-components.md C2).
class LogoTile extends StatelessWidget {
  const LogoTile({super.key}) : _size = _LogoTileSize.auth;

  /// The splash's 72 tile (docs/specs/auth/screens/s13-splash.md).
  const LogoTile.large({super.key}) : _size = _LogoTileSize.splash;

  /// The Home header's 28 tile (docs/specs/home/01-design-tokens.md).
  const LogoTile.header({super.key}) : _size = _LogoTileSize.header;

  final _LogoTileSize _size;

  @override
  Widget build(BuildContext context) {
    final (size, radius) = switch (_size) {
      _LogoTileSize.auth => (AuthDimens.logoTile, AppRadius.logoTile),
      _LogoTileSize.splash => (
        SplashDimens.logoTile,
        SplashDimens.logoTileRadius,
      ),
      _LogoTileSize.header => (HomeDimens.logoTile, HomeDimens.logoRadius),
    };
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

enum _LogoTileSize { auth, splash, header }
