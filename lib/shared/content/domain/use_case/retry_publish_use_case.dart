import 'package:injectable/injectable.dart';

import '../../data/enums/content_kind.dart';
import '../../data/repository/content_publish_repository.dart';

/// Sends the failed post, short or story again.
@injectable
class RetryPublishUseCase {
  RetryPublishUseCase(this._publish);

  final ContentPublishRepository _publish;

  void call(ContentKind kind) => _publish.retry(kind);
}
