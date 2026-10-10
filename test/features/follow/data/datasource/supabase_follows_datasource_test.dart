import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/features/follow/data/datasource/follows_datasource.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/data/enums/suggestion_reason.dart';
import 'package:pulse/features/follow/data/enums/suggestion_tab.dart';

import '../../../../helpers/backend_double.dart';

void main() {
  const uid = BackendDouble.uid;

  /// A signed-in client whose non-auth requests go to [handler].
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

  dynamic jsonBody(http.Request request) => jsonDecode(request.body);

  group('suggested profiles', () {
    test('asks for a tab and parses the rows', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'id': 'u2',
            'username': 'salma',
            'full_name': 'Salma Kamal',
            'avatar_url': null,
            'city': 'Cairo',
            'reason_kind': 'mutual',
            'mutual_count': 12,
          },
        ]),
      );
      final result = await SupabaseFollowsDatasource(backend.client)
          .getSuggestedProfiles(SuggestionTab.suggested);

      final profiles = result;
      expect(profiles.single.fullName, 'Salma Kamal');
      expect(profiles.single.reason, SuggestionReason.mutual);
      expect(profiles.single.mutualCount, 12);
      expect(jsonBody(backend.to('suggested_profiles').single), {
        'p_tab': 'suggested',
        'p_limit': 20,
        'p_offset': 0,
      });
    });

    test('an empty list is a successful empty list', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json(<dynamic>[]),
      );
      final result = await SupabaseFollowsDatasource(backend.client)
          .getSuggestedProfiles(SuggestionTab.popular, limit: 5, offset: 10);
      expect(result, isEmpty);
      expect(jsonBody(backend.to('suggested_profiles').single), {
        'p_tab': 'popular',
        'p_limit': 5,
        'p_offset': 10,
      });
    });
  });

  group('follows', () {
    test(
      'follow inserts the pair and returns the status the backend set',
      () async {
        final backend = await signedIn(
          (request) async => request.method == 'POST'
              ? http.Response('', 201)
              : BackendDouble.json({'status': 'pending'}),
        );
        final status = await SupabaseFollowsDatasource(backend.client)
            .follow('u2');
        expect(status, FollowStatus.pending);

        final insert = backend.to('/follows').first;
        expect(insert.method, 'POST');
        expect(
          insert.headers['prefer'],
          contains('resolution=ignore-duplicates'),
        );
        // The client never sends a status: the backend decides it.
        expect(jsonBody(insert), {'follower_id': uid, 'following_id': 'u2'});
        final read = backend.to('/follows').last;
        expect(read.method, 'GET');
        expect(read.url.queryParameters['follower_id'], 'eq.$uid');
        expect(read.url.queryParameters['following_id'], 'eq.u2');
      },
    );

    test('unfollow deletes the pair', () async {
      final backend = await signedIn((_) async => http.Response('', 204));
      await SupabaseFollowsDatasource(backend.client).unfollow('u2');
      final request = backend.to('/follows').single;
      expect(request.method, 'DELETE');
      expect(request.url.queryParameters['follower_id'], 'eq.$uid');
      expect(request.url.queryParameters['following_id'], 'eq.u2');
    });

    test('follow all returns how many were new', () async {
      final backend = await signedIn((_) async => BackendDouble.json(2));
      final result = await SupabaseFollowsDatasource(backend.client)
          .followAll(['a', 'b', 'c']);
      expect(result, 2);
      expect(jsonBody(backend.to('follow_many').single), {
        'p_ids': ['a', 'b', 'c'],
      });
    });
  });

  group('follow requests', () {
    test('lists the waiting requests', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'id': 'u2',
            'username': 'nour.adel',
            'full_name': 'Nour Adel',
            'avatar_url': null,
            'city': null,
            'mutual_count': 12,
            'requested_at': '2026-10-10T08:00:00Z',
          },
        ]),
      );
      final result = await SupabaseFollowsDatasource(backend.client)
          .getRequests(limit: 10, offset: 5);
      expect(result.single.fullName, 'Nour Adel');
      expect(result.single.mutualCount, 12);
      expect(jsonBody(backend.to('follow_requests').single), {
        'p_limit': 10,
        'p_offset': 5,
      });
    });

    test('counts only pending requests to the signed-in user', () async {
      final backend = await signedIn(
        (_) async => http.Response(
          '[]',
          200,
          headers: {'content-type': 'application/json', 'content-range': '*/5'},
        ),
      );
      final count = await SupabaseFollowsDatasource(backend.client)
          .getRequestCount();
      expect(count, 5);
      final query = backend.to('/follows').single.url.queryParameters;
      expect(query['following_id'], 'eq.$uid');
      expect(query['status'], 'eq.pending');
    });

    test('accept sets the status of one pending request', () async {
      final backend = await signedIn((_) async => http.Response('', 204));
      await SupabaseFollowsDatasource(backend.client).acceptRequest('u2');
      final request = backend.to('/follows').single;
      expect(request.method, 'PATCH');
      expect(jsonBody(request), {'status': 'accepted'});
      expect(request.url.queryParameters['following_id'], 'eq.$uid');
      expect(request.url.queryParameters['follower_id'], 'eq.u2');
      expect(request.url.queryParameters['status'], 'eq.pending');
    });

    test('accept all sets every pending request to the user', () async {
      final backend = await signedIn((_) async => http.Response('', 204));
      await SupabaseFollowsDatasource(backend.client).acceptAllRequests();
      final request = backend.to('/follows').single;
      expect(request.method, 'PATCH');
      expect(jsonBody(request), {'status': 'accepted'});
      expect(request.url.queryParameters['following_id'], 'eq.$uid');
      expect(request.url.queryParameters.containsKey('follower_id'), isFalse);
    });

    test('decline deletes the pending request', () async {
      final backend = await signedIn((_) async => http.Response('', 204));
      await SupabaseFollowsDatasource(backend.client).declineRequest('u2');
      final request = backend.to('/follows').single;
      expect(request.method, 'DELETE');
      expect(request.url.queryParameters['following_id'], 'eq.$uid');
      expect(request.url.queryParameters['follower_id'], 'eq.u2');
      expect(request.url.queryParameters['status'], 'eq.pending');
    });
  });
}
