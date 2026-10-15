import '../../../../core/utils/equatable.dart';
import '../../data/enums/content_kind.dart';

enum ContentDeleteStage {
  /// Hidden from the screens, but the delete can still be undone.
  pending,

  /// Undone, or the request failed: the content is back.
  restored,

  /// The request went through: the content is gone.
  deleted,
}

/// Your content going through a delete that can be undone, sent on the `EventBus`.
class ContentDeleteEvent extends Equatable {
  const ContentDeleteEvent(this.kind, this.id, this.stage);

  final ContentKind kind;
  final String id;
  final ContentDeleteStage stage;

  @override
  List<Object?> get props => [kind, id, stage];
}
