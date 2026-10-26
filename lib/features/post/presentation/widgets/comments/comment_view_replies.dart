import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/comments_dimens.dart';

/// "— View N more replies": loads the rest of a thread. While it loads it shows a spinner, and when it
/// fails it says so and the same tap retries.
class CommentViewReplies extends StatelessWidget {
  const CommentViewReplies({
    super.key,
    required this.remaining,
    required this.status,
    required this.onTap,
  });

  final int remaining;

  /// Null when nothing is loading.
  final LoadMoreStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final label = status == LoadMoreStatus.failed
        ? l10n.commentsLoadMoreFailed
        : l10n.commentsViewMoreReplies(remaining);
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      child: InkWell(
        onTap: status == LoadMoreStatus.loading ? null : onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: CommentsDimens.viewRepliesMinHeight,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start:
                  CommentsDimens.replyIndent + CommentsDimens.rowPadding.left,
            ),
            child: Row(
              children: [
                Container(
                  width: CommentsDimens.viewRepliesLine,
                  height: CommentsDimens.divider,
                  color: colors.border,
                ),
                SizedBox(width: CommentsDimens.viewRepliesGap),
                AppText(
                  label,
                  style: context.text.chipLabel,
                  color: status == LoadMoreStatus.failed
                      ? colors.primary
                      : colors.textSecondary,
                ),
                if (status == LoadMoreStatus.loading) ...[
                  SizedBox(width: CommentsDimens.viewRepliesGap),
                  PulseLineLoader(
                    color: colors.primary,
                    width: LoadingDimens.loadMoreWidth,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
