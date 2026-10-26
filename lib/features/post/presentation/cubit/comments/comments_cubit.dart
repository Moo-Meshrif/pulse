import 'package:injectable/injectable.dart';

import '../../../../../core/enums/report_reason.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../../core/utils/uuid_v4.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/use_case/report_content_use_case.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../../data/datasource/comments_datasource.dart';
import '../../../data/enums/comment_sort.dart';
import '../../../domain/entity/comment_entity.dart';
import '../../../domain/entity/comment_page_entity.dart';
import '../../../domain/use_case/add_comment_use_case.dart';
import '../../../domain/use_case/edit_comment_use_case.dart';
import '../../../domain/use_case/get_comment_replies_use_case.dart';
import '../../../domain/use_case/get_post_comments_use_case.dart';
import '../../utils/comment_drafts.dart';
import '../../utils/comment_edit.dart';
import '../../utils/comment_text.dart';
import '../../utils/enums/comments_status.dart';
import '../../utils/pending_comment.dart';
import 'comments_state.dart';

/// The comments sheet of one post: pages of comments in the chosen order, the rest of a thread's replies,
/// likes shown at once and put back when the request fails, and your own comments: shown while they are
/// sent, kept when they fail so Retry writes them once.
@injectable
class CommentsCubit extends BaseCubit<CommentsState> {
  CommentsCubit(
    this._getComments,
    this._getReplies,
    this._comments,
    this._addComment,
    this._drafts,
    this._editComment,
    this._report,
    GetLastAccountUseCase account,
    @factoryParam this.postId,
    @factoryParam this.focusCommentId,
  ) : me = account(),
      super(const CommentsState());

  final GetPostCommentsUseCase _getComments;
  final GetCommentRepliesUseCase _getReplies;
  final CommentsDatasource _comments;
  final AddCommentUseCase _addComment;
  final CommentDrafts _drafts;
  final EditCommentUseCase _editComment;
  final ReportContentUseCase _report;
  final String postId;

  /// Who is writing, for the composer and the rows being sent; null when this device has no saved account.
  final LastAccountEntity? me;

  /// The comment a link opened; it is first on the first page.
  final String? focusCommentId;

  /// Counts the loads from the top: an answer for an older sort or a reloaded list is dropped.
  int _generation = 0;

  /// Comments with a like request in flight: a second tap waits.
  final _likePending = <String>{};

  /// Comments taken out of the list by Hide, so Undo can put them back where they were.
  final _hidden = <String, RemovedComment>{};
  bool _saving = false;

  /// Loads the first page in the current sort (also the retry). The page saved on the phone for this sort
  /// shows at once and the fresh one replaces it; with nothing saved the skeleton shows.
  Future<void> load() {
    final generation = ++_generation;
    final saved = _saved();
    return run(
      () => _getComments(
        postId,
        sort: state.sort,
        userId: me?.id,
        focusCommentId: focusCommentId,
      ),
      loading: saved == null
          ? state.copyWith(
              status: CommentsStatus.loading,
              comments: const [],
              nextCursor: null,
              more: LoadMoreStatus.idle,
              replies: const {},
            )
          : state.copyWith(
              status: CommentsStatus.ready,
              comments: saved.comments,
              nextCursor: saved.nextCursor,
              more: LoadMoreStatus.idle,
              replies: const {},
            ),
      onSuccess: (page) {
        if (generation != _generation) return null;
        // The fresh page ends any page request that began on the saved one.
        _generation++;
        return state.copyWith(
          status: CommentsStatus.ready,
          comments: page.comments,
          nextCursor: page.nextCursor,
          more: LoadMoreStatus.idle,
          replies: const {},
        );
      },
      // A failure keeps the saved comments on screen.
      onFailure: (_) => generation != _generation || saved != null
          ? null
          : state.copyWith(status: CommentsStatus.failed),
    );
  }

  /// The saved first page of the current sort; null when none, it has no comments, or a link asks for a
  /// comment in focus (that page is never saved).
  CommentPageEntity? _saved() {
    final userId = me?.id;
    if (userId == null || focusCommentId != null) return null;
    final page = _getComments.saved(userId, postId, state.sort);
    return page == null || page.comments.isEmpty ? null : page;
  }

  /// Shows the comments in [sort], from the top.
  Future<void> changeSort(CommentSort sort) {
    if (sort == state.sort) return Future.value();
    emit(state.copyWith(sort: sort));
    return load();
  }

