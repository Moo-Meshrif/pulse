import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/utils/format_countdown.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_composer_dimens.dart';
import '../media/post_media_chip.dart';

/// A photo or video in the strip, with its remove button and, for a video, its length.
class MediaThumb extends StatelessWidget {
  const MediaThumb({
    super.key,
    required this.index,
    this.image,
    this.durationMs,
    required this.onRemove,
  });

  /// Position in the strip, from 0.
  final int index;

  /// The photo, or a frame of the video; null while there is none, which draws a plain tile.
  final ImageProvider? image;

  /// A video's length; null for a photo.
  final int? durationMs;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cacheWidth =
        (PostComposerDimens.thumb * MediaQuery.devicePixelRatioOf(context))
            .round();
    final picture = image;
    return SizedBox.square(
      dimension: PostComposerDimens.thumb,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                PostComposerDimens.thumbRadius,
              ),
              child: picture == null
                  ? ColoredBox(color: colors.border)
                  : Image(
                      image: ResizeImage.resizeIfNeeded(
                        cacheWidth,
                        null,
                        picture,
                      ),
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: colors.border),
                    ),
            ),
          ),
          if (durationMs != null)
            PositionedDirectional(
              start: PostComposerDimens.durationInset,
              bottom: PostComposerDimens.durationInset,
              child: PostMediaChip(
                text: formatCountdown(Duration(milliseconds: durationMs!)),
                radius: PostComposerDimens.durationRadius,
              ),
            ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: _RemoveButton(number: index + 1, onTap: onRemove),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.number, required this.onTap});

  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: context.l10n.newPostRemoveMedia(number),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: PostComposerDimens.removeTapTarget,
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: Padding(
              padding: EdgeInsets.all(PostComposerDimens.removeInset),
              child: Container(
                width: PostComposerDimens.removeButton,
                height: PostComposerDimens.removeButton,
                decoration: BoxDecoration(
                  color: colors.mediaChip,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(
                  AppAssets.close,
                  size: PostComposerDimens.removeIcon,
                  color: colors.textOnPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
