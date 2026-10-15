import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../../../post/domain/entity/post_publish_status.dart';
import '../../../post/domain/use_case/discard_post_publish_use_case.dart';
import '../../../post/domain/use_case/retry_post_publish_use_case.dart';
import '../../../post/domain/use_case/watch_post_publish_use_case.dart';

/// How the post being shared or saved is going, for the banner above the feed.
@injectable
class PostPublishCubit extends BaseCubit<PostPublishStatus> {
  PostPublishCubit(this._watch, this._retry, this._discard)
    : super(const PostPublishIdle());

  final WatchPostPublishUseCase _watch;
  final RetryPostPublishUseCase _retry;
  final DiscardPostPublishUseCase _discard;
  StreamSubscription<PostPublishStatus>? _status;

  void start() => _status ??= _watch().listen(emit);

  void retry() => _retry();

  void discard() => _discard();

  @override
  Future<void> close() async {
    await _status?.cancel();
    return super.close();
  }
}
