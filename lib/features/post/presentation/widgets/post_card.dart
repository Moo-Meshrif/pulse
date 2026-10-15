import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../dimens/post_card_dimens.dart';
import '../utils/post_card_callbacks.dart';
import '../utils/post_card_data.dart';
import 'expandable_caption.dart';
import 'post_action_bar.dart';
import 'post_author_row.dart';
import 'post_media.dart';

/// A post in a feed: author row, caption, media and action bar on a rounded card. [data] says what to draw,
/// [callbacks] what to tell the list. Put a [PostVideoScope] around the list so only one video plays.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.data,
    this.callbacks = const PostCardCallbacks(),
    this.isOptionsOpen = false,
  });

  final PostCardData data;
  final PostCardCallbacks callbacks;

  /// True while this post's options sheet is open.
  final bool isOptionsOpen;

  @override
  Widget build(BuildContext context) {
    final caption = data.caption?.trim() ?? '';
    final hasCaption = caption.isNotEmpty;
    final hasMedia = data.media.isNotEmpty;
    return Container(
      padding: PostCardDimens.padding,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(PostCardDimens.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostAuthorRow(
            authorId: data.authorId,
            name: data.authorName,
            avatarUrl: data.authorAvatarUrl,
            city: data.city,
            createdAt: data.createdAt,
            audienceIcon: data.audienceIcon,
            isOptionsOpen: isOptionsOpen,
            onProfile: callbacks.onProfile,
            onOptions: callbacks.onOptions,
          ),
          if (hasCaption)
            ExpandableCaption(
              text: caption,
              collapsedLines: hasMedia
                  ? PostCardDimens.captionWithMediaCollapsedLines
                  : PostCardDimens.captionOnlyCollapsedLines,
              margin: hasMedia
                  ? PostCardDimens.captionMargin
                  : PostCardDimens.captionOnlyMargin,
            )
          else
            SizedBox(height: PostCardDimens.captionMargin.top),
          if (hasMedia)
            PostMedia(
              postId: data.id,
              items: data.media,
              onDoubleTap: data.isLiked ? null : callbacks.onDoubleTapLike,
            ),
          PostActionBar(
            likeCount: data.likeCount,
            commentCount: data.commentCount,
            isLiked: data.isLiked,
            isSaved: data.isSaved,
            onLike: callbacks.onLike,
            onComment: callbacks.onComment,
            onShare: callbacks.onShare,
            onlySave: data.isOnlyMe,
            onSave: callbacks.onSave,
          ),
        ],
      ),
    );
  }
}
