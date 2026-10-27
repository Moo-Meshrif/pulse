import 'dart:async';
import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../../../../core/enums/report_reason.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/data/enums/mute_scope.dart';
import '../../../../../shared/content/data/model/post_count_model.dart';
import '../../../../../shared/content/domain/use_case/report_content_use_case.dart';
import '../../../../../shared/content/domain/use_case/set_mute_use_case.dart';
import '../../../../follow/domain/use_case/toggle_follow_use_case.dart';
import '../../../data/repository/post_repository.dart';
import '../../../domain/entity/post_entity.dart';
import '../../utils/enums/post_row.dart';
import '../../utils/post_entity_edit.dart';
import 'post_actions_state.dart';

/// What a person does to the posts a screen lists: like and save (shown at once, rolled back on failure)
/// and the options of the "···" sheet. Every method takes the post as the screen loaded it; changes made
/// since are applied on top. The option methods throw the `Failure` of a failed request for the options
/// flow to show.
@injectable
class PostActionsCubit extends BaseCubit<PostActionsState> {
  PostActionsCubit(this._posts, this._report, this._setMute, this._toggleFollow)
    : super(const PostActionsState());

  final PostRepository _posts;
  final ReportContentUseCase _report;
  final SetMuteUseCase _setMute;
  final ToggleFollowUseCase _toggleFollow;

  /// A second tap on a post waits for the first request.
  final _likePending = <String>{};
  final _savePending = <String>{};
  final _likeRuns = <String, Future<void>>{};

  /// How long the "Post hidden" row keeps its Undo before the row goes.
  static const hiddenUndoWindow = Duration(seconds: 5);

  final _hiddenTimers = <String, Timer>{};

  /// The post with everything done to it since the feed loaded.
  PostEntity postOf(PostEntity loaded) => state.posts[loaded.id] ?? loaded;

  PostRow rowOf(String postId) => state.rows[postId] ?? PostRow.card;

  /// The feed loaded again: what was done to its posts is in the new data.
  void reset() {
    _cancelHiddenTimers();
    emit(const PostActionsState());
  }

  /// The screen replaced these posts with newer versions: what was done to them here is in the new data.
  void forget(Set<String> ids) {
    if (!ids.any(state.posts.containsKey)) return;
    emit(
      state.copyWith(
        posts: {
          for (final entry in state.posts.entries)
            if (!ids.contains(entry.key)) entry.key: entry.value,
        },
      ),
    );
  }

  /// Puts the newest like and comment counts on the [loaded] posts. A post whose like request is still in
  /// flight keeps its own count until the request ends.
  void applyCounts(
    List<PostEntity> loaded,
    Map<String, PostCountModel> counts,
  ) {
    final changed = <String, PostEntity>{};
    for (final post in loaded) {
      final count = counts[post.id];
      if (count == null || _likePending.contains(post.id)) continue;
      final now = postOf(post);
      final likes = count.likeCount ?? now.likeCount;
      final comments = count.commentCount ?? now.commentCount;
      final liked = count.likedByMe ?? now.likedByMe;
      final saved = count.savedByMe ?? now.savedByMe;
      if (likes == now.likeCount &&
          comments == now.commentCount &&
          liked == now.likedByMe &&
          saved == now.savedByMe) {
        continue;
      }
      changed[post.id] = now.copyWith(
        likeCount: likes,
        commentCount: comments,
        likedByMe: liked,
        savedByMe: saved,
      );
    }
    if (changed.isEmpty) return;
    emit(state.copyWith(posts: {...state.posts, ...changed}));
  }

  void _cancelHiddenTimers() {
    for (final timer in _hiddenTimers.values) {
      timer.cancel();
    }
    _hiddenTimers.clear();
  }

  @override
  Future<void> close() {
    _cancelHiddenTimers();
    return super.close();
  }

  Future<void> toggleLike(PostEntity loaded) =>
      setLiked(loaded, liked: !postOf(loaded).likedByMe);

  /// Like only, never unlike: the double tap on the media.
  Future<void> likeByDoubleTap(PostEntity loaded) =>
      setLiked(loaded, liked: true);

  /// Ends when the like request of [postId] in flight ends (at once when there is none).
  Future<void> likeSettled(String postId) =>
      _likeRuns[postId] ?? Future.value();

  Future<void> setLiked(PostEntity loaded, {required bool liked}) {
    if (_likePending.contains(loaded.id)) return Future.value();
    final run = _setLikedNow(loaded, liked: liked);
    _likeRuns[loaded.id] = run;
    return run;
  }

  Future<void> _setLikedNow(PostEntity loaded, {required bool liked}) async {
    final before = postOf(loaded);
    if (before.likedByMe == liked || !_likePending.add(loaded.id)) return;
    _emitPost(
      before.copyWith(
        likedByMe: liked,
        likeCount: max(0, before.likeCount + (liked ? 1 : -1)),
      ),
    );
    await run(
      () => _posts.setLike(loaded.id, liked: liked),
      onSuccess: (count) {
        _likePending.remove(loaded.id);
        return _withPost(postOf(loaded).copyWith(likeCount: count));
      },
      onFailure: (failure) {
        _likePending.remove(loaded.id);
        return _withPost(before, failure: failure);
      },
    );
  }

