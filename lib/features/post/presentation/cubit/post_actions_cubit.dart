import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../../../core/enums/report_reason.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/enums/mute_scope.dart';
import '../../../../shared/content/domain/use_case/report_content_use_case.dart';
import '../../../../shared/content/domain/use_case/set_mute_use_case.dart';
import '../../../follow/domain/use_case/toggle_follow_use_case.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/use_case/delete_post_use_case.dart';
import '../../domain/use_case/hide_post_use_case.dart';
import '../../domain/use_case/set_comments_enabled_use_case.dart';
import '../../domain/use_case/set_post_like_use_case.dart';
import '../../domain/use_case/set_post_save_use_case.dart';
import '../utils/enums/post_row.dart';
import '../utils/post_entity_edit.dart';
import 'post_actions_state.dart';

/// What a person does to the posts a screen lists: like and save (shown at once, rolled back when they
/// fail) and the options of the "···" sheet. Every method takes the post as the screen loaded it; the
/// changes made since are applied on top. Home provides one for its feed; the post page can do the same. The option methods throw the `Failure` of a request that failed:
/// the options flow shows it.
@injectable
class PostActionsCubit extends BaseCubit<PostActionsState> {
  PostActionsCubit(
    this._setLike,
    this._setSave,
    this._hidePost,
    this._setCommentsEnabled,
    this._deletePost,
    this._report,
    this._setMute,
    this._toggleFollow,
  ) : super(const PostActionsState());

  final SetPostLikeUseCase _setLike;
  final SetPostSaveUseCase _setSave;
  final HidePostUseCase _hidePost;
  final SetCommentsEnabledUseCase _setCommentsEnabled;
  final DeletePostUseCase _deletePost;
  final ReportContentUseCase _report;
  final SetMuteUseCase _setMute;
  final ToggleFollowUseCase _toggleFollow;

  /// Posts with a like or save request in flight: a second tap on the same post waits for the first.
  final _likePending = <String>{};
  final _savePending = <String>{};

  /// The post with everything done to it since the feed loaded.
  PostEntity postOf(PostEntity loaded) => state.posts[loaded.id] ?? loaded;

  PostRow rowOf(String postId) => state.rows[postId] ?? PostRow.card;

  /// The feed loaded again: what was done to its posts is in the new data.
  void reset() => emit(const PostActionsState());

  Future<void> toggleLike(PostEntity loaded) =>
      setLiked(loaded, liked: !postOf(loaded).likedByMe);

  /// Like only, never unlike: the double tap on the media.
  Future<void> likeByDoubleTap(PostEntity loaded) =>
      setLiked(loaded, liked: true);

  Future<void> setLiked(PostEntity loaded, {required bool liked}) async {
    final before = postOf(loaded);
    if (before.likedByMe == liked || !_likePending.add(loaded.id)) return;
    _emitPost(
      before.copyWith(
        likedByMe: liked,
        likeCount: max(0, before.likeCount + (liked ? 1 : -1)),
      ),
    );
    await run(
      () => _setLike(loaded.id, liked: liked),
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
      () => _setSave(loaded.id, saved: !before.savedByMe),
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
    await _hidePost(loaded.id, hidden: true);
    _emitRow(loaded.id, PostRow.hidden);
  }

  Future<void> undoNotInterested(PostEntity loaded) async {
    await _hidePost(loaded.id, hidden: false);
    _emitRow(loaded.id, PostRow.card);
  }

  /// Their posts leave the feed on its next refresh.
  Future<void> unfollow(PostEntity loaded) =>
      _toggleFollow(loaded.authorId, follow: false);

  Future<void> undoUnfollow(PostEntity loaded) =>
      _toggleFollow(loaded.authorId, follow: true);

  Future<void> mute(PostEntity loaded) =>
      _setMute(loaded.authorId, muted: true, scope: MuteScope.posts);

  Future<void> undoMute(PostEntity loaded) =>
      _setMute(loaded.authorId, muted: false, scope: MuteScope.posts);

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
    await _setCommentsEnabled(loaded.id, enabled: enabled);
    _emitPost(postOf(loaded).copyWith(commentsEnabled: enabled));
  }

  /// Delete, step 1: the card goes at once and the request waits for [commitDelete], so the notice's
  /// Undo can still bring it back.
  void delete(PostEntity loaded) => _emitRow(loaded.id, PostRow.deleting);

  void undoDelete(PostEntity loaded) => _emitRow(loaded.id, PostRow.card);

  /// Delete, step 2: the notice ended without Undo. A failure brings the card back and is shown by the
  /// screen through [PostActionsState.failure].
  Future<void> commitDelete(PostEntity loaded) => run(
    () => _deletePost(loaded.id),
    onSuccess: (_) => state.copyWith(
      rows: {...state.rows, loaded.id: PostRow.removed},
      failure: null,
    ),
    onFailure: (failure) => state.copyWith(
      rows: {...state.rows, loaded.id: PostRow.card},
      failure: failure,
    ),
  );

  /// The audience picker saved a new audience for the post.
  void audienceChanged(PostEntity loaded, ContentAudience audience) =>
      _emitPost(postOf(loaded).copyWith(visibility: audience));

  PostActionsState _withPost(PostEntity post, {Failure? failure}) =>
      state.copyWith(posts: {...state.posts, post.id: post}, failure: failure);

  void _emitPost(PostEntity post) => emit(_withPost(post));

  void _emitRow(String postId, PostRow row) =>
      emit(state.copyWith(rows: {...state.rows, postId: row}, failure: null));
}
