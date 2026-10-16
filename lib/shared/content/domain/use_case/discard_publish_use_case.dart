import 'package:injectable/injectable.dart';

import '../../data/enums/content_kind.dart';
import '../../data/repository/content_publish_repository.dart';

/// Drops the failed post, short or story.
@injectable
class DiscardPublishUseCase {
  DiscardPublishUseCase(this._publish);

  final ContentPublishRepository _publish;

  void call(ContentKind kind) => _publish.discard(kind);
}
