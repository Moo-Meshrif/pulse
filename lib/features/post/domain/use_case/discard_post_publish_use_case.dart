import 'package:injectable/injectable.dart';

import '../../data/repository/post_publish_repository.dart';

/// Drops the post that failed.
@injectable
class DiscardPostPublishUseCase {
  DiscardPostPublishUseCase(this._publish);

  final PostPublishRepository _publish;

  void call() => _publish.discard();
}