  /// Loads the next page. A failed page waits for [retry] (the list calls this on every scroll).
  Future<void> loadMore({bool retry = false}) {
    final cursor = state.nextCursor;
    final generation = _generation;
    return run(
      () => _getComments(
        postId,
        sort: state.sort,
        before: cursor,
        focusCommentId: focusCommentId,
      ),
      prevent:
          cursor == null ||
          state.status != CommentsStatus.ready ||
          state.more == LoadMoreStatus.loading ||
          (state.more == LoadMoreStatus.failed && !retry),
      loading: state.copyWith(more: LoadMoreStatus.loading),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              comments: [...state.comments, ...page.comments],
              nextCursor: page.nextCursor,
              more: LoadMoreStatus.idle,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(more: LoadMoreStatus.failed),
    );
  }

  /// Loads the next replies of the thread of [comment] (also the retry).
  Future<void> loadMoreReplies(CommentEntity comment) {
    final id = comment.id;
    final generation = _generation;
    return run(
      () => _getReplies(id, after: comment.replies.lastOrNull),
      prevent: state.replies[id] == LoadMoreStatus.loading,
      loading: _withReplyStatus(id, LoadMoreStatus.loading),
      onSuccess: (replies) {
        if (generation != _generation) return null;
        final next = _withReplyStatus(id, null);
        return next.copyWith(
          comments: CommentEdit.update(next.comments, id, (thread) {
            final all = [...thread.replies, ...replies];
            // An empty page means the thread is complete, whatever the count said.
            return thread.copyWith(
              replies: all,
              replyCount: replies.isEmpty ? all.length : thread.replyCount,
            );
          }),
        );
      },
      onFailure: (_) => generation != _generation
          ? null
          : _withReplyStatus(id, LoadMoreStatus.failed),
    );
  }

  /// Likes [comment], or unlikes it when you already liked it.
  Future<void> toggleLike(CommentEntity comment) async {
    final id = comment.id;
    if (!_likePending.add(id)) return;
    final liked = !comment.likedByMe;
    _edit(id, (c) => CommentEdit.liked(c, liked: liked));
    await run(
      () => _comments.setLike(id, liked: liked),
      onSuccess: (count) {
        _likePending.remove(id);
        return state.copyWith(
          failure: null,
          comments: CommentEdit.update(
            state.comments,
            id,
            (c) => c.copyWith(likeCount: count),
          ),
        );
      },
      onFailure: (failure) {
        _likePending.remove(id);
        return state.copyWith(
          failure: failure,
          comments: CommentEdit.update(
            state.comments,
            id,
            (c) => CommentEdit.liked(c, liked: !liked),
          ),
        );
      },
    );
  }

  /// Likes [comment] when you have not yet (a double tap never unlikes).
  Future<void> likeOnly(CommentEntity comment) =>
      comment.likedByMe ? Future.value() : toggleLike(comment);

  /// The text left in the field the last time the sheet closed on this post.
  String get draft => _drafts.read(me?.id ?? '', postId);

  void saveDraft(String text) => _drafts.save(me?.id ?? '', postId, text);

  /// Writes [text] as a comment, or as a reply when a reply is open. It shows at once.
  Future<void> send(String text) {
    final target = state.replyTo;
    if (!CommentText.canSend(text, replyUsername: target?.username)) {
      return Future.value();
    }
    final pending = PendingComment(
      clientId: uuidV4(),
      body: text.trim(),
      parentId: target == null ? null : target.parentId ?? target.id,
    );
    saveDraft('');
    emit(
      state.copyWith(
        pending: [...state.pending, pending],
        replyTo: null,
        failure: null,
      ),
    );
    return _post(pending);
  }

  /// Sends a failed comment again with its first client id.
  Future<void> retry(String clientId) {
    final pending = state.pending.where((p) => p.clientId == clientId);
    if (pending.isEmpty || !pending.first.failed) return Future.value();
    return _post(pending.first);
  }

  /// Drops a failed comment.
  void discardFailed(String clientId) => emit(
    state.copyWith(
      pending: state.pending.where((p) => p.clientId != clientId).toList(),
    ),
  );

  /// Opens a reply to [comment]; a reply to a reply goes to the first comment of its thread.
  void startReply(CommentEntity comment) =>
      emit(state.copyWith(replyTo: comment));

  void cancelReply() => emit(state.copyWith(replyTo: null));

  /// Opens a reply to [comment] and puts [emoji] in the field (the long-press menu).
  void replyWithEmoji(CommentEntity comment, String emoji) {
    emit(state.copyWith(replyTo: comment, editing: null, emoji: emoji));
    emit(state.copyWith(emoji: null));
  }

  /// Puts the words of your [comment] in the field to change them.
  void startEdit(CommentEntity comment) =>
      emit(state.copyWith(editing: comment, replyTo: null));

  void cancelEdit() => emit(state.copyWith(editing: null));

