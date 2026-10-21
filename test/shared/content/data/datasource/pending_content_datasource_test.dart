import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/shared/content/data/datasource/pending_content_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/pending_content_state.dart';
import 'package:pulse/shared/content/data/model/pending_content_status_model.dart';

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

  test('share sends the request and reads the state', () async {
    final backend = await signedIn((_) async => BackendDouble.json('waiting'));
    final pending = SupabasePendingContentDatasource(backend.client);

    final state = await pending.share('p1', ContentKind.post, {
      'caption': 'hi',
      'media': <Object>[],
    });

    expect(state, PendingContentState.waiting);
    expect(body(backend.to('/rpc/share_content').single), {
      'p_id': 'p1',
      'p_kind': 'post',
      'p_request': {'caption': 'hi', 'media': <Object>[]},
    });
  });

  test('publish and discard read the state; an unknown one is null', () async {
    final backend = await signedIn(
      (request) async => BackendDouble.json(
        request.url.path.endsWith('publish_content') ? 'published' : 'later',
      ),
    );
    final pending = SupabasePendingContentDatasource(backend.client);

    expect(await pending.publish('p1'), PendingContentState.published);
    expect(await pending.discard('p1', ContentKind.post), isNull);
    expect(body(backend.to('/rpc/discard_content').single), {
      'p_id': 'p1',
      'p_kind': 'post',
    });
  });

  test('status reads each row with its missing files', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {
          'id': 'p1',
          'kind': 'post',
          'state': 'waiting',
          'error_code': null,
          'missing': ['u1/p1/m1.jpg'],
        },
      ]),
    );
    final pending = SupabasePendingContentDatasource(backend.client);

    final rows = await pending.status(['p1']);

    expect(rows, const [
      PendingContentStatusModel(
        id: 'p1',
        state: PendingContentState.waiting,
        missing: ['u1/p1/m1.jpg'],
      ),
    ]);
    expect(body(backend.to('/rpc/content_status').single), {
      'p_ids': ['p1'],
    });
  });

  test(
    'cleanup lists the files to delete and confirms how many are left',
    () async {
      final backend = await signedIn(
        (request) async => request.url.path.endsWith('content_cleanup_list')
            ? BackendDouble.json([
                {
                  'id': 'p1',
                  'paths': ['u1/p1/a.jpg'],
                },
              ])
            : BackendDouble.json(2),
      );
      final pending = SupabasePendingContentDatasource(backend.client);

      final rows = await pending.cleanupList();
      expect(rows.single.id, 'p1');
      expect(rows.single.paths, ['u1/p1/a.jpg']);

      expect(await pending.confirmCleanup('p1'), 2);
      expect(body(backend.to('/rpc/confirm_content_cleanup').single), {
        'p_id': 'p1',
      });
    },
  );
}
