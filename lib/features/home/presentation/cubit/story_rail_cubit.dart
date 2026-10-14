import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../../../post/domain/use_case/watch_feed_refresh_requests_use_case.dart';
import '../../../story/domain/entity/story_upload_status.dart';
import '../../../story/domain/use_case/get_story_rail_use_case.dart';
import '../../../story/domain/use_case/retry_story_upload_use_case.dart';
import '../../../story/domain/use_case/watch_story_rail_changes_use_case.dart';
import '../../../story/domain/use_case/watch_story_upload_use_case.dart';
import 'story_rail_state.dart';

/// The Stories rail of Home: the people with a story, and how posting your own is going.
@injectable
class StoryRailCubit extends BaseCubit<StoryRailState> {
  StoryRailCubit(
    this._rail,
    this._railChanges,
    this._uploadStatus,
    this._retryUpload,
    this._refreshRequests,
  ) : super(const StoryRailState());

  final GetStoryRailUseCase _rail;
  final WatchStoryRailChangesUseCase _railChanges;
  final WatchStoryUploadUseCase _uploadStatus;
  final RetryStoryUploadUseCase _retryUpload;
  final WatchFeedRefreshRequestsUseCase _refreshRequests;

  final _subscriptions = <StreamSubscription<Object?>>[];
  bool _isLoading = false;
  bool _reloadAgain = false;

  /// Loads the rail and keeps it current: a mute or delete reloads it, and so does a story that finished
  /// posting or a refresh of Home.
  Future<void> start() {
    _subscriptions
      ..add(_railChanges().listen((_) => load()))
      ..add(_uploadStatus().listen(_onUpload))
      ..add(_refreshRequests().listen((_) => load()));
    return load();
  }

  /// A change that comes in while loading runs one more load after it. A load that fails leaves the rail
  /// as it is.
  Future<void> load() async {
    if (_isLoading) {
      _reloadAgain = true;
      return;
    }
    _isLoading = true;
    do {
      _reloadAgain = false;
      await run(
        _rail.call,
        onSuccess: (items) => state.copyWith(items: items),
        onFailure: (_) => null,
      );
    } while (_reloadAgain && !isClosed);
    _isLoading = false;
  }

  void retryUpload() => _retryUpload();

  void _onUpload(StoryUploadStatus status) {
    emit(state.copyWith(upload: status));
    if (status is StoryUploadDone) load();
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
