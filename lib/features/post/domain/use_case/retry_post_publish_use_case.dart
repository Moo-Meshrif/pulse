import 'package:injectable/injectable.dart';

import '../../data/repository/post_publish_repository.dart';

/// Sends the post that failed again.
@injectable
class RetryPostPublishUseCase {
  RetryPostPublishUseCase(this._publish);

  final PostPublishRepository _publish;

  void call() => _publish.retry();
}
