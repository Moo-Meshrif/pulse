import 'package:injectable/injectable.dart';

import '../../../../core/events/event_bus.dart';
import '../../../../core/events/event_cubit_mixin.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../post/domain/entity/post_publish_status.dart';
import '../../../post/domain/use_case/discard_post_publish_use_case.dart';
import '../../../post/domain/use_case/retry_post_publish_use_case.dart';

/// How the post being shared or saved is going, for the banner above the feed.
@injectable
class PostPublishCubit extends BaseCubit<PostPublishStatus>
    with EventCubitMixin<PostPublishStatus> {
  PostPublishCubit(this._events, this._retry, this._discard)
    : super(_events.latest<PostPublishStatus>() ?? const PostPublishIdle());

  final EventBus _events;
  final RetryPostPublishUseCase _retry;
  final DiscardPostPublishUseCase _discard;
  bool _started = false;

  @override
  EventBus get events => _events;

  /// Follows the status; a post already being sent shows from the first frame.
  void start() {
    if (_started) return;
    _started = true;
    syncState<PostPublishStatus>((_, status) => status);
  }

  void retry() => _retry();

  void discard() => _discard();
}
