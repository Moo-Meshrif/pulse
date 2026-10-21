import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../dimens/post_card_dimens.dart';
import '../utils/post_card_callbacks.dart';
import '../utils/post_card_data.dart';
import 'expandable_caption.dart';
import 'post_author_row.dart';
import 'post_media.dart';

/// The original post inside a share: a framed card with its author row, caption and media, and no action bar.
/// A tap anywhere on it opens the original ([PostCardCallbacks.onOriginal]).
class SharedPostEmbed extends StatelessWidget {
  const SharedPostEmbed({
    super.key,
    required this.shareId,
    required this.original,
    required this.callbacks,
  });

  /// The share's id: the original's videos are told apart from the same post shown elsewhere in the feed.
  final String shareId;
  final PostCardData original;
  final PostCardCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final caption = original.caption?.trim() ?? '';
    final hasMedia = original.media.isNotEmpty;
    final inner = PostCardCallbacks(
      onProfile: callbacks.onOriginalProfile,
      onTaggedPerson: callbacks.onTaggedPerson,
    );
    return Semantics(
      container: true,
      button: callbacks.onOriginal != null,
      label: context.l10n.postSharedSemantics(original.authorName),
      onTap: callbacks.onOriginal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: callbacks.onOriginal,
        child: Container(
          padding: EdgeInsets.all(PostCardDimens.embedPadding),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(PostCardDimens.embedRadius),
            border: Border.all(
              color: context.appColors.border,
              width: PostCardDimens.embedBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PostAuthorRow(data: original, callbacks: inner, isEmbedded: true),
              if (caption.isNotEmpty)
                ExpandableCaption(
                  text: caption,
                  collapsedLines: PostCardDimens.embedCaptionLines,
                  margin: PostCardDimens.embedCaptionMargin,
                )
              else
                SizedBox(height: PostCardDimens.embedCaptionMargin.top),
              if (hasMedia)
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    PostCardDimens.embedMediaRadius,
                  ),
                  child: PostMedia(
                    postId: '$shareId/original',
                    items: original.media,
                    onTap: callbacks.onOriginal,
                    tags: original.tags,
                    onTaggedPerson: callbacks.onTaggedPerson,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
