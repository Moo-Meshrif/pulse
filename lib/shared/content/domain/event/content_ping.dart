import '../../../../core/utils/equatable.dart';
import '../../data/enums/content_kind.dart';

/// The server says something of [kind] may have changed, sent on the `EventBus`. It carries nothing else:
/// a screen holding items of that kind runs its normal change check.
class ContentPing extends Equatable {
  const ContentPing(this.kind);

  final ContentKind kind;

  @override
  List<Object?> get props => [kind];
}
