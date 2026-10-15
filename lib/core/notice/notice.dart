import 'package:flutter/foundation.dart';

enum NoticeKind { error, success, info }

/// One message of the notice card. Identity matters: the card restarts its timer for each new instance.
@immutable
class Notice {
  const Notice(
    this.kind,
    this.title, {
    this.message,
    this.icon,
    this.actionLabel,
    this.onResult,
  });

  final NoticeKind kind;
  final String title;

  /// A second line under [title].
  final String? message;

  /// An icon asset in place of the one of [kind].
  final String? icon;

  /// The one action ("Undo", "Retry", "View"); its tap is reported to [onResult].
  final String? actionLabel;

  /// Runs once when the card goes away: true if its action was tapped, false for anything else (timer,
  /// swipe, tap, replaced, dropped from the queue, host gone). "Undo" acts on true; a deferred delete
  /// commits on false.
  final ValueChanged<bool>? onResult;

  bool get hasAction => actionLabel != null;

  /// 3 s success/info, 4 s error, 5 s with an action.
  Duration get duration => Duration(
    seconds: hasAction
        ? 5
        : kind == NoticeKind.error
        ? 4
        : 3,
  );
}
