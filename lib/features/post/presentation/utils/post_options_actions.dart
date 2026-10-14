import 'package:flutter/foundation.dart' show ValueChanged;

import '../../../../core/enums/report_reason.dart';
import '../../../../shared/content/data/enums/content_audience.dart';

/// What the list that opened the options sheet does for each option. A callback that sends something
/// throws a `Failure` when it cannot; the flow shows it. Null means the feature does not exist yet.
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
    required this.onAudienceChanged,
    this.onEditCaption,
  });

  final Future<void> Function() onSave;
  final Future<void> Function() onNotInterested;
  final Future<void> Function() onUnfollow;
  final Future<void> Function() onUndoUnfollow;
  final Future<void> Function() onMute;
  final Future<void> Function() onUndoMute;
  final Future<void> Function(ReportReason reason, String? note) onReport;
  final Future<void> Function() onToggleComments;
  final Future<void> Function() onDelete;

  /// The picker saved a new audience for the post: the list shows it on the card.
  final ValueChanged<ContentAudience> onAudienceChanged;

  /// Edit caption has no page yet (T6).
  final void Function()? onEditCaption;
}
