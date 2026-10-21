import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_dimens.dart';

/// The white "View post" pill under an open post sticker, with a small pointer up at the sticker.
class StoryViewPostPill extends StatelessWidget {
  const StoryViewPostPill({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(
            StoryPostDimens.pointerWidth,
            StoryPostDimens.pointerHeight,
          ),
          painter: _Pointer(colors.onDark),
        ),
        Semantics(
          button: true,
          label: context.l10n.storyViewPost,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              height: StoryPostDimens.viewPillHeight,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s20),
              decoration: BoxDecoration(
                color: colors.onDark,
                borderRadius: BorderRadius.circular(
                  StoryPostDimens.viewPillHeight / 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.s4,
                children: [
                  AppText(
                    context.l10n.storyViewPost,
                    style: context.text.button,
                    color: colors.textPrimary,
                  ),
                  AppSvgIcon(
                    AppAssets.chevronRight,
                    size: AppSpacing.s20,
                    color: colors.textPrimary,
                    directional: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pointer extends CustomPainter {
  const _Pointer(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Pointer old) => old.color != color;
}
