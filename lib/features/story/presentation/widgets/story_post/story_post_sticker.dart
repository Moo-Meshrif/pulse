import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/colors/app_colors.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/utils/story_post_args.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/story_post_sticker_style.dart';
import '../../dimens/story_dimens.dart';
import '../story_avatar.dart';

/// The post a story shows, drawn in one of three styles (docs/specs/post/screens/s13-add-to-story.md): a
/// white card with the author, the first picture and the words; the picture alone with an author chip; or a
/// small card for adding your own text above it. Its width follows the screen, so the editor and the
/// viewer draw it the same.
class StoryPostSticker extends StatelessWidget {
  const StoryPostSticker({super.key, required this.post, required this.style});

  final StoryPostArgs post;
  final StoryPostStickerStyle style;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context).width;
    final fraction = switch (style) {
      StoryPostStickerStyle.card => StoryPostDimens.cardWidth,
      StoryPostStickerStyle.media => StoryPostDimens.mediaWidth,
      StoryPostStickerStyle.compact => StoryPostDimens.compactWidth,
    };
    final caption = post.caption?.trim() ?? '';
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: caption.isEmpty
          ? l10n.storyPostSemanticsNoCaption(post.username)
          : l10n.storyPostSemantics(post.username, caption),
      excludeSemantics: true,
      child: SizedBox(
        width: (screen * fraction).clamp(0, StoryPostDimens.maxWidth),
        child: switch (style) {
          StoryPostStickerStyle.card => _Card(post: post, caption: caption),
          StoryPostStickerStyle.media => _MediaOnly(post: post),
          StoryPostStickerStyle.compact => _Compact(
            post: post,
            caption: caption,
          ),
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.post, required this.caption});

  final StoryPostArgs post;
  final String caption;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(StoryPostDimens.cardRadius),
      boxShadow: [
        BoxShadow(
          color: StoryColors.tool,
          offset: Offset(0, StoryPostDimens.shadowOffset),
          blurRadius: StoryPostDimens.shadowBlur,
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(StoryPostDimens.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: StoryPostDimens.authorPadding,
            child: Row(
              spacing: AppSpacing.s8,
              children: [
                StoryAvatar(
                  size: StoryPostDimens.authorAvatar,
                  seed: post.username,
                  name: post.username,
                  imageUrl: post.avatarUrl,
                ),
                Expanded(
                  child: AppText(
                    post.username,
                    style: context.text.label.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    color: context.appColors.textPrimary,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          if (post.mediaUrl != null) _Picture(post: post),
          if (caption.isNotEmpty || post.mediaUrl != null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.s8),
              child: _Words(post: post, caption: caption),
            ),
        ],
      ),
    ),
  );
}

class _MediaOnly extends StatelessWidget {
  const _MediaOnly({required this.post});

  final StoryPostArgs post;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(StoryPostDimens.mediaOnlyRadius),
      child: Stack(
        children: [
          if (post.mediaUrl != null)
            _Picture(post: post, radius: 0)
          else
            AspectRatio(
              aspectRatio: StoryPostDimens.mediaAspect,
              child: ColoredBox(color: colors.surface),
            ),
          PositionedDirectional(
            start: StoryPostDimens.chipInset,
            bottom: StoryPostDimens.chipInset,
            child: Container(
              height: StoryPostDimens.chipHeight,
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.s4,
                end: StoryPostDimens.cardPadding,
              ),
              decoration: BoxDecoration(
                color: StoryColors.postChip,
                borderRadius: BorderRadius.circular(
                  StoryPostDimens.chipHeight / 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: StoryPostDimens.chipGap,
                children: [
                  StoryAvatar(
                    size: StoryPostDimens.chipAvatar,
                    seed: post.username,
                    name: post.username,
                    imageUrl: post.avatarUrl,
                  ),
                  AppText(
                    post.username,
                    style: context.text.chipLabel,
                    color: colors.onDark,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Compact extends StatelessWidget {
  const _Compact({required this.post, required this.caption});

  final StoryPostArgs post;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(StoryPostDimens.compactRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(StoryPostDimens.cardPadding),
        child: Row(
          spacing: StoryPostDimens.cardPadding,
          children: [
            if (post.mediaUrl != null)
              SizedBox.square(
                dimension: StoryPostDimens.compactThumb,
                child: _Picture(
                  post: post,
                  radius: StoryPostDimens.compactThumbRadius,
                  aspect: 1,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    post.username,
                    style: context.text.label.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    color: colors.textPrimary,
                    maxLines: 1,
                  ),
                  if (caption.isNotEmpty)
                    AppText(
                      caption,
                      style: context.text.bodyXs,
                      color: colors.textSecondary,
                      maxLines: StoryPostDimens.captionLines,
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

/// The post's first picture, cover-fit in [aspect] (4:5 by default).
class _Picture extends StatelessWidget {
  const _Picture({
    required this.post,
    this.radius,
    this.aspect = StoryPostDimens.mediaAspect,
  });

  final StoryPostArgs post;
  final double? radius;
  final double aspect;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius ?? StoryPostDimens.mediaRadius),
    child: AspectRatio(
      aspectRatio: aspect,
      child: AppImage.network(
        post.mediaUrl!,
        cacheKey: post.mediaCacheKey,
        fit: BoxFit.cover,
      ),
    ),
  );
}

/// The author's name in bold, then the words, at most two lines.
class _Words extends StatelessWidget {
  const _Words({required this.post, required this.caption});

  final StoryPostArgs post;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodyXs.copyWith(
      color: context.appColors.textPrimary,
      height: StoryPostDimens.captionHeight,
    );
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: post.username,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (caption.isNotEmpty) TextSpan(text: ' $caption'),
        ],
      ),
      maxLines: StoryPostDimens.captionLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
