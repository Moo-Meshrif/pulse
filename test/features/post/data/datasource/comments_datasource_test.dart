import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/datasource/comments_datasource.dart';
import 'package:pulse/features/post/data/enums/comment_sort.dart';

import '../../../../helpers/backend_double.dart';
import '../../../../helpers/failure_of.dart';

void main() {
  Future<BackendDouble> signedIn(
    Future<http.Response> Function(http.Request request) handler,
  ) async {
    final backend = BackendDouble((request) {
      if (request.url.path.endsWith('/token')) {
        return Future.value(BackendDouble.sessionResponse());
      }
      return handler(request);
    });
    await backend.signIn();
    return backend;
  }

  Map<String, dynamic> body(http.Request request) =>
      jsonDecode(request.body) as Map<String, dynamic>;

  Map<String, dynamic> row(
    String id, {
    int rank = 0,
    bool focus = false,
    String? parentId,
  }) => {
    'id': id,
    'post_id': 'p1',
    'parent_id': parentId,
    'author_id': 'u1',
    'username': 'sara',
    'body': 'hello',
    'created_at': '2026-10-25T10:00:00Z',
    'like_count': 2,
    'liked_by_me': true,
    'is_post_author': false,
    'reply_count': 1,
    'is_focus': focus,
    'rank': rank,
    'replies': [
      {
        'id': '$id-r',
        'post_id': 'p1',
        'parent_id': id,
        'author_id': 'u2',
        'username': 'omar',
        'body': 'hi',
        'created_at': '2026-10-25T10:05:00Z',
      },
    ],
  };

  group('getComments', () {
    test('sends the paging and focus parameters and reads the rows', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([row('c1', rank: 2)]),
      );
      final comments = SupabaseCommentsDatasource(backend.client);

      final page = await comments.getComments(
        'p1',
        sort: CommentSort.newest,
        limit: 20,
        beforeRank: 1,
        beforeCreated: DateTime.utc(2026, 10, 25, 9),
        beforeId: 'c0',
        focusCommentId: 'c9',
      );

      expect(body(backend.to('/rpc/post_comments').single), {
        'p_post': 'p1',
        'p_sort': 'newest',
        'p_limit': 20,
        'p_before_rank': 1,
        'p_before_time': '2026-10-25T09:00:00.000Z',
        'p_before_id': 'c0',
        'p_focus': 'c9',
      });
      final comment = page.comments.single;
      expect(comment.id, 'c1');
      expect(comment.likedByMe, isTrue);
      expect(comment.replyCount, 1);
      expect(comment.replies?.single.parentId, 'c1');
    });

    test('a first page sends no cursor and no focus', () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      final comments = SupabaseCommentsDatasource(backend.client);

      await comments.getComments('p1', sort: CommentSort.relevant, limit: 20);

      expect(body(backend.to('/rpc/post_comments').single), {
        'p_post': 'p1',
        'p_sort': 'relevant',
        'p_limit': 20,
      });
    });

    test(
      'a full page gives the cursor of its last row, the focus row not counted',
      () async {
        final backend = await signedIn(
          (_) async => BackendDouble.json([
            row('focus', rank: 3, focus: true),
            row('c1', rank: 2),
            row('c2', rank: 1),
          ]),
        );
        final comments = SupabaseCommentsDatasource(backend.client);

        final page = await comments.getComments(
          'p1',
          sort: CommentSort.relevant,
          limit: 2,
        );

        expect(page.nextId, 'c2');
        expect(page.nextRank, 1);
        expect(page.nextCreated, DateTime.utc(2026, 10, 25, 10));
      },
    );

    test('a short page has no cursor', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([row('focus', focus: true), row('c1')]),
      );
      final comments = SupabaseCommentsDatasource(backend.client);

      final page = await comments.getComments(
        'p1',
        sort: CommentSort.relevant,
        limit: 2,
      );

      expect(page.nextId, isNull);
      expect(page.nextRank, isNull);
    });

    test('a post that is gone is a NotFoundFailure', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.postgrestError(400, 'P0002'),
      );
      final comments = SupabaseCommentsDatasource(backend.client);

      expect(
        await failureOf(
          comments.getComments('p1', sort: CommentSort.relevant, limit: 20),
        ),
        isA<NotFoundFailure>(),
      );
    });
  });

  test('getReplies sends the cursor after the last reply', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([row('r2', parentId: 'c1')]),
    );
    final comments = SupabaseCommentsDatasource(backend.client);

    final replies = await comments.getReplies(
      'c1',
      limit: 20,
      afterCreated: DateTime.utc(2026, 10, 25, 10, 5),
      afterId: 'r1',
    );

    expect(body(backend.to('/rpc/comment_replies').single), {
      'p_comment': 'c1',
      'p_limit': 20,
      'p_before_time': '2026-10-25T10:05:00.000Z',
      'p_before_id': 'r1',
    });
    expect(replies.single.id, 'r2');
  });

  group('addComment', () {
    test('sends the words, the parent and the client id', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json(row('c1')),
      );
      final comments = SupabaseCommentsDatasource(backend.client);

      final comment = await comments.addComment(
        'p1',
        'hello',
        parentId: 'c0',
        clientId: 'k1',
      );

      expect(body(backend.to('/rpc/add_comment').single), {
        'p_post': 'p1',
        'p_body': 'hello',
        'p_parent': 'c0',
        'p_client_id': 'k1',
      });
      expect(comment.id, 'c1');
    });

    test('a top-level comment sends no parent', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json(row('c1')),
      );
      final comments = SupabaseCommentsDatasource(backend.client);

      await comments.addComment('p1', 'hello');

      expect(body(backend.to('/rpc/add_comment').single), {
        'p_post': 'p1',
        'p_body': 'hello',
      });
    });

    test('comments turned off is a RejectedFailure', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.postgrestError(400, '22023'),
      );
      final comments = SupabaseCommentsDatasource(backend.client);

      expect(
        await failureOf(comments.addComment('p1', 'hello')),
        isA<RejectedFailure>(),
      );
    });
  });

  test(
    'editComment, deleteComment and hideComment call their functions',
    () async {
      final backend = await signedIn((request) async {
        return request.url.path.endsWith('/edit_comment')
            ? BackendDouble.json(row('c1'))
            : BackendDouble.json(null);
      });
      final comments = SupabaseCommentsDatasource(backend.client);

      await comments.editComment('c1', 'new words');
      await comments.deleteComment('c1');
      await comments.hideComment('c1', hidden: true);

      expect(body(backend.to('/rpc/edit_comment').single), {
        'p_comment': 'c1',
        'p_body': 'new words',
      });
      expect(body(backend.to('/rpc/delete_comment').single), {
        'p_comment': 'c1',
      });
      expect(body(backend.to('/rpc/hide_comment').single), {
        'p_comment': 'c1',
        'p_hidden': true,
      });
    },
  );

  test('a hide the post owner is not allowed is an AuthFailure', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.postgrestError(403, '42501'),
    );
    final comments = SupabaseCommentsDatasource(backend.client);

    expect(
      await failureOf(comments.hideComment('c1', hidden: true)),
      isA<AuthFailure>(),
    );
  });

  test('setLike sends the choice and returns the count', () async {
    final backend = await signedIn((_) async => BackendDouble.json(5));
    final comments = SupabaseCommentsDatasource(backend.client);

    final count = await comments.setLike('c1', liked: true);

    expect(body(backend.to('/rpc/set_comment_like').single), {
      'p_comment': 'c1',
      'p_liked': true,
    });
    expect(count, 5);
  });

  test('getMentionCandidates sends the query and reads the people', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {'id': 'u1', 'username': 'sara', 'full_name': 'Sara Ali'},
      ]),
    );
    final comments = SupabaseCommentsDatasource(backend.client);

    final people = await comments.getMentionCandidates('p1', 'sa');

    expect(body(backend.to('/rpc/comment_mention_candidates').single), {
      'p_post': 'p1',
      'p_query': 'sa',
      'p_limit': 3,
    });
    expect(people.single.username, 'sara');
  });
}
