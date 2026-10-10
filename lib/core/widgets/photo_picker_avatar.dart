import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../services/photo_picker_service.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// The profile photo picker (docs/specs/auth/02-components.md C13): an 88 circle (dashed with a camera
/// while empty, the picture with a solid border once chosen) and a plus badge, next to a title and caption.
/// A tap calls [onTap]; the owner shows the sheet.
class PhotoPickerAvatar extends StatelessWidget {
  const PhotoPickerAvatar({
    super.key,
    required this.photo,
    required this.onTap,
    this.avatarUrl,
  });

  final PickedPhoto? photo;

  /// A saved picture, shown while [photo] (a new pick) is null.
  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final size = AuthDimens.avatarUpload;
    return Semantics(
      button: true,
      label: l10n.addPhoto,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            SizedBox.square(
              dimension: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: photo == null && avatarUrl == null
                        ? CustomPaint(
                            painter: _DashedCirclePainter(
                              color: colors.border,
                              width: AuthDimens.avatarDashedWidth,
                            ),
                            child: Center(
                              child: AppSvgIcon(
                                AppAssets.camera,
                                size: AuthDimens.avatarCameraIcon,
                                color: colors.textSecondary,
                              ),
                            ),
                          )
                        : DecoratedBox(
                            position: DecorationPosition.foreground,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.border,
                                width: AuthDimens.avatarDashedWidth,
                              ),
                            ),
                            child: ClipOval(
                              child: photo != null
                                  ? Image.memory(
                                      photo!.bytes,
                                      fit: BoxFit.cover,
                                      cacheWidth: (size * 2).round(),
                                    )
                                  : Image.network(
                                      avatarUrl!,
                                      fit: BoxFit.cover,
                                      cacheWidth: (size * 2).round(),
                                      errorBuilder: (_, _, _) =>
                                          const SizedBox.shrink(),
                                    ),
                            ),
                          ),
                  ),
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: Container(
                      width: AuthDimens.avatarBadge,
                      height: AuthDimens.avatarBadge,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.background,
                          width: AuthDimens.avatarBadgeRing,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AppSvgIcon(
                        AppAssets.plus,
                        size: AuthDimens.avatarBadgePlus,
                        color: colors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.addPhoto,
                    style: context.text.name,
                    color: colors.textPrimary,
                  ),
                  SizedBox(height: AppSpacing.s4),
                  AppText(
                    l10n.addPhotoHint,
                    style: context.text.bodySm,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color, required this.width});

  final Color color;
  final double width;

  static const _dash = 6.0;
  static const _gap = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final circle = Path()
      ..addOval(
        Rect.fromLTWH(0, 0, size.width, size.height).deflate(width / 2),
      );
    for (final metric in circle.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += _dash + _gap) {
        canvas.drawPath(
          metric.extractPath(at, math.min(at + _dash, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) =>
      old.color != color || old.width != width;
}
