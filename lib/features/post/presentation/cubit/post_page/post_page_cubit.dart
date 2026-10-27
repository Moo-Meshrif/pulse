import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../../../follow/domain/use_case/get_follow_status_use_case.dart';
import '../../../../follow/domain/use_case/toggle_follow_use_case.dart';
import '../../../../profile/domain/use_case/get_current_user_id_use_case.dart';
import '../../../data/repository/post_repository.dart';
import '../../../domain/entity/post_entity.dart';
import '../../../domain/event/feed_refresh_requested.dart';
import '../../../domain/event/post_counts_changed.dart';
import '../../../domain/event/post_saved.dart';
import '../../../domain/use_case/sign_post_media_urls_use_case.dart';
import '../../utils/enums/post_page_status.dart';
import '../../utils/feed_post.dart';
import '../../utils/feed_post_signer.dart';
import 'post_page_state.dart';

/// One post on its own page: the post passed in shows at once and is read again. What people do to the
/// post is `PostActionsCubit`'s; this tells the feed about the counts it changed.
@injectable
class PostPageCubit extends BaseCubit<PostPageState>
    with EventCubitMixin<PostPageState> {
  PostPageCubit(
    this._posts,
    SignPostMediaUrlsUseCase signMedia,
    this._getFollow,
    this._toggleFollow,
    this._events,
    GetCurrentUserIdUseCase currentUserId,
    @factoryParam this.postId,
    @factoryParam FeedPost? passed,
  ) : _signer = FeedPostSigner(signMedia),
      super(
        PostPageState(
          status: passed == null
              ? PostPageStatus.loading
              : PostPageStatus.ready,
          post: passed,
          userId: currentUserId(),
        ),
      ) {
    // An edit of this post (from this page's options) shows when it is saved.
    listenTo<PostSaved>((event) {
      if (event.post.id == postId) load();
    });
    // An edit was saved but could not be read back: read this post again.
    listenTo<FeedRefreshRequested>((_) => load());
  }

  final PostRepository _posts;
  final FeedPostSigner _signer;
  final GetFollowStatusUseCase _getFollow;
  final ToggleFollowUseCase _toggleFollow;
  final EventBus _events;
  final String postId;

  @override
  EventBus get events => _events;

  /// Reads the post again (also the retry). A failure keeps what is on screen; with nothing on screen it
  /// is the error tile.
  Future<void> load() {
    final hasPost = state.post != null;
    return run(
      _read,
      loading: hasPost
          ? null
          : state.copyWith(status: PostPageStatus.loading, failure: null),
      onSuccess: (post) {
        if (post == null) {
          return state.copyWith(status: PostPageStatus.unavailable, post: null);
        }
        _loadFollow(post.entity);
        loadLikedBy();
        return state.copyWith(status: PostPageStatus.ready, post: post);
      },
      onFailure: (failure) => hasPost
          ? state.copyWith(failure: failure)
          : state.copyWith(status: PostPageStatus.failed, failure: null),
    );
  }

  Future<FeedPost?> _read() async {
    final entity = await _posts.post(postId);
    return entity == null ? null : (await _signer.sign([entity])).single;
  }

  Future<void> _loadFollow(PostEntity post) async {
    if (post.authorId == state.userId) return;
    try {
      final status = await _getFollow(post.authorId);
      emit(state.copyWith(follow: status));
    } on Object {
      // The chip stays on "Follow"; tapping it asks the server again.
    }
  }

  /// Reads the "Liked by" row again (after the post loads and after a like made here). A failure keeps
  /// the row on screen.
  Future<void> loadLikedBy() async {
    try {
      final likedBy = await _posts.likedByPreview(postId);
      emit(state.copyWith(likedBy: likedBy));
    } on Object {
      // The row stays as it was; it is only a preview of the likes list.
    }
  }

  /// You took your like back: when you were the only one, the row goes at once.
  void youUnliked() {
    if (state.likedBy?.isOnlyMe ?? false) emit(state.copyWith(likedBy: null));
  }

  /// Follow or unfollow the author at once; a failure puts the chip back.
  Future<void> toggleFollow() async {
    final post = state.post?.entity;
    if (post == null) return;
    final before = state.follow ?? FollowStatus.none;
    final follow = before == FollowStatus.none;
    emit(
      state.copyWith(
        follow: follow ? FollowStatus.accepted : FollowStatus.none,
      ),
    );
    await run(
      () => _toggleFollow(post.authorId, follow: follow),
      onSuccess: (status) => state.copyWith(follow: status),
      onFailure: (failure) => state.copyWith(follow: before, failure: failure),
    );
  }

  void countsChanged(PostEntity post, {Future<void>? likeSettled}) => fire(
    PostCountsChanged(
      postId: post.id,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      likedByMe: post.likedByMe,
      savedByMe: post.savedByMe,
      likeSettled: likeSettled,
    ),
  );
}
