import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/services/media_picker_service.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/utils/format_countdown.dart';
import '../../../../../core/widgets/widgets.dart';
import '../media/post_media_chip.dart';

/// A picked photo or video in the strip, with its remove button and, for a video, its length.
class MediaThumb extends StatelessWidget {
  const MediaThumb({
    super.key,
    required this.media,
    required this.index,
    this.poster,
    required this.onRemove,
  });

  final PickedMedia media;

  /// Position in the strip, from 0.
  final int index;

  /// A frame of the video, if one could be made.
  final String? poster;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cacheWidth =
        (PostComposerDimens.thumb * MediaQuery.devicePixelRatioOf(context))
            .round();
    final picture = media.isVideo ? poster : media.path;
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
                  : Image.file(
                      File(picture),
                      fit: BoxFit.cover,
                      cacheWidth: cacheWidth,
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: colors.border),
                    ),
            ),
          ),
          if (media.isVideo && media.durationMs != null)
            PositionedDirectional(
              start: PostComposerDimens.durationInset,
              bottom: PostComposerDimens.durationInset,
              child: PostMediaChip(
                text: formatCountdown(
                  Duration(milliseconds: media.durationMs!),
                ),
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
