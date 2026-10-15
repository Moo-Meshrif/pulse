import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_composer_dimens.dart';

/// The dashed "+ Add" tile at the end of the media strip.
class AddMediaTile extends StatelessWidget {
  const AddMediaTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = context.l10n.newPostAdd;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          foregroundPainter: _DashedRoundedRectPainter(
            color: colors.dashed,
            radius: PostComposerDimens.thumbRadius,
          ),
          child: Container(
            width: PostComposerDimens.thumb,
            height: PostComposerDimens.thumb,
            decoration: BoxDecoration(
              color: colors.addFill,
              borderRadius: BorderRadius.circular(
                PostComposerDimens.thumbRadius,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSvgIcon(
                  AppAssets.plus,
                  size: PostComposerDimens.addPlus,
                  color: colors.primary,
                ),
                AppText(
                  label,
                  style: context.text.action,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({required this.color, required this.radius});

  static const _dash = 6.0; // unscaled: dash pattern
  static const _gap = 4.0; // unscaled: dash pattern

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = PostComposerDimens.addBorderWidth;
    final inset = PostComposerDimens.addBorderWidth / 2;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            inset,
            inset,
            size.width - 2 * inset,
            size.height - 2 * inset,
          ),
          Radius.circular(radius),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += _dash + _gap) {
        canvas.drawPath(
          metric.extractPath(at, math.min(at + _dash, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRoundedRectPainter old) =>
      old.color != color || old.radius != radius;
}
