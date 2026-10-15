import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_card_dimens.dart';
import '../../dimens/tag_people_dimens.dart';
import '../../utils/tag_choice.dart';
import '../../utils/tag_photo.dart';
import '../media/post_media_chip.dart';
import '../media/post_tag_labels.dart';
import '../media/tag_spot.dart';

/// The photo being tagged, as large as the space allows with its own proportions: a tap marks a spot, each
/// label can be dragged and has a × that takes its spot off. Spots are fractions (0..1) of the photo, so
/// they hold at any size and are not mirrored in right-to-left.
class TagPhotoCanvas extends StatelessWidget {
  const TagPhotoCanvas({
    super.key,
    required this.photo,
    required this.number,
    required this.total,
    required this.labels,
    this.pendingX,
    this.pendingY,
    required this.onTap,
    required this.onMove,
    required this.onRemove,
  });

  final TagPhoto photo;

  /// Which photo this is of [total], from 1.
  final int number;
  final int total;
  final List<TagChoice> labels;
  final double? pendingX;
  final double? pendingY;
  final void Function(double x, double y) onTap;
  final void Function(String id, double x, double y) onMove;
  final ValueChanged<String> onRemove;

  ImageProvider? get _image {
    final path = photo.filePath;
    if (path != null) return FileImage(File(path));
    final url = photo.url;
    return url == null ? null : NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final width = min(box.maxWidth, box.maxHeight * photo.aspect);
      final height = width / photo.aspect;
      final colors = context.appColors;
      final image = _image;
      return Center(
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(PostCardDimens.mediaRadius),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) => onTap(
                details.localPosition.dx / width,
                details.localPosition.dy / height,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: colors.border),
                  if (image != null) Image(image: image, fit: BoxFit.cover),
                  PositionedDirectional(
                    top: PostCardDimens.mediaInset,
                    end: PostCardDimens.mediaInset,
                    child: PostMediaChip(text: '$number/$total'),
                  ),
                  for (final choice in labels)
                    Positioned.fill(
                      child: CustomSingleChildLayout(
                        delegate: TagSpotLayout(
                          anchor: Offset(
                            (choice.x ?? 0) * width,
                            (choice.y ?? 0) * height,
                          ),
                          above: PostTagLabels.fitsAbove(
                            (choice.y ?? 0) * height,
                          ),
                          isOwn: false,
                        ),
                        child: _DragLabel(
                          choice: choice,
                          above: PostTagLabels.fitsAbove(
                            (choice.y ?? 0) * height,
                          ),
                          onDrag: (dx, dy) => onMove(
                            choice.id,
                            (choice.x ?? 0) + dx / width,
                            (choice.y ?? 0) + dy / height,
                          ),
                          onRemove: () => onRemove(choice.id),
                        ),
                      ),
                    ),
                  if (pendingX != null && pendingY != null)
                    Positioned(
                      left: pendingX! * width - TagPeopleDimens.marker / 2,
                      top: pendingY! * height - TagPeopleDimens.marker / 2,
                      child: const _Marker(),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _DragLabel extends StatelessWidget {
  const _DragLabel({
    required this.choice,
    required this.above,
    required this.onDrag,
    required this.onRemove,
  });

  final TagChoice choice;
  final bool above;
  final void Function(double dx, double dy) onDrag;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final pill = Container(
      height: PostCardDimens.tagLabelHeight,
      padding: EdgeInsetsDirectional.only(
        start: PostCardDimens.tagLabelPadding,
        end: PostCardDimens.dotGap,
      ),
      decoration: BoxDecoration(
        color: colors.tagLabel,
        borderRadius: BorderRadius.circular(PostCardDimens.tagLabelRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: AppText(
              choice.username,
              style: context.text.countLabel,
              color: colors.textOnPrimary,
              maxLines: 1,
            ),
          ),
          SizedBox(width: PostCardDimens.dotGap),
          Semantics(
            button: true,
            excludeSemantics: true,
            label: l10n.postTagInPhotoRemoveSpot(choice.shownName),
            onTap: onRemove,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: SizedBox.square(
                dimension: TagPeopleDimens.labelClose * 2,
                child: Center(
                  child: AppSvgIcon(
                    AppAssets.close,
                    size: TagPeopleDimens.labelCloseIcon,
                    color: colors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      label: l10n.postTagInPhotoLabel(choice.shownName),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        onPanUpdate: (details) => onDrag(details.delta.dx, details.delta.dy),
        child: TagPointerWrap(
          above: above,
          color: colors.tagLabel,
          child: pill,
        ),
      ),
    );
  }
}

/// A dashed white ring where the person tapped, while the pick list is open.
class _Marker extends StatelessWidget {
  const _Marker();

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(TagPeopleDimens.marker),
    painter: _MarkerPainter(color: context.appColors.textOnPrimary),
  );
}

class _MarkerPainter extends CustomPainter {
  const _MarkerPainter({required this.color});

  static const _dashes = 12;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = TagPeopleDimens.markerStroke;
    final rect = Offset.zero & size;
    const sweep = 2 * pi / _dashes;
    for (var i = 0; i < _dashes; i += 2) {
      canvas.drawArc(rect.deflate(1), i * sweep, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_MarkerPainter old) => old.color != color;
}
