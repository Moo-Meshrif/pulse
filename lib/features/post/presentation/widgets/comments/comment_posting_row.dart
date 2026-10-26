import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../dimens/comments_dimens.dart';
import '../../utils/pending_comment.dart';
import '../post_person_avatar.dart';

/// A comment of yours the server has not confirmed: faded with "Posting…", or failed with Retry and Delete.
class CommentPostingRow extends StatelessWidget {
  const CommentPostingRow({
    super.key,
    required this.pending,
    required this.me,
    required this.onRetry,
    required this.onDelete,
  });

  final PendingComment pending;
  final LastAccountEntity? me;
  final VoidCallback onRetry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isReply = pending.parentId != null;
    final fullName = me?.fullName?.trim();
    final name = fullName == null || fullName.isEmpty
        ? me?.username ?? ''
        : fullName;
    final row = Padding(
      padding: CommentsDimens.rowPadding.add(
        EdgeInsetsDirectional.only(
          start: isReply ? CommentsDimens.replyIndent : 0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostPersonAvatar(
            id: me?.id ?? pending.clientId,
            name: name,
            url: me?.avatarUrl,
            size: isReply ? CommentsDimens.replyAvatar : CommentsDimens.avatar,
          ),
          SizedBox(width: CommentsDimens.avatarGap),
          Expanded(
            child: Opacity(
              opacity: pending.failed ? 1 : CommentsDimens.postingOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    name,
                    style: context.text.countLabel,
                    color: colors.textPrimary,
                  ),
                  SizedBox(height: CommentsDimens.lineGap),
                  AppText(
                    pending.body,
                    style: context.text.bodySm,
                    color: colors.textPrimary,
                  ),
                  SizedBox(height: CommentsDimens.lineGap),
                  pending.failed
                      ? _Failed(onRetry: onRetry, onDelete: onDelete)
                      : const _Posting(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      container: true,
      label: context.l10n.commentBy(name),
      child: row,
    );
  }
}

class _Posting extends StatelessWidget {
  const _Posting();

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.textSecondary;
    return Row(
      children: [
        AppSvgIcon(
          AppAssets.clock,
          size: CommentsDimens.stateIcon,
          color: color,
        ),
        SizedBox(width: CommentsDimens.stateGap),
        AppText(
          context.l10n.commentsPosting,
          style: context.text.chip,
          color: color,
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry, required this.onDelete});

  final VoidCallback onRetry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = context.appColors.warningInk;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppSvgIcon(
          AppAssets.warning,
          size: CommentsDimens.stateIcon,
          color: color,
        ),
        SizedBox(width: CommentsDimens.stateGap),
        AppText(
          l10n.commentsCouldntPost,
          style: context.text.chip,
          color: color,
        ),
        _Action(label: l10n.commentsRetry, color: color, onTap: onRetry),
        _Action(label: l10n.commentsDelete, color: color, onTap: onDelete),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    excludeSemantics: true,
    label: label,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: CommentsDimens.stateTarget,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: CommentsDimens.stateGap),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText('· ', style: context.text.chip, color: color),
              AppText(
                label,
                style: context.text.chip.copyWith(fontWeight: FontWeight.w700),
                color: color,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
