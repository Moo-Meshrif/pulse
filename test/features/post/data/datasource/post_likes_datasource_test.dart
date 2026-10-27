import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/datasource/post_likes_datasource.dart';

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

  Map<String, dynamic> row(String id) => {
    'id': id,
    'username': 'sara',
    'full_name': 'Sara K',
    'avatar_url': null,
    'liked_at': '2026-10-27T10:00:00Z',
    'follow_status': 'accepted',
    'follows_me': true,
    'total': 1204,
  };

  group('getLikers', () {
    test('sends the search and the cursor and reads the rows', () async {
      late Map<String, dynamic> sent;
      final backend = await signedIn((request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return BackendDouble.json([row('u1'), row('u2')]);
      });
      final likes = SupabasePostLikesDatasource(backend.client);

      final page = await likes.getLikers(
        'p1',
        query: 'sa',
        limit: 2,
        beforeLikedAt: DateTime.utc(2026, 10, 26),
        beforeId: 'u0',
      );

      expect(sent['p_post'], 'p1');
      expect(sent['p_query'], 'sa');
      expect(sent['p_limit'], 2);
      expect(sent['p_before_time'], '2026-10-26T00:00:00.000Z');
      expect(sent['p_before_id'], 'u0');
      expect(page.likers.map((l) => l.id), ['u1', 'u2']);
      expect(page.likers.first.followStatus, 'accepted');
      expect(page.likers.first.total, 1204);
      expect(page.nextId, 'u2');
    });

    test('a short page is the last one', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([row('u1')]),
      );
      final page = await SupabasePostLikesDatasource(backend.client)
          .getLikers('p1', limit: 20);
      expect(page.nextId, isNull);
      expect(page.nextLikedAt, isNull);
    });

    test('a post nobody can see is not found', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json({
          'code': 'P0002',
          'message': 'post_unavailable',
        }, status: 400),
      );
      final likes = SupabasePostLikesDatasource(backend.client);
      expect(
        await failureOf(likes.getLikers('p1', limit: 20)),
        isA<NotFoundFailure>(),
      );
    });
  });

  group('getPreview', () {
    test('reads the row and its avatars', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'first_id': 'u1',
            'first_username': 'salma.ash',
            'first_full_name': 'Salma',
            'others': 1203,
            'avatars': [
              {'id': 'u1', 'name': 'Salma', 'avatar_url': null},
              {'id': 'u2', 'name': 'Omar', 'avatar_url': 'x'},
            ],
          },
        ]),
      );
      final preview = await SupabasePostLikesDatasource(backend.client)
          .getPreview('p1');
      expect(preview?.firstUsername, 'salma.ash');
      expect(preview?.others, 1203);
      expect(preview?.avatars?.length, 2);
    });

    test('reads that you are the only one who liked it', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'first_id': 'me',
            'first_username': 'me.me',
            'others': 0,
            'avatars': [
              {'id': 'me', 'name': 'Me', 'avatar_url': null},
            ],
            'only_me': true,
          },
        ]),
      );
      final preview = await SupabasePostLikesDatasource(backend.client)
          .getPreview('p1');
      expect(preview?.onlyMe, isTrue);
    });

    test('no row means nobody liked it', () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      expect(
        await SupabasePostLikesDatasource(backend.client).getPreview('p1'),
        isNull,
      );
    });
  });

  group('getPreviews', () {
    test('sends the ids and maps the rows by post id', () async {
      late Map<String, dynamic> sent;
      final backend = await signedIn((request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return BackendDouble.json([
          {'post_id': 'p1', 'first_username': 'salma.ash', 'others': 3},
          {'post_id': 'p2', 'first_username': 'omar', 'others': 0},
        ]);
      });
      final previews = await SupabasePostLikesDatasource(backend.client)
          .getPreviews(['p1', 'p2', 'p3']);

      expect(sent['p_posts'], ['p1', 'p2', 'p3']);
      expect(previews.keys, ['p1', 'p2']);
      expect(previews['p1']?.firstUsername, 'salma.ash');
      expect(previews['p1']?.others, 3);
    });

    test('no ids makes no request', () async {
      var calls = 0;
      final backend = await signedIn((_) async {
        calls++;
        return BackendDouble.json([]);
      });
      final previews = await SupabasePostLikesDatasource(backend.client)
          .getPreviews([]);
      expect(previews, isEmpty);
      expect(calls, 0);
    });
  });
}
