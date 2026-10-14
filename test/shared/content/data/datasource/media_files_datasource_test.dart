import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';

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

  test('listFolder returns full paths under the signed-in user', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {'name': '0.jpg'},
        {'name': '1.mp4'},
      ]),
    );
    final files = SupabaseMediaFilesDatasource(backend.client);

    expect(await files.listFolder('p1'), [
      '${BackendDouble.uid}/p1/0.jpg',
      '${BackendDouble.uid}/p1/1.mp4',
    ]);
  });

  test('a failed listing is an empty list', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json({'message': 'boom'}, status: 500),
    );
    final files = SupabaseMediaFilesDatasource(backend.client);

    expect(await files.listFolder('p1'), isEmpty);
  });

  test('remove sends the paths; a failure is ignored', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json({'message': 'boom'}, status: 500),
    );
    final files = SupabaseMediaFilesDatasource(backend.client);

    await expectLater(files.remove(['a/b.jpg']), completes);

    final request = backend.requests.singleWhere(
      (r) => r.url.path.endsWith('/object/post-media'),
    );
    expect((jsonDecode(request.body) as Map)['prefixes'], ['a/b.jpg']);
  });

  test('remove with no paths sends nothing', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));
    await SupabaseMediaFilesDatasource(backend.client).remove(const []);

    expect(
      backend.requests.where((r) => r.url.path.contains('/object/')),
      isEmpty,
    );
  });
}
