import 'package:injectable/injectable.dart';

import '../../data/repository/post_publish_repository.dart';
import '../entity/post_publish_status.dart';

/// Fires with the status each time it changes, the current one first. Home shows it above the feed.
@injectable
class WatchPostPublishUseCase {
  WatchPostPublishUseCase(this._publish);

  final PostPublishRepository _publish;

  Stream<PostPublishStatus> call() => _publish.status;
}
