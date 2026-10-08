import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/profile/data/datasource/interests_datasource.dart';

import '../../../../helpers/backend_double.dart';

void main() {
  Failure? failureOf(Either<Failure, Object?> result) =>
      result.fold((f) => f, (_) => null);

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

  group('interests', () {
    test('lists the topics in sort order', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json([
          {
            'id': 1,
            'slug': 'travel',
            'name_en': 'Travel',
            'name_ar': 'سفر',
            'sort_order': 1,
          },
          {
            'id': 2,
            'slug': 'photography',
            'name_en': 'Photography',
            'name_ar': 'تصوير',
            'sort_order': 2,
          },
        ]),
      );
      final result = await SupabaseInterestsDatasource(backend.client)
          .getInterests();

      final interests = result.getOrElse((_) => []);
      expect(interests.map((i) => i.slug), ['travel', 'photography']);
      expect(interests.first.nameFor('ar'), 'سفر');
      expect(
        backend.to('/interests').single.url.queryParameters['order'],
        startsWith(
          'sort_order.asc',
        ), // ascending, not postgrest's descending default
      );
    });

    test('saving replaces the user\'s interests with the chosen ids', () async {
      final backend = await signedIn((_) async => http.Response('', 204));
      final result = await SupabaseInterestsDatasource(backend.client)
          .saveInterests([1, 5]);
      expect(result.isRight, isTrue);
      expect(jsonBody(backend.to('set_user_interests').single), {
        'p_ids': [1, 5],
      });
    });
  });

  test(
    'a server error is a ServerFailure and a lost connection a NetworkFailure',
    () async {
      final server = await signedIn(
        (_) async => BackendDouble.postgrestError(500, '500'),
      );
      expect(
        failureOf(
          await SupabaseInterestsDatasource(server.client).getInterests(),
        ),
        const ServerFailure(statusCode: 500),
      );

      final offline = await signedIn(
        (_) async => throw http.ClientException('offline'),
      );
      expect(
        failureOf(
          await SupabaseInterestsDatasource(offline.client).getInterests(),
        ),
        const NetworkFailure(),
      );
    },
  );
}
