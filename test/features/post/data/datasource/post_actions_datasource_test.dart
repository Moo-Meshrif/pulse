import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/datasource/post_actions_datasource.dart';

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

  test('setLike sends the post and flag and returns the new count', () async {
    final backend = await signedIn((_) async => BackendDouble.json(8));
    final actions = SupabasePostActionsDatasource(backend.client);

    final count = await actions.setLike('p1', liked: true);

    expect(count, 8);
    expect(body(backend.to('/rpc/set_post_like').single), {
      'p_post': 'p1',
      'p_liked': true,
    });
  });

  test('setSave returns the answer of the server', () async {
    final backend = await signedIn((_) async => BackendDouble.json(false));
    final actions = SupabasePostActionsDatasource(backend.client);

    expect(await actions.setSave('p1', saved: true), isFalse);
    expect(body(backend.to('/rpc/set_post_save').single), {
      'p_post': 'p1',
      'p_saved': true,
    });
  });

  test('hidePost sends hidden, and false is Undo', () async {
    final backend = await signedIn((_) async => BackendDouble.json(null));
    final actions = SupabasePostActionsDatasource(backend.client);

    await actions.hidePost('p1', hidden: false);

    expect(body(backend.to('/rpc/hide_post').single), {
      'p_post': 'p1',
      'p_hidden': false,
    });
  });

  test('setCommentsEnabled updates only that post', () async {
    final backend = await signedIn((_) async => BackendDouble.json(null));
    final actions = SupabasePostActionsDatasource(backend.client);

    await actions.setCommentsEnabled('p1', enabled: false);

    final request = backend.to('/posts').single;
    expect(request.method, 'PATCH');
    expect(request.url.queryParameters['id'], 'eq.p1');
    expect(body(request), {'comments_enabled': false});
  });

  group('deletePost', () {
    test('deletes only the row of that post', () async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      final actions = SupabasePostActionsDatasource(backend.client);

      await actions.deletePost('p1');

      final request = backend.to('/posts').single;
      expect(request.method, 'DELETE');
      expect(request.url.queryParameters['id'], 'eq.p1');
      expect(
        backend.requests.where((r) => r.url.path.contains('/object/')),
        isEmpty,
      );
    });

    test('a failed row delete is a Failure', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.postgrestError(403, '42501'),
      );
      final actions = SupabasePostActionsDatasource(backend.client);

      await expectLater(actions.deletePost('p1'), throwsA(isA<Failure>()));
    });
  });
}
