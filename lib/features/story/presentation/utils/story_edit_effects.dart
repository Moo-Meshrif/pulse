import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../data/model/story_overlay_model.dart';
import '../widgets/story_menus/story_confirm_dialog.dart';
import 'enums/story_edit_notice.dart';

/// What both story edit screens do for the same cases: the message for a [StoryEditNotice] and the
/// "discard this story?" question when leaving.
abstract final class StoryEditEffects {
  static void showNotice(BuildContext context, StoryEditNotice notice) {
    final l10n = context.l10n;
    switch (notice) {
      case StoryEditNotice.uploadBusy:
        Notices.info(l10n.storyUploadBusy);
      case StoryEditNotice.shareFailed:
        Notices.error(l10n.storyShareFailed);
      case StoryEditNotice.saved:
        Notices.success(l10n.storySaved);
      case StoryEditNotice.saveFailed:
        Notices.error(l10n.errorGeneric);
      case StoryEditNotice.stickerLimit:
        Notices.info(l10n.storyStickerLimit(StoryOverlayModel.maxPerStory));
    }
  }

  /// X and system back: nothing is lost without asking.
  static Future<void> discard(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await StoryConfirmDialog.show(
      context,
      title: l10n.storyDiscardTitle,
      body: l10n.storyDiscardBody,
      confirmLabel: l10n.storyDiscard,
      cancelLabel: l10n.storyKeepEditing,
    );
    if (confirmed && context.mounted) AppNavigator.back(context);
  }
}
