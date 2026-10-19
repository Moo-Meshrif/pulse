import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../post/domain/entity/feed_cursor_entity.dart';
import '../../utils/enums/feed_mode.dart';
import '../../utils/enums/feed_status.dart';
import '../../utils/feed_post.dart';

part 'feed_state.freezed.dart';

@freezed
abstract class FeedState with _$FeedState {
  const FeedState._();

  const factory FeedState({
    /// The signed-in person, to tell their own posts apart.
    String? userId,
    @Default(FeedStatus.initial) FeedStatus status,
    @Default(<FeedPost>[]) List<FeedPost> posts,

    /// Where the next page starts; null on the last page.
    FeedCursorEntity? nextCursor,
    @Default(false) bool isRefreshing,
    @Default(LoadMoreStatus.idle) LoadMoreStatus loadMore,

    /// Posts whose delete can still be undone: they are not shown, and when they were the last ones the
    /// empty page shows.
    @Default(<String>{}) Set<String> pendingDeleteIds,

    /// Counts the times the posts were replaced (first load, refresh): what was done to the old ones
    /// no longer applies.
    @Default(0) int generation,

    /// Why the first load failed.
    Failure? failure,

    /// One-shot: a refresh failed; the posts on screen stay.
    Failure? refreshFailure,
  }) = _FeedState;

  bool get hasMore => nextCursor != null;

  FeedMode get mode => switch (status) {
    FeedStatus.initial || FeedStatus.loading => FeedMode.skeleton,
    FeedStatus.failed => FeedMode.failed,
    FeedStatus.ready when posts.every((p) => pendingDeleteIds.contains(p.id)) =>
      FeedMode.empty,
    FeedStatus.ready => FeedMode.content,
  };
}