  Future<void> toggleSave(PostEntity loaded) async {
    final before = postOf(loaded);
    if (!_savePending.add(loaded.id)) return;
    _emitPost(before.copyWith(savedByMe: !before.savedByMe));
    await run(
      () => _posts.setSave(loaded.id, saved: !before.savedByMe),
      onSuccess: (saved) {
        _savePending.remove(loaded.id);
        return _withPost(postOf(loaded).copyWith(savedByMe: saved));
      },
      onFailure: (failure) {
        _savePending.remove(loaded.id);
        return _withPost(before, failure: failure);
      },
    );
  }

  /// "Not interested": the card becomes the hidden row.
  Future<void> notInterested(PostEntity loaded) async {
    await _posts.hidePost(loaded.id, hidden: true);
    _emitRow(loaded.id, PostRow.hidden);
    _hiddenTimers[loaded.id]?.cancel();
    _hiddenTimers[loaded.id] = Timer(hiddenUndoWindow, () {
      _hiddenTimers.remove(loaded.id);
      if (rowOf(loaded.id) == PostRow.hidden) {
        _emitRow(loaded.id, PostRow.removed);
      }
    });
  }

  Future<void> undoNotInterested(PostEntity loaded) async {
    _hiddenTimers.remove(loaded.id)?.cancel();
    await _posts.hidePost(loaded.id, hidden: false);
    _emitRow(loaded.id, PostRow.card);
  }

  /// Their posts leave the feed on its next refresh.
  Future<void> unfollow(PostEntity loaded) =>
      _toggleFollow(loaded.authorId, follow: false);

  Future<void> undoUnfollow(PostEntity loaded) =>
      _toggleFollow(loaded.authorId, follow: true);

  /// Their posts leave the feed at once.
  Future<void> mute(PostEntity loaded) async {
    await _setMute(loaded.authorId, muted: true, scope: MuteScope.posts);
    emit(
      state.copyWith(
        mutedAuthors: {...state.mutedAuthors, loaded.authorId},
        failure: null,
      ),
    );
  }

  Future<void> undoMute(PostEntity loaded) async {
    await _setMute(loaded.authorId, muted: false, scope: MuteScope.posts);
    emit(
      state.copyWith(
        mutedAuthors: {...state.mutedAuthors}..remove(loaded.authorId),
        failure: null,
      ),
    );
  }

  /// Reported: the server hides the post for the reporter and the card goes.
  Future<void> report(
    PostEntity loaded,
    ReportReason reason,
    String? note,
  ) async {
    await _report(ContentKind.post, loaded.id, reason, note: note);
    _emitRow(loaded.id, PostRow.removed);
  }

  Future<void> toggleComments(PostEntity loaded) async {
    final enabled = !postOf(loaded).commentsEnabled;
    await _posts.setCommentsEnabled(loaded.id, enabled: enabled);
    _emitPost(postOf(loaded).copyWith(commentsEnabled: enabled));
  }

  /// The comments sheet of [loaded] added or removed comments: the card shows [count].
  void commentCountChanged(PostEntity loaded, int count) {
    final now = postOf(loaded);
    if (now.commentCount != count) _emitPost(now.copyWith(commentCount: count));
  }

  /// The card goes at once; the request waits for [commitDelete] so Undo can bring it back.
  void delete(PostEntity loaded) => _emitRow(loaded.id, PostRow.deleting);

  void undoDelete(PostEntity loaded) => _emitRow(loaded.id, PostRow.card);

  /// The notice ended without Undo. A failure brings the card back and shows in [PostActionsState.failure].
  Future<void> commitDelete(PostEntity loaded) => run(
    () => _posts.deletePost(loaded.id),
    onSuccess: (_) => state.copyWith(
      rows: {...state.rows, loaded.id: PostRow.removed},
      failure: null,
    ),
    onFailure: (failure) => state.copyWith(
      rows: {...state.rows, loaded.id: PostRow.card},
      failure: failure,
    ),
  );

  /// Takes [userId]'s tag off the post at once; it comes back if the request fails. A tag already gone
  /// counts as removed.
  Future<void> removeMyTag(PostEntity loaded, {required String userId}) async {
    final before = postOf(loaded);
    _emitPost(before.withoutTag(userId));
    try {
      await _posts.removeMyTag(loaded.id);
    } catch (_) {
      _emitPost(before);
      rethrow;
    }
  }

  /// The audience picker saved a new audience for the post.
  void audienceChanged(PostEntity loaded, ContentAudience audience) =>
      _emitPost(postOf(loaded).copyWith(visibility: audience));

  PostActionsState _withPost(PostEntity post, {Failure? failure}) =>
      state.copyWith(posts: {...state.posts, post.id: post}, failure: failure);

  void _emitPost(PostEntity post) => emit(_withPost(post));

  void _emitRow(String postId, PostRow row) =>
      emit(state.copyWith(rows: {...state.rows, postId: row}, failure: null));
}
