import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/hex_color.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/enums/story_overlay_type.dart';
import '../../data/model/story_overlay_model.dart';

/// The stickers of a story drawn over its media, from the JSON the story was saved with.
class StoryOverlaysLayer extends StatelessWidget {
  const StoryOverlaysLayer({super.key, required this.overlays});

  final List<StoryOverlayModel> overlays;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      fit: StackFit.expand,
      children: [
        for (final overlay in overlays)
          if (overlay.x != null && overlay.y != null && overlay.type != null)
            StoryOverlayPlacement(
              overlay: overlay,
              child: storyStickerFor(overlay),
            ),
      ],
    ),
  );
}

/// The sticker widget of [overlay]: text, or the location card.
Widget storyStickerFor(StoryOverlayModel overlay) => switch (overlay.type!) {
  StoryOverlayType.text => StoryTextSticker(
    text: overlay.text ?? '',
    color: overlay.color,
  ),
  StoryOverlayType.location => StoryLocationSticker(text: overlay.text ?? ''),
};

/// Puts [child] with its centre at the fractions [overlay] holds of the frame (the nearest Stack's size),
/// turned and scaled around that centre. The viewer, the edit screen and the saved picture all use it, so
/// a sticker lands in the same place in each.
class StoryOverlayPlacement extends StatelessWidget {
  const StoryOverlayPlacement({
    super.key,
    required this.overlay,
    required this.child,
  });

  final StoryOverlayModel overlay;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: (overlay.x ?? 0.5).clamp(0.0, 1.0) * box.maxWidth,
          top: (overlay.y ?? 0.5).clamp(0.0, 1.0) * box.maxHeight,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Transform.rotate(
              angle: _radians(overlay),
              child: Transform.scale(scale: overlay.scale ?? 1, child: child),
            ),
          ),
        ),
      ],
    ),
  );

  static double _radians(StoryOverlayModel overlay) {
    final degrees =
        overlay.rotation ??
        (overlay.type == StoryOverlayType.location
            ? StoryDimens.stickerRotationDegrees
            : 0);
    return degrees * math.pi / 180;
  }
}

class StoryTextSticker extends StatelessWidget {
  const StoryTextSticker({super.key, required this.text, this.color});

  final String text;

  /// `#RRGGBB`; white when null.
  final String? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 2 * AppSpacing.s24,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.text.overlayText.copyWith(
          color: parseHexColor(color) ?? colors.storyOnDark,
          shadows: AppShadows.textOverlay,
        ),
      ),
    );
  }
}

class StoryLocationSticker extends StatelessWidget {
  const StoryLocationSticker({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(StoryDimens.stickerRadius),
        boxShadow: AppShadows.sticker,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: StoryDimens.stickerHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: StoryDimens.stickerPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvgIcon(
                AppAssets.location,
                size: StoryDimens.stickerPin,
                color: colors.primary,
              ),
              SizedBox(width: StoryDimens.stickerGap),
              Flexible(
                child: AppText(
                  text.toUpperCase(),
                  style: context.text.stickerLabel,
                  color: colors.primary,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
