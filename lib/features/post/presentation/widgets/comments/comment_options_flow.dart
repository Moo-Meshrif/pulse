import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entity/comment_entity.dart';
import '../../cubit/comments/comments_cubit.dart';
import '../../utils/comment_option_layout.dart';
import '../../utils/enums/comment_option.dart';
import 'comment_options_sheet.dart';

/// Opens the long-press menu of a comment and carries out the choice: the cubit does the work, the
/// confirmation, the report sheet and the notices are here. Everything the steps need is taken from the
/// screen before the first `await` (the sheet may be gone by the time Undo is tapped).
abstract final class CommentOptionsFlow {
  static Future<void> show(
    BuildContext context, {
    required CommentsCubit cubit,
    required CommentEntity comment,
    required bool isPostOwner,
    required bool commentsEnabled,
  }) async {
    final layout = CommentOptionLayout.of(
      isMine: comment.authorId == cubit.me?.id,
      isPostOwner: isPostOwner,
      commentsEnabled: commentsEnabled,
    );
    final choice = await CommentOptionsSheet.show(context, layout);
    if (choice == null || !context.mounted) return;
    final emoji = choice.emoji;
    if (emoji != null) return cubit.replyWithEmoji(comment, emoji);
    final option = choice.option;
    if (option != null) await _run(context, option, cubit, comment);
  }

  static Future<void> _run(
    BuildContext context,
    CommentOption option,
    CommentsCubit cubit,
    CommentEntity comment,
  ) {
    switch (option) {
      case CommentOption.reply:
        cubit.startReply(comment);
        return Future.value();
      case CommentOption.copyText:
        return _copy(context, comment);
      case CommentOption.edit:
        cubit.startEdit(comment);
        return Future.value();
      case CommentOption.delete:
        return _delete(context, cubit, comment);
      case CommentOption.hide:
        return _hide(context, cubit, comment);
      case CommentOption.report:
        return _report(context, cubit, comment);
    }
  }

  static Future<void> _copy(BuildContext context, CommentEntity comment) async {
    final message = context.l10n.commentsCopied;
    await Clipboard.setData(ClipboardData(text: comment.body));
    Notices.info(message);
  }

  static Future<void> _delete(
    BuildContext context,
    CommentsCubit cubit,
    CommentEntity comment,
  ) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: l10n.commentsDeleteTitle,
      message: l10n.commentsDeleteBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (confirmed != true) return;
    await cubit.delete(comment);
  }

  static Future<void> _hide(
    BuildContext context,
    CommentsCubit cubit,
    CommentEntity comment,
  ) async {
    final l10n = context.l10n;
    final id = comment.id;
    if (!await cubit.hide(comment)) return;
    Notices.info(
      l10n.commentsHidden,
      actionLabel: l10n.undo,
      onResult: (acted) {
        if (acted) cubit.undoHide(id);
      },
    );
  }

  static Future<void> _report(
    BuildContext context,
    CommentsCubit cubit,
    CommentEntity comment,
  ) {
    final l10n = context.l10n;
    return ReportSheet.show(
      context,
      copy: ReportCopy(
        title: l10n.commentsReport,
        body: l10n.commentsReportBody,
        sentBody: l10n.commentsReportSent,
        notePlaceholder: l10n.commentsReportNotePlaceholder,
      ),
      onSubmit: (reason, note) => cubit.report(comment, reason, note),
    );
  }
}
