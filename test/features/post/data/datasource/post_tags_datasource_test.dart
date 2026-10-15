import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/features/post/data/datasource/post_tags_datasource.dart';
import 'package:pulse/features/post/data/enums/follow_state.dart';

import '../../../../helpers/backend_double.dart';

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

  test('searchPeople sends the query and reads who can be tagged', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {
          'id': 'u2',
          'username': 'sara',
          'full_name': 'Sara Ali',
          'avatar_url': null,
          'can_tag': true,
        },
        {'id': 'u3', 'username': 'omar', 'can_tag': false},
      ]),
    );
    final tags = SupabasePostTagsDatasource(backend.client);

    final people = await tags.searchPeople('sa', limit: 10);

    expect(body(backend.to('/rpc/tag_search').single), {
      'p_q': 'sa',
      'p_limit': 10,
    });
    expect(people.map((p) => p.username), ['sara', 'omar']);
    expect(people.map((p) => p.canTag), [true, false]);
  });

  test('a blank search sends no query', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));
    final tags = SupabasePostTagsDatasource(backend.client);

    await tags.searchPeople(null);

    expect(body(backend.to('/rpc/tag_search').single)['p_q'], isNull);
  });

  test('getTaggedPeople reads the follow state of each person', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {'id': 'u1', 'username': 'me', 'follow_state': 'me'},
        {'id': 'u2', 'username': 'sara', 'follow_state': 'following'},
        {'id': 'u3', 'username': 'omar', 'follow_state': 'pending'},
        {'id': 'u4', 'username': 'lina', 'follow_state': 'none'},
        {'id': 'u5', 'username': 'x', 'follow_state': 'odd'},
      ]),
    );
    final tags = SupabasePostTagsDatasource(backend.client);

    final people = await tags.getTaggedPeople('p1');

    expect(body(backend.to('/rpc/post_tagged_people').single), {
      'p_post': 'p1',
    });
    expect(people.map((p) => p.followState), [
      FollowState.me,
      FollowState.following,
      FollowState.pending,
      FollowState.none,
      null,
    ]);
  });

  test('removeMyTag says whether a tag was removed', () async {
    var removed = true;
    final backend = await signedIn((_) async => BackendDouble.json(removed));
    final tags = SupabasePostTagsDatasource(backend.client);

    expect(await tags.removeMyTag('p1'), isTrue);
    removed = false;
    expect(await tags.removeMyTag('p1'), isFalse);
    expect(body(backend.to('/rpc/remove_my_tag').first), {'p_post': 'p1'});
  });
}
