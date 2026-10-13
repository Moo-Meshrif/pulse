import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../utils/story_sticker.dart';
import '../story_overlays_layer.dart';

/// The stickers of the edit screen: drag with one finger, pinch to scale (0.5x to 3x), twist to turn, tap
/// to retype, and drag onto the trash at the bottom to remove. Positions are fractions of this canvas,
/// so they match the viewer.
class StoryStickerCanvas extends StatefulWidget {
  const StoryStickerCanvas({
    super.key,
    required this.stickers,
    required this.onTransform,
    required this.onRemove,
    required this.onEdit,
    required this.zoneBottom,
  });

  final List<StorySticker> stickers;
  final void Function(
    int id, {
    double? x,
    double? y,
    double? scale,
    double? rotation,
  })
  onTransform;
  final ValueChanged<int> onRemove;
  final ValueChanged<StorySticker> onEdit;

  /// Distance from the bottom of the canvas to the bottom of the trash.
  final double zoneBottom;

  @override
  State<StoryStickerCanvas> createState() => _StoryStickerCanvasState();
}

class _StoryStickerCanvasState extends State<StoryStickerCanvas> {
  int? _active;
  bool _overZone = false;
  double _baseScale = 1;
  double _baseRotation = 0;

  Size get _size => (context.findRenderObject() as RenderBox).size;

  Offset get _zoneCenterGlobal {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;
    return box.localToGlobal(
      Offset(
        size.width / 2,
        size.height - widget.zoneBottom - StoryCameraDimens.deleteZone / 2,
      ),
    );
  }

  void _start(StorySticker sticker, ScaleStartDetails _) {
    setState(() {
      _active = sticker.id;
      _baseScale = sticker.overlay.scale ?? 1;
      _baseRotation = sticker.overlay.rotation ?? 0;
    });
  }

  void _update(StorySticker sticker, ScaleUpdateDetails details) {
    final size = _size;
    final overlay = sticker.overlay;
    widget.onTransform(
      sticker.id,
      x: (overlay.x ?? 0.5) + details.focalPointDelta.dx / size.width,
      y: (overlay.y ?? 0.5) + details.focalPointDelta.dy / size.height,
      scale: (_baseScale * details.scale).clamp(
        StoryCameraDimens.stickerMinScale,
        StoryCameraDimens.stickerMaxScale,
      ),
      rotation: _baseRotation + details.rotation * 180 / math.pi,
    );
    final over =
        (details.focalPoint - _zoneCenterGlobal).distance <
        StoryCameraDimens.deleteZone * StoryCameraDimens.deleteZoneHoverScale;
    if (over != _overZone) setState(() => _overZone = over);
  }

  void _end(StorySticker sticker, ScaleEndDetails _) {
    if (_overZone) widget.onRemove(sticker.id);
    setState(() {
      _active = null;
      _overZone = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : StoryMotion.uiFade;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final sticker in widget.stickers)
          StoryOverlayPlacement(
            key: ValueKey(sticker.id),
            overlay: sticker.overlay,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onEdit(sticker),
              onScaleStart: (d) => _start(sticker, d),
              onScaleUpdate: (d) => _update(sticker, d),
              onScaleEnd: (d) => _end(sticker, d),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.s8),
                child: storyStickerFor(sticker.overlay),
              ),
            ),
          ),
        PositionedDirectional(
          bottom: widget.zoneBottom,
          start: 0,
          end: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _active == null ? 0 : 1,
              duration: duration,
              child: Center(
                child: Semantics(
                  label: context.l10n.storyRemoveSticker,
                  child: AnimatedScale(
                    scale: _overZone
                        ? StoryCameraDimens.deleteZoneHoverScale
                        : 1,
                    duration: duration,
                    child: Container(
                      width: StoryCameraDimens.deleteZone,
                      height: StoryCameraDimens.deleteZone,
                      decoration: BoxDecoration(
                        color: _overZone ? colors.danger : colors.storyTool,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: AppSvgIcon(
                        AppAssets.trash,
                        size: StoryCameraDimens.toolIcon,
                        color: colors.storyOnDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
