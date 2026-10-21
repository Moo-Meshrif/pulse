import '../../../../core/utils/equatable.dart';
import '../../data/enums/content_kind.dart';

/// What changed in posts, shorts or stories since the last check, sent on the `EventBus`. A screen
/// holding items of [kind] replaces the ones in [upsertedIds] (read them again), drops the ones in
/// [removedIds] and ignores the rest. [mustReload] says the phone was away too long (or too far behind):
/// load normally instead. Every change is safe to apply twice.
class ContentChanged extends Equatable {
  const ContentChanged(
    this.kind, {
    this.upsertedIds = const [],
    this.removedIds = const [],
    this.mustReload = false,
  });

  final ContentKind kind;
  final List<String> upsertedIds;
  final List<String> removedIds;
  final bool mustReload;

  @override
  List<Object?> get props => [kind, upsertedIds, removedIds, mustReload];
}
