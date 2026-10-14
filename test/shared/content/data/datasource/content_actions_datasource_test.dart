import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/shared/content/data/datasource/content_actions_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';

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

  test('report sends the kind, id, wire reason and note', () async {
    final backend = await signedIn((_) async => BackendDouble.json(null));
    final actions = SupabaseContentActionsDatasource(backend.client);

    await actions.report(ContentKind.story, 's1', ReportReason.falseInfo);
    await actions.report(
      ContentKind.post,
      'p1',
      ReportReason.other,
      note: 'rude',
    );

    final calls = backend.to('/rpc/report_content').map(body).toList();
    expect(calls[0], {
      'p_kind': 'story',
      'p_id': 's1',
      'p_reason': 'false_info',
      'p_note': null,
    });
    expect(calls[1], {
      'p_kind': 'post',
      'p_id': 'p1',
      'p_reason': 'other',
      'p_note': 'rude',
    });
  });

  test('setAudience sends the kind and the wire audience', () async {
    final backend = await signedIn((_) async => BackendDouble.json('x'));
    final actions = SupabaseContentActionsDatasource(backend.client);

    await actions.setAudience(
      ContentKind.short,
      'p1',
      ContentAudience.closeFriends,
    );

    expect(body(backend.to('/rpc/set_content_audience').single), {
      'p_kind': 'short',
      'p_id': 'p1',
      'p_audience': 'close_friends',
    });
  });

  test('changing the audience of content that is not yours fails', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.postgrestError(403, '42501'),
    );
    final actions = SupabaseContentActionsDatasource(backend.client);

    await expectLater(
      actions.setAudience(ContentKind.story, 's1', ContentAudience.followers),
      throwsA(isA<Failure>()),
    );
  });

  test('setMuted sends the user, the flag and the scope', () async {
    final backend = await signedIn((_) async => BackendDouble.json(true));
    final actions = SupabaseContentActionsDatasource(backend.client);

    await actions.setMuted('u2', muted: true, scope: MuteScope.stories);
    await actions.setMuted('u2', muted: false, scope: MuteScope.posts);

    final calls = backend.to('/rpc/set_mute').map(body).toList();
    expect(calls[0], {'p_user': 'u2', 'p_muted': true, 'p_scope': 'stories'});
    expect(calls[1], {'p_user': 'u2', 'p_muted': false, 'p_scope': 'posts'});
  });
}
