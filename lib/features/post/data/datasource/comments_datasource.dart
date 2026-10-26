import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/comment_sort.dart';
import '../model/comment_model.dart';
import '../model/comment_page_model.dart';
import '../model/mention_person_model.dart';

/// Comments and replies on a post: reading, writing, liking, and what the post owner and the writer do
/// to them. Reporting a comment is the shared `ContentActionsDatasource` with `ContentKind.comment`.
/// Every call throws a `Failure` on error: a [NotFoundFailure] when the post or comment is gone or not
/// visible, a [RejectedFailure] when the server refuses it for good (comments are off, bad words).
abstract interface class CommentsDatasource {
  /// A page of top-level comments, each with its first replies. Pass the previous page's cursor as
  /// [beforeRank], [beforeCreated] and [beforeId] for the next one. [focusCommentId] puts that comment (or
  /// its thread) first on the first page; pass it on every page so it is never listed twice.
  Future<CommentPageModel> getComments(
    String postId, {
    required CommentSort sort,
    required int limit,
    int? beforeRank,
    DateTime? beforeCreated,
    String? beforeId,
    String? focusCommentId,
  });

  /// The replies of a top-level comment after the reply made at [afterCreated] with id [afterId], oldest
  /// first.
  Future<List<CommentModel>> getReplies(
    String commentId, {
    required int limit,
    DateTime? afterCreated,
    String? afterId,
  });

  /// Writes a comment, or a reply when [parentId] is set (a reply to a reply goes to its top-level
  /// comment). The same [clientId] writes once, so a retry is safe; the answer is the comment as written.
  Future<CommentModel> addComment(
    String postId,
    String body, {
    String? parentId,
    String? clientId,
  });

  /// Changes the words of your own comment.
  Future<CommentModel> editComment(String commentId, String body);

  /// Deletes your own comment and its replies.
  Future<void> deleteComment(String commentId);

  /// Hides someone's comment on your post ([hidden]) or brings it back (Undo).
  Future<void> hideComment(String commentId, {required bool hidden});

  /// Likes or unlikes a comment; returns its like count afterwards.
  Future<int> setLike(String commentId, {required bool liked});

  /// Up to [limit] people to suggest while typing `@query`.
  Future<List<MentionPersonModel>> getMentionCandidates(
    String postId,
    String query, {
    int limit = 3,
  });
}

/// [CommentsDatasource] as an adapter over Supabase: `post_comments`, `comment_replies`, `add_comment`,
/// `edit_comment`, `delete_comment`, `hide_comment`, `set_comment_like`, `comment_mention_candidates`.
@LazySingleton(as: CommentsDatasource)
final class SupabaseCommentsDatasource implements CommentsDatasource {
  SupabaseCommentsDatasource(this._client);

  /// What the functions raise for a post or comment that is gone or not visible.
  static const _unavailable = 'P0002';

  /// What `add_comment` raises for comments that are off and for words it refuses.
  static const _refused = '22023';

  final SupabaseClient _client;

  @override
  Future<CommentPageModel> getComments(
    String postId, {
    required CommentSort sort,
    required int limit,
    int? beforeRank,
    DateTime? beforeCreated,
    String? beforeId,
    String? focusCommentId,
  }) => _call(
    'post_comments',
    {
      'p_post': postId,
      'p_sort': sort.wire,
      'p_limit': limit,
      'p_before_rank': ?beforeRank,
      if (beforeCreated != null)
        'p_before_time': beforeCreated.toUtc().toIso8601String(),
      'p_before_id': ?beforeId,
      'p_focus': ?focusCommentId,
    },
    (rows) {
      final comments = _comments(rows);
      // The focus row is not part of the paging, so the cursor is the last of the others.
      final paged = [
        for (final comment in comments)
          if (comment.isFocus != true) comment,
      ];
      final last = paged.length < limit ? null : paged.last;
      return CommentPageModel(
        comments: comments,
        nextRank: last?.rank,
        nextCreated: last?.createdAt,
        nextId: last?.id,
      );
    },
  );

  @override
  Future<List<CommentModel>> getReplies(
    String commentId, {
    required int limit,
    DateTime? afterCreated,
    String? afterId,
  }) => _call('comment_replies', {
    'p_comment': commentId,
    'p_limit': limit,
    if (afterCreated != null)
      'p_before_time': afterCreated.toUtc().toIso8601String(),
    'p_before_id': ?afterId,
  }, _comments);

  @override
  Future<CommentModel> addComment(
    String postId,
    String body, {
    String? parentId,
    String? clientId,
  }) => _call('add_comment', {
    'p_post': postId,
    'p_body': body,
    'p_parent': ?parentId,
    'p_client_id': ?clientId,
  }, _comment);

  @override
  Future<CommentModel> editComment(String commentId, String body) =>
      _call('edit_comment', {'p_comment': commentId, 'p_body': body}, _comment);

  @override
  Future<void> deleteComment(String commentId) =>
      _call('delete_comment', {'p_comment': commentId}, (_) {});

  @override
  Future<void> hideComment(String commentId, {required bool hidden}) => _call(
    'hide_comment',
    {'p_comment': commentId, 'p_hidden': hidden},
    (_) {},
  );

  @override
  Future<int> setLike(String commentId, {required bool liked}) => _call(
    'set_comment_like',
    {'p_comment': commentId, 'p_liked': liked},
    (count) => JsonMapper.integer(count) ?? 0,
  );

  @override
  Future<List<MentionPersonModel>> getMentionCandidates(
    String postId,
    String query, {
    int limit = 3,
  }) => _call(
    'comment_mention_candidates',
    {'p_post': postId, 'p_query': query, 'p_limit': limit},
    (rows) =>
        JsonMapper.list(
          rows,
          (item) => item is Map<String, dynamic>
              ? MentionPersonModel.fromJson(item)
              : null,
        ) ??
        const [],
  );

  /// Calls [function], reads the answer with [parse], and turns the server's two refusals into failures.
  Future<T> _call<T>(
    String function,
    Map<String, dynamic> params,
    T Function(dynamic answer) parse,
  ) => Guard.run(() async {
    try {
      return parse(await _client.rpc<dynamic>(function, params: params));
    } on PostgrestException catch (error) {
      if (error.code == _unavailable) throw NotFoundException(function);
      if (error.code == _refused) throw const RejectedFailure();
      rethrow;
    }
  });

  CommentModel _comment(dynamic answer) =>
      CommentModel.fromJson(Map<String, dynamic>.from(answer as Map));

  List<CommentModel> _comments(dynamic answer) =>
      JsonMapper.list(
        answer,
        (item) =>
            item is Map<String, dynamic> ? CommentModel.fromJson(item) : null,
      ) ??
      const [];
}
