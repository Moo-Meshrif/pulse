import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/shared/content/data/datasource/privacy_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

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

  test('getPrivacy reads the two columns of the signed-in profile', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json({
        'is_private': true,
        'default_post_visibility': 'close_friends',
      }),
    );
    final privacy = SupabasePrivacyDatasource(backend.client);

    final result = await privacy.getPrivacy();

    expect(result.isPrivate, isTrue);
    expect(result.defaultAudience, ContentAudience.closeFriends);
    final request = backend.to('/profiles').single;
    expect(request.url.queryParameters['id'], 'eq.user-1');
    expect(
      request.url.queryParameters['select'],
      'is_private,default_post_visibility',
    );
  });

  test('setDefaultAudience updates only that column', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));
    final privacy = SupabasePrivacyDatasource(backend.client);

    await privacy.setDefaultAudience(ContentAudience.onlyMe);

    final request = backend.to('/profiles').single;
    expect(request.method, 'PATCH');
    expect(request.url.queryParameters['id'], 'eq.user-1');
    expect(jsonDecode(request.body), {'default_post_visibility': 'only_me'});
  });
}
