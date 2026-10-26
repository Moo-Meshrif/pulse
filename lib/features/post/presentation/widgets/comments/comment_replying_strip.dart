import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/comments_dimens.dart';

/// "Replying to @name" with an X, above the comment field.
class CommentReplyingStrip extends StatelessWidget {
  const CommentReplyingStrip({
    super.key,
    required this.username,
    required this.onCancel,
  });

  final String username;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // The name keeps its left-to-right order inside an Arabic sentence.
    final name = '\u2066@$username\u2069';
    final text = context.l10n.commentsReplyingTo(name);
    final at = text.indexOf(name);
    return CommentStrip(
      cancelLabel: context.l10n.commentsReplyCancel,
      onCancel: onCancel,
      child: Text.rich(
        TextSpan(
          style: context.text.caption.copyWith(color: colors.textSecondary),
          children: [
            TextSpan(text: at < 0 ? text : text.substring(0, at)),
            if (at >= 0) ...[
              TextSpan(
                text: name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              TextSpan(text: text.substring(at + name.length)),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Editing comment" with an X, above the comment field.
class CommentEditingStrip extends StatelessWidget {
  const CommentEditingStrip({super.key, required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => CommentStrip(
    cancelLabel: context.l10n.commentsEditCancel,
    onCancel: onCancel,
    child: AppText(
      context.l10n.commentsEditing,
      style: context.text.caption,
      color: context.appColors.textSecondary,
    ),
  );
}

/// The rounded strip above the field: [child] on the start side, the X at the end.
class CommentStrip extends StatelessWidget {
  const CommentStrip({
    super.key,
    required this.child,
    required this.cancelLabel,
    required this.onCancel,
  });

  final Widget child;
  final String cancelLabel;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      constraints: BoxConstraints(minHeight: CommentsDimens.stripHeight),
      padding: EdgeInsetsDirectional.only(start: CommentsDimens.stripSide),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(CommentsDimens.stripRadius),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          Semantics(
            button: true,
            label: cancelLabel,
            excludeSemantics: true,
            child: InkResponse(
              onTap: onCancel,
              radius: CommentsDimens.stripHeight / 2,
              child: SizedBox(
                width: CommentsDimens.stripHeight,
                height: CommentsDimens.stripHeight,
                child: Center(
                  child: AppSvgIcon(
                    AppAssets.close,
                    size: CommentsDimens.stateIcon,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
