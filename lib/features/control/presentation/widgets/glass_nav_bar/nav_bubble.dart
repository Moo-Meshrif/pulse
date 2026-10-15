import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/colors/app_colors.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../dimens/nav_dimens.dart';
import 'glass_border_painter.dart';
import 'outside_shadow_painter.dart';

/// The white circle behind the selected tab: a translucent fill, a top highlight, a 1 px ring and a glow
/// that is the same on every side. The ring is painted last, over the highlight, so the circle's edge is
/// complete on a light page too.
class NavBubble extends StatelessWidget {
  const NavBubble({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: OutsideShadowPainter(
      borderRadius: BorderRadius.circular(NavDimens.bubble / 2),
      shadows: AppShadows.navActiveTab,
    ),
    child: _circle(context.appColors),
  );

  Widget _circle(AppColors colors) => Container(
    width: NavDimens.bubble,
    height: NavDimens.bubble,
    foregroundDecoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: colors.glassActiveRing,
        width: NavDimens.borderWidth,
      ),
    ),
    child: CustomPaint(
      foregroundPainter: GlassBorderPainter(
        radius: NavDimens.bubble / 2,
        colors: [colors.glassHighlightTop, colors.glassHighlightBottom],
        stops: const [0, 0.5],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.glassActive,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}
