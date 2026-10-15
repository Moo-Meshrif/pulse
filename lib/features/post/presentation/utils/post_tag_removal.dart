import 'package:flutter/widgets.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/widgets/widgets.dart';

/// Removing your own tag from someone else's post: one destructive confirm for every way in (the options
/// sheet, your label on a photo, the tagged people sheet), then the result notice.
abstract final class PostTagRemoval {
  /// Asks, then runs [remove] (which puts the tag back and throws a `Failure` when it fails). [ownerName] is
  /// whose post it is.
  static Future<void> confirmAndRemove(
    BuildContext context, {
    required String ownerName,
    required Future<void> Function() remove,
  }) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.userMinus,
      title: l10n.postTagRemoveTitle,
      message: l10n.postTagRemoveBody(ownerName),
      confirmLabel: l10n.postTagRemoveConfirm,
      cancelLabel: l10n.cancel,
    );
    if (confirmed != true) return;
    try {
      await remove();
    } on Failure {
      Notices.error(l10n.postTagRemoveError);
      return;
    }
    Notices.success(l10n.postTagRemoved, body: l10n.postTagRemovedBody);
  }
}
