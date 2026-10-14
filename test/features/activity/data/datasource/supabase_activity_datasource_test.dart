import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/activity/data/datasource/activity_datasource.dart';

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

  http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );

  group('getUnreadCount', () {
    test('reads the activity and follow request counts', () async {
      final backend = await signedIn(
        (_) async => json([
          {'activity': 4, 'follow_requests': 2},
        ]),
      );
      final unread = await SupabaseActivityDatasource(backend.client)
          .getUnreadCount();
      expect(backend.to('/rpc/activity_unread_count'), hasLength(1));
      expect(unread.activity, 4);
      expect(unread.followRequests, 2);
    });

    test('no row means nothing waits', () async {
      final backend = await signedIn((_) async => json([]));
      final unread = await SupabaseActivityDatasource(backend.client)
          .getUnreadCount();
      expect(unread.activity, isNull);
      expect(unread.followRequests, isNull);
    });

    test('a server error is a Failure', () async {
      final backend = await signedIn(
        (_) async => json({'message': 'boom'}, 500),
      );
      expect(
        await failureOf(
          SupabaseActivityDatasource(backend.client).getUnreadCount(),
        ),
        isA<ServerFailure>(),
      );
    });
  });
}
