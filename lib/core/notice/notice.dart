import 'package:flutter/foundation.dart';

enum NoticeKind { error, success, info }

/// One message of the notice card. Identity matters: the card restarts its timer for each new instance.
@immutable
class Notice {
  const Notice(this.kind, this.title, {this.actionLabel, this.onAction});

  final NoticeKind kind;
  final String title;

  /// The one action ("Undo", "Retry", "View"); shown only with both fields.
  final String? actionLabel;
  final VoidCallback? onAction;

  bool get hasAction => actionLabel != null && onAction != null;

  /// 3 s success/info, 4 s error, 5 s with an action.
  Duration get duration => Duration(
    seconds: hasAction
        ? 5
        : kind == NoticeKind.error
        ? 4
        : 3,
  );
}
