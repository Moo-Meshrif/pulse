import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/entity/content_publish_status.dart';
import '../../../../../shared/content/domain/use_case/discard_publish_use_case.dart';
import '../../../../../shared/content/domain/use_case/get_publish_status_use_case.dart';
import '../../../../../shared/content/domain/use_case/retry_publish_use_case.dart';

/// How the post being shared or saved is going, for the banner above the feed.
@injectable
class PostPublishCubit extends BaseCubit<ContentPublishStatus>
    with EventCubitMixin<ContentPublishStatus> {
  PostPublishCubit(
    this._events,
    GetPublishStatusUseCase status,
    this._retry,
    this._discard,
  ) : super(status(ContentKind.post));

  final EventBus _events;
  final RetryPublishUseCase _retry;
  final DiscardPublishUseCase _discard;
  bool _started = false;

  @override
  EventBus get events => _events;

  /// Follows the status; a post already being sent shows from the first frame.
  void start() {
    if (_started) return;
    _started = true;
    syncState<ContentPublishStatus>(
      (_, status) => status.kind == ContentKind.post ? status : null,
    );
  }

  void retry() => _retry(ContentKind.post);

  void discard() => _discard(ContentKind.post);
}
