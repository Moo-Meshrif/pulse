import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/profile/data/datasource/follows_datasource.dart';
import 'package:pulse/features/profile/data/enums/suggestion_reason.dart';
import 'package:pulse/features/profile/data/enums/suggestion_tab.dart';

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

      final profiles = result.getOrElse((_) => []);
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
      expect(result.getOrElse((_) => []), isEmpty);
      expect(jsonBody(backend.to('suggested_profiles').single), {
        'p_tab': 'popular',
        'p_limit': 5,
        'p_offset': 10,
      });
    });
  });

  group('follows', () {
    test('follow upserts the pair, so following twice is harmless', () async {
      final backend = await signedIn((_) async => http.Response('', 201));
      final result = await SupabaseFollowsDatasource(backend.client)
          .follow('u2');
      expect(result.isRight, isTrue);
      final request = backend.to('/follows').single;
      expect(request.method, 'POST');
      expect(
        request.headers['prefer'],
        contains('resolution=merge-duplicates'),
      );
      expect(jsonBody(request), {'follower_id': uid, 'following_id': 'u2'});
    });

    test('unfollow deletes the pair', () async {
      final backend = await signedIn((_) async => http.Response('', 204));
      final result = await SupabaseFollowsDatasource(backend.client)
          .unfollow('u2');
      expect(result.isRight, isTrue);
      final request = backend.to('/follows').single;
      expect(request.method, 'DELETE');
      expect(request.url.queryParameters['follower_id'], 'eq.$uid');
      expect(request.url.queryParameters['following_id'], 'eq.u2');
    });

    test('follow all returns how many were new', () async {
      final backend = await signedIn((_) async => BackendDouble.json(2));
      final result = await SupabaseFollowsDatasource(backend.client)
          .followAll(['a', 'b', 'c']);
      expect(result, const Right<Failure, int>(2));
      expect(jsonBody(backend.to('follow_many').single), {
        'p_ids': ['a', 'b', 'c'],
      });
    });
  });
}
