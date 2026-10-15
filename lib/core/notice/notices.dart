import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'notice.dart';

/// The app's one way to tell the person something that is not part of a screen: a card that drops from
/// the top (`NoticeHost`, in `App`'s builder). Context-free, so a flow can use it after an `await` or once
/// its screen is gone.
///
/// One card at a time: a new notice replaces the current one of the same kind, or waits behind it of
/// another kind (at most [maxQueued] wait; the oldest is dropped). A null [message] shows nothing.
abstract final class Notices {
  static const maxQueued = 2;

  /// Tests turn it off: the time-left bar animates for seconds, so `pumpAndSettle` would run the card
  /// out before the test looks at it.
  static bool autoDismiss = true;

  /// The card on screen, or null. The host listens.
  static final ValueNotifier<Notice?> current = ValueNotifier(null);
  static final List<Notice> _queue = [];

  static void error(
    String? message, {
    String? actionLabel,
    ValueChanged<bool>? onResult,
  }) => _show(NoticeKind.error, message, actionLabel, onResult);

  static void success(
    String? message, {
    String? body,
    String? actionLabel,
    ValueChanged<bool>? onResult,
  }) => _show(NoticeKind.success, message, actionLabel, onResult, body: body);

  /// A neutral message; with an action it is the reversible-action notice ("Undo").
  static void info(
    String? message, {
    String? body,
    String? icon,
    String? actionLabel,
    ValueChanged<bool>? onResult,
  }) => _show(
    NoticeKind.info,
    message,
    actionLabel,
    onResult,
    body: body,
    icon: icon,
  );

  /// Takes [notice] off the screen (timer, swipe, tap or its action, [acted]) and shows the next one
  /// waiting.
  static void dismiss(Notice notice, {bool acted = false}) {
    if (current.value != notice) {
      if (_queue.remove(notice)) notice.onResult?.call(acted);
      return;
    }
    current.value = _queue.isEmpty ? null : _queue.removeAt(0);
    notice.onResult?.call(acted);
  }

  /// Drops everything: the host is gone.
  static void clear() {
    final gone = [?current.value, ..._queue];
    _queue.clear();
    current.value = null;
    for (final notice in gone) {
      notice.onResult?.call(false);
    }
  }

  static void _show(
    NoticeKind kind,
    String? message,
    String? actionLabel,
    ValueChanged<bool>? onResult, {
    String? body,
    String? icon,
  }) {
    if (message == null) return;
    final notice = Notice(
      kind,
      message,
      message: body,
      icon: icon,
      actionLabel: actionLabel,
      onResult: onResult,
    );
    if (kind == NoticeKind.error) HapticFeedback.mediumImpact();
    final shown = current.value;
    if (shown == null || shown.kind == kind) {
      current.value = notice;
      shown?.onResult?.call(false);
      return;
    }
    _queue.add(notice);
    if (_queue.length > maxQueued) _queue.removeAt(0).onResult?.call(false);
  }
}
