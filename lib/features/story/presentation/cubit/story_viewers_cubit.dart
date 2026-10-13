import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../../data/datasource/stories_datasource.dart';
import '../utils/enums/story_viewers_status.dart';
import 'story_viewers_state.dart';

/// Who viewed one of your stories, a page at a time.
@injectable
class StoryViewersCubit extends BaseCubit<StoryViewersState> {
  StoryViewersCubit(this._stories) : super(const StoryViewersState());

  /// Viewers per page.
  static const pageSize = 30;

  final StoriesDatasource _stories;

  String? _storyId;
  int _knownTotal = 0;

  Future<void> retry() {
    final id = _storyId;
    return id == null ? Future.value() : load(id, knownTotal: _knownTotal);
  }

  Future<void> load(String storyId, {int knownTotal = 0}) async {
    _storyId = storyId;
    _knownTotal = knownTotal;
    await run(
      () => _stories.getViewers(storyId, limit: pageSize),
      loading: StoryViewersState(total: knownTotal),
      onSuccess: (page) => StoryViewersState(
        status: StoryViewersStatus.ready,
        viewers: page,
        total: page.firstOrNull?.total ?? 0,
        hasMore: page.length >= pageSize,
      ),
      onFailure: (_) => StoryViewersState(
        status: StoryViewersStatus.failed,
        total: knownTotal,
      ),
    );
  }

  Future<void> loadMore() async {
    final id = _storyId;
    final cursor = state.viewers.lastOrNull?.viewedAt;
    if (id == null || !state.hasMore || state.isLoadingMore || cursor == null) {
      return;
    }
    await run(
      () => _stories.getViewers(id, limit: pageSize, before: cursor),
      loading: state.copyWith(isLoadingMore: true, loadMoreFailed: false),
      onSuccess: (page) => state.copyWith(
        viewers: [...state.viewers, ...page],
        hasMore: page.length >= pageSize,
        isLoadingMore: false,
      ),
      onFailure: (_) =>
          state.copyWith(isLoadingMore: false, loadMoreFailed: true),
    );
  }
}
