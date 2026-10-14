import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/shared/content/data/datasource/audience_datasource.dart';

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

  test('getSummary reads the three numbers', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {'followers': 312, 'close_friends': 12, 'hidden': 2},
      ]),
    );

    final summary = await SupabaseAudienceDatasource(backend.client)
        .getSummary();

    expect(
      [summary.followers, summary.closeFriends, summary.hidden],
      [312, 12, 2],
    );
    expect(backend.to('/rpc/audience_summary'), hasLength(1));
  });

  test('an empty answer has no numbers', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));

    final summary = await SupabaseAudienceDatasource(backend.client)
        .getSummary();

    expect(summary.followers, isNull);
  });

  test('a failed call is a Failure', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.postgrestError(500, 'XX000'),
    );

    await expectLater(
      SupabaseAudienceDatasource(backend.client).getSummary(),
      throwsA(isA<Failure>()),
    );
  });
}
