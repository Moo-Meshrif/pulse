import 'package:flutter/widgets.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';

/// What the person picked in the long-press menu of a comment; the flow that opened the menu carries it out.
enum CommentOption {
  reply,
  copyText,
  hide,
  report,
  edit,
  delete;

  bool get isDanger => this == report || this == delete;

  String get icon => switch (this) {
    reply => AppAssets.reply,
    copyText => AppAssets.copy,
    hide => AppAssets.eyeOff,
    report => AppAssets.flag,
    edit => AppAssets.edit,
    delete => AppAssets.trash,
  };

  String title(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      reply => l10n.commentReply,
      copyText => l10n.commentsCopyText,
      hide => l10n.commentsHide,
      report => l10n.commentsReport,
      edit => l10n.commentsEdit,
      delete => l10n.commentsDelete,
    };
  }
}
