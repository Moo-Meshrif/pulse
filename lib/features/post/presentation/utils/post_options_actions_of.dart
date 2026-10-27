import 'package:flutter/foundation.dart' show VoidCallback;

import '../../domain/entity/post_entity.dart';
import '../cubit/post_actions/post_actions_cubit.dart';
import 'post_options_actions.dart';

/// The options sheet's callbacks for [loaded], done by [actions]. The list that opens the sheet gives what
/// only it knows: the edit screen, the tag removal and the Share sheet. They use [actions] and [loaded]
/// taken now, never a context, because a delete's Undo runs after the card is gone.
PostOptionsActions postOptionsActionsOf(
  PostActionsCubit actions,
  PostEntity loaded, {
  required VoidCallback onEdit,
  required Future<void> Function() onRemoveMyTag,
  required VoidCallback onShare,
}) => PostOptionsActions(
  onSave: () => actions.toggleSave(loaded),
  onNotInterested: () => actions.notInterested(loaded),
  onUnfollow: () => actions.unfollow(loaded),
  onUndoUnfollow: () => actions.undoUnfollow(loaded),
  onMute: () => actions.mute(loaded),
  onUndoMute: () => actions.undoMute(loaded),
  onReport: (reason, note) => actions.report(loaded, reason, note),
  onToggleComments: () => actions.toggleComments(loaded),
  onDelete: () => actions.delete(loaded),
  onUndoDelete: () => actions.undoDelete(loaded),
  onCommitDelete: () => actions.commitDelete(loaded),
  onAudienceChanged: (audience) => actions.audienceChanged(loaded, audience),
  onEdit: onEdit,
  onRemoveMyTag: onRemoveMyTag,
  onShare: onShare,
);
