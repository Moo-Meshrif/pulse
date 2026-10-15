import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/extensions/notice_context.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../utils/enums/post_option.dart';
import '../../utils/post_options_actions.dart';
import '../../utils/post_options_data.dart';
import '../../utils/post_tag_removal.dart';
import '../post_visibility/post_visibility_sheet.dart';
import 'post_options_sheet.dart';

/// Opens the options sheet of a post and carries out the option picked: the report sheet, the delete
/// confirmation and the notices are here; what happens to the post is the list's [PostOptionsActions].
/// Each step takes what it needs from the screen before its first `await` (the card may be gone by then).
abstract final class PostOptionsFlow {
  static Future<void> show(
    BuildContext context, {
    required PostOptionsData data,
    required PostOptionsActions actions,
  }) async {
    final option = await PostOptionsSheet.show(context, data);
    if (option == null || !context.mounted) return;
    await _run(context, option, data, actions);
  }

  static Future<void> _run(
    BuildContext context,
    PostOption option,
    PostOptionsData data,
    PostOptionsActions actions,
  ) {
    switch (option) {
      case PostOption.save:
        return _attempt(context, actions.onSave);
      case PostOption.copyLink:
      case PostOption.share:
        // TODO(post-plan T7): Copy link and Share are coming soon until post links and share_plus exist.
        Notices.info(context.l10n.comingSoon);
        return Future.value();
      case PostOption.notInterested:
        return _attempt(context, actions.onNotInterested);
      case PostOption.unfollow:
        return _unfollow(context, data, actions);
      case PostOption.mute:
        return _mute(context, data, actions);
      case PostOption.report:
        return _report(context, data, actions);
      case PostOption.edit:
        actions.onEdit();
        return Future.value();
      case PostOption.changeAudience:
        return _changeAudience(context, data, actions);
      case PostOption.toggleComments:
        return _attempt(context, actions.onToggleComments);
      case PostOption.removeMyTag:
        return PostTagRemoval.confirmAndRemove(
          context,
          ownerName: data.username,
          remove: actions.onRemoveMyTag,
        );
      case PostOption.delete:
        return _delete(context, actions);
    }
  }

  static Future<void> _changeAudience(
    BuildContext context,
    PostOptionsData data,
    PostOptionsActions actions,
  ) async {
    final l10n = context.l10n;
    final audience = await PostVisibilitySheet.change(
      context,
      postId: data.postId,
      audience: data.visibility,
    );
    if (audience == null) return;
    actions.onAudienceChanged(audience);
    Notices.success(l10n.postVisibilityUpdated);
  }

  /// Runs [action] and shows the failure it throws, if any. Returns whether it succeeded.
  static Future<bool> _attempt(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return true;
    } on Failure catch (failure) {
      if (context.mounted) context.showFailure(failure);
      return false;
    }
  }

  static Future<void> _unfollow(
    BuildContext context,
    PostOptionsData data,
    PostOptionsActions actions,
  ) async {
    final l10n = context.l10n;
    if (!await _attempt(context, actions.onUnfollow)) return;
    Notices.info(
      l10n.postUnfollowed(data.username),
      actionLabel: l10n.undo,
      onResult: (acted) {
        if (acted) actions.onUndoUnfollow();
      },
    );
  }

  static Future<void> _mute(
    BuildContext context,
    PostOptionsData data,
    PostOptionsActions actions,
  ) async {
    final l10n = context.l10n;
    if (!await _attempt(context, actions.onMute)) return;
    Notices.info(
      l10n.postMuted(data.username),
      actionLabel: l10n.undo,
      onResult: (acted) {
        if (acted) actions.onUndoMute();
      },
    );
  }

  static Future<void> _report(
    BuildContext context,
    PostOptionsData data,
    PostOptionsActions actions,
  ) async {
    final l10n = context.l10n;
    await ReportSheet.show(
      context,
      copy: ReportCopy(
        title: l10n.postReportTitle,
        body: l10n.postReportBody,
        sentBody: l10n.postReportSent,
        notePlaceholder: l10n.postReportNotePlaceholder,
      ),
      onSubmit: actions.onReport,
      sentRows: [
        ReportSentRow(
          icon: AppAssets.volumeOff,
          title: l10n.postMute(data.username),
          onTap: () => _afterReport(context, actions.onMute, () {
            Notices.info(
              l10n.postMuted(data.username),
              actionLabel: l10n.undo,
              onResult: (acted) {
                if (acted) actions.onUndoMute();
              },
            );
          }),
        ),
        ReportSentRow(
          icon: AppAssets.userMinus,
          title: l10n.postUnfollow(data.username),
          onTap: () => _afterReport(context, actions.onUnfollow, () {
            Notices.info(
              l10n.postUnfollowed(data.username),
              actionLabel: l10n.undo,
              onResult: (acted) {
                if (acted) actions.onUndoUnfollow();
              },
            );
          }),
        ),
      ],
    );
  }

  static Future<void> _afterReport(
    BuildContext context,
    Future<void> Function() action,
    VoidCallback onDone,
  ) async {
    try {
      await action();
    } on Failure catch (failure) {
      if (context.mounted) context.showFailure(failure);
      return;
    }
    onDone();
  }

  static Future<void> _delete(
    BuildContext context,
    PostOptionsActions actions,
  ) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: l10n.postDeleteTitle,
      message: l10n.postDeleteBody,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (confirmed != true || !context.mounted) return;
    actions.onDelete();
    Notices.success(
      l10n.postDeleted,
      actionLabel: l10n.undo,
      onResult: (acted) =>
          acted ? actions.onUndoDelete() : actions.onCommitDelete(),
    );
  }
}
