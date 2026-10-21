import 'package:flutter/foundation.dart' show ValueChanged, VoidCallback;

import '../../../../core/enums/report_reason.dart';
import '../../../../shared/content/data/enums/content_audience.dart';

/// What the list that opened the options sheet does for each option. A callback that sends something
/// throws a `Failure` when it cannot; the flow shows it.
class PostOptionsActions {
  const PostOptionsActions({
    required this.onSave,
    required this.onNotInterested,
    required this.onUnfollow,
    required this.onUndoUnfollow,
    required this.onMute,
    required this.onUndoMute,
    required this.onReport,
    required this.onToggleComments,
    required this.onDelete,
    required this.onUndoDelete,
    required this.onCommitDelete,
    required this.onAudienceChanged,
    required this.onEdit,
    required this.onRemoveMyTag,
    required this.onShare,
  });

  final Future<void> Function() onSave;
  final Future<void> Function() onNotInterested;
  final Future<void> Function() onUnfollow;
  final Future<void> Function() onUndoUnfollow;
  final Future<void> Function() onMute;
  final Future<void> Function() onUndoMute;
  final Future<void> Function(ReportReason reason, String? note) onReport;
  final Future<void> Function() onToggleComments;

  /// Delete is in two steps so it can be undone: the card goes at once, and the request is sent when the
  /// notice ends without Undo.
  final VoidCallback onDelete;
  final VoidCallback onUndoDelete;
  final VoidCallback onCommitDelete;

  /// The picker saved a new audience for the post: the list shows it on the card.
  final ValueChanged<ContentAudience> onAudienceChanged;

  /// Opens the edit screen of the post; saving there reloads the feed.
  final VoidCallback onEdit;

  /// Takes your tag off the post at once; throws a `Failure` (after putting the tag back) when it fails.
  final Future<void> Function() onRemoveMyTag;

  /// Opens the Share sheet of the post (the Share tile only exists where the sheet has something to offer).
  final VoidCallback onShare;
}
