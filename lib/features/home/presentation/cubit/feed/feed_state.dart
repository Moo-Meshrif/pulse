import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../../shared/content/data/model/post_count_model.dart';
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

    /// New posts of other people that were found while the person reads further down: they wait here, never
    /// inserted above what is on screen, until the person asks for them (the pill).
    @Default(<FeedPost>[]) List<FeedPost> pendingPosts,

    /// Posts that just arrived on top: they show a soft ring for a moment.
    @Default(<String>{}) Set<String> freshIds,

    /// Posts a change check replaced where they stand: what was done to them on this phone (a like, a save)
    /// no longer applies, the new version has it.
    @Default(<String>{}) Set<String> replacedIds,

    /// The newest counts of the posts on screen, from the last check.
    @Default(<String, PostCountModel>{}) Map<String, PostCountModel> counts,

    /// Why the first load failed.
    Failure? failure,

    /// One-shot: a refresh failed; the posts on screen stay.
    Failure? refreshFailure,
  }) = _FeedState;

  bool get hasMore => nextCursor != null;

  /// The waiting posts of other people: only these show the pill. The person's own wait silently.
  List<FeedPost> get pendingFromOthers =>
      pendingPosts.where((post) => post.entity.authorId != userId).toList();

  FeedMode get mode => switch (status) {
    FeedStatus.initial || FeedStatus.loading => FeedMode.skeleton,
    FeedStatus.failed => FeedMode.failed,
    FeedStatus.ready when posts.every((p) => pendingDeleteIds.contains(p.id)) =>
      FeedMode.empty,
    FeedStatus.ready => FeedMode.content,
  };
}