  /// Saves [text] as the words of the comment being edited. Returns whether it saved (or nothing changed).
  Future<bool> saveEdit(String text) async {
    final target = state.editing;
    final body = text.trim();
    if (target == null || _saving || !CommentText.canSend(body)) return false;
    if (body == target.body) {
      cancelEdit();
      return true;
    }
    _saving = true;
    var saved = false;
    await run(
      () => _editComment(target.id, body),
      onSuccess: (comment) {
        saved = true;
        return state.copyWith(
          editing: null,
          comments: CommentEdit.update(
            state.comments,
            target.id,
            (c) => c.copyWith(body: comment.body, editedAt: comment.editedAt),
          ),
        );
      },
      onFailure: (failure) => state.copyWith(failure: failure),
    );
    _saving = false;
    return saved;
  }

  /// Deletes your [comment] (and its replies) at once; the row comes back if the request fails.
  Future<bool> delete(CommentEntity comment) async {
    final removed = CommentEdit.find(state.comments, comment.id);
    if (removed == null) return false;
    final dropped = 1 + (comment.isReply ? 0 : comment.replyCount);
    emit(
      state.copyWith(
        failure: null,
        editing: state.editing?.id == comment.id ? null : state.editing,
        comments: CommentEdit.remove(state.comments, comment.id),
        countDelta: state.countDelta - dropped,
      ),
    );
    var done = true;
    await run(
      () => _comments.deleteComment(comment.id),
      onSuccess: (_) {},
      onFailure: (failure) {
        done = false;
        return state.copyWith(
          failure: failure,
          comments: CommentEdit.restore(state.comments, removed),
          countDelta: state.countDelta + dropped,
        );
      },
    );
    return done;
  }

  /// Hides someone's [comment] on your post: the row goes at once and comes back if the request fails.
  Future<bool> hide(CommentEntity comment) async {
    final removed = CommentEdit.find(state.comments, comment.id);
    if (removed == null) return false;
    _hidden[comment.id] = removed;
    emit(
      state.copyWith(
        failure: null,
        comments: CommentEdit.remove(state.comments, comment.id),
      ),
    );
    var done = true;
    await run(
      () => _comments.hideComment(comment.id, hidden: true),
      onSuccess: (_) {},
      onFailure: (failure) {
        done = false;
        _hidden.remove(comment.id);
        return state.copyWith(
          failure: failure,
          comments: CommentEdit.restore(state.comments, removed),
        );
      },
    );
    return done;
  }

  /// Shows a hidden comment again to everyone. It works after the sheet closed (the id is all it needs).
  Future<void> undoHide(String commentId) async {
    final removed = _hidden[commentId];
    if (removed == null) return;
    await run(
      () => _comments.hideComment(commentId, hidden: false),
      onSuccess: (_) {
        _hidden.remove(commentId);
        if (CommentEdit.contains(state.comments, commentId)) return null;
        return state.copyWith(
          comments: CommentEdit.restore(state.comments, removed),
        );
      },
      onFailure: (failure) => state.copyWith(failure: failure),
    );
  }

  /// Reports [comment]. Throws a `Failure` when it cannot (the report sheet shows it).
  Future<void> report(
    CommentEntity comment,
    ReportReason reason,
    String? note,
  ) => _report(ContentKind.comment, comment.id, reason, note: note);

  Future<void> _post(PendingComment pending) => run(
    () => _addComment(
      postId,
      pending.body,
      parentId: pending.parentId,
      clientId: pending.clientId,
    ),
    loading: _withPending(pending.copyWith(failed: false)),
    onSuccess: (saved) {
      final others = state.pending
          .where((p) => p.clientId != pending.clientId)
          .toList();
      if (CommentEdit.contains(state.comments, saved.id)) {
        return state.copyWith(pending: others);
      }
      return state.copyWith(
        pending: others,
        countDelta: state.countDelta + 1,
        comments: saved.isReply
            ? CommentEdit.addReply(state.comments, saved.parentId!, saved)
            : CommentEdit.prepend(state.comments, saved),
      );
    },
    onFailure: (failure) => _withPending(
      pending.copyWith(failed: true),
      failure: failure is RejectedFailure || failure is NotFoundFailure
          ? failure
          : null,
    ),
  );

  /// The state with [pending] replacing the one with its client id (or added).
  CommentsState _withPending(PendingComment pending, {Failure? failure}) =>
      state.copyWith(
        pending: [
          for (final p in state.pending)
            if (p.clientId == pending.clientId) pending else p,
        ],
        failure: failure,
      );

  void _edit(String id, CommentEntity Function(CommentEntity) change) => emit(
    state.copyWith(
      failure: null,
      comments: CommentEdit.update(state.comments, id, change),
    ),
  );

  /// The state with the reply paging of thread [id] set; null clears it.
  CommentsState _withReplyStatus(String id, LoadMoreStatus? status) {
    final replies = {...state.replies};
    if (status == null) {
      replies.remove(id);
    } else {
      replies[id] = status;
    }
    return state.copyWith(replies: replies);
  }
}
