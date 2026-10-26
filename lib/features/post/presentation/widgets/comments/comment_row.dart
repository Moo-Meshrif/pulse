import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/post_time.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entity/comment_entity.dart';
import '../../dimens/comments_dimens.dart';
import '../post_person_avatar.dart';
import 'comment_author_badge.dart';
import 'comment_body.dart';

/// One comment or reply: avatar, name, time, text, Reply and likes, and the heart at the end. A reply is
/// indented and has the smaller avatar.
class CommentRow extends StatefulWidget {
  const CommentRow({
    super.key,
    required this.comment,
    this.highlighted = false,
    required this.onLike,
    required this.onLikeOnce,
    required this.onOptions,
    this.onReply,
  });

  final CommentEntity comment;

  /// A reply is being written to this comment.
  final bool highlighted;
  final VoidCallback onLike;

  /// Double tap on the row: likes, never unlikes.
  final VoidCallback onLikeOnce;

  /// Long press: opens the menu; the row stays darker until it closes.
  final Future<void> Function() onOptions;

  /// Opens a reply to this comment; null hides Reply (comments are off).
  final VoidCallback? onReply;

  @override
  State<CommentRow> createState() => _CommentRowState();
}

class _CommentRowState extends State<CommentRow> {
  bool _pressed = false;

  Future<void> _openOptions() async {
    setState(() => _pressed = true);
    await widget.onOptions();
    if (mounted) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final onReply = widget.onReply;
    final isReply = comment.isReply;
    return Semantics(
      container: true,
      label: context.l10n.commentBy(comment.shownName),
      onLongPress: _openOptions,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: _openOptions,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _pressed
                ? context.appColors.divider
                : widget.highlighted
                ? context.appColors.primarySoft
                : Colors.transparent,
            borderRadius: BorderRadius.circular(CommentsDimens.rowRadius),
          ),
          child: Padding(
            padding: CommentsDimens.rowPadding.add(
              EdgeInsetsDirectional.only(
                start: isReply ? CommentsDimens.replyIndent : 0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostPersonAvatar(
                  id: comment.authorId,
                  name: comment.shownName,
                  url: comment.avatarUrl,
                  size: isReply
                      ? CommentsDimens.replyAvatar
                      : CommentsDimens.avatar,
                ),
                SizedBox(width: CommentsDimens.avatarGap),
                Expanded(
                  child: _Content(
                    comment: comment,
                    onReply: onReply,
                    onLikeOnce: widget.onLikeOnce,
                  ),
                ),
                _Heart(comment: comment, onTap: widget.onLike),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.comment,
    required this.onReply,
    required this.onLikeOnce,
  });

  final CommentEntity comment;
  final VoidCallback? onReply;
  final VoidCallback onLikeOnce;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final time = postTime(l10n, comment.createdAt, clock.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: onLikeOnce,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: CommentsDimens.nameGap,
                children: [
                  AppText(
                    comment.shownName,
                    style: context.text.countLabel,
                    color: colors.textPrimary,
                  ),
                  if (comment.isPostAuthor) const CommentAuthorBadge(),
                  AppText(
                    comment.isEdited ? '$time · ${l10n.commentsEdited}' : time,
                    style: context.text.caption,
                    color: colors.textSecondary,
                  ),
                ],
              ),
              SizedBox(height: CommentsDimens.lineGap),
              CommentBody(comment.body),
            ],
          ),
        ),
        SizedBox(height: CommentsDimens.lineGap),
        Row(
          children: [
            if (onReply != null) _ReplyButton(onTap: onReply!),
            if (comment.likeCount > 0) ...[
              if (onReply != null) SizedBox(width: CommentsDimens.actionsGap),
              AppText(
                l10n.commentLikes(comment.likeCount),
                style: context.text.chip,
                color: colors.textSecondary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ReplyButton extends StatelessWidget {
  const _ReplyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    excludeSemantics: true,
    label: context.l10n.commentReply,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: CommentsDimens.stateTarget,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 1,
          child: AppText(
            context.l10n.commentReply,
            style: context.text.chip,
            color: context.appColors.textSecondary,
          ),
        ),
      ),
    ),
  );
}

class _Heart extends StatelessWidget {
  const _Heart({required this.comment, required this.onTap});

  final CommentEntity comment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final liked = comment.likedByMe;
    return Semantics(
      button: true,
      toggled: liked,
      excludeSemantics: true,
      label: liked ? context.l10n.postUnlike : context.l10n.postLike,
      child: InkResponse(
        onTap: onTap,
        radius: CommentsDimens.heartTarget / 2,
        child: SizedBox(
          width: CommentsDimens.heartTarget,
          height: CommentsDimens.heartTarget,
          child: Center(
            child: AppSvgIcon(
              liked ? AppAssets.heartFilled : AppAssets.heart,
              size: CommentsDimens.heart,
              color: liked ? colors.like : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
