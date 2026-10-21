import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/cancel_signal.dart';
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

  group('upload', () {
    late Directory dir;
    late File file;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('media_upload_test');
      file = File('${dir.path}/a.bin')
        ..writeAsBytesSync(List.filled(200 * 1024, 7));
    });

    tearDown(() => dir.delete(recursive: true));

    /// The waits between tries, recorded instead of slept.
    late List<Duration> waits;

    /// An uploader whose server answers each try with the next of [answers]: a status code, or an
    /// error to throw. The last answer repeats.
    Future<(SupabaseMediaFilesDatasource, List<http.BaseRequest>)> uploader(
      int status, {
      List<Object>? answers,
    }) async {
      final backend = await signedIn((_) async => BackendDouble.json([]));
      final sent = <http.BaseRequest>[];
      final queue = answers ?? [status];
      waits = [];
      final client = MockClient.streaming((request, bodyStream) async {
        sent.add(request);
        await bodyStream.drain<void>();
        final answer = queue.length > 1 ? queue.removeAt(0) : queue.single;
        if (answer is! int) throw answer;
        return http.StreamedResponse(Stream.value([]), answer);
      });
      return (
        SupabaseMediaFilesDatasource(
          backend.client,
          client,
          wait: (delay) async => waits.add(delay),
          random: Random(1),
        ),
        sent,
      );
    }

    test('posts the file to the bucket with the session token', () async {
      final (files, sent) = await uploader(200);
      await files.upload(
        path: 'user-1/stories/x.jpg',
        file: file,
        contentType: 'image/jpeg',
      );

      final request = sent.single as http.StreamedRequest;
      expect(request.method, 'POST');
      expect(
        request.url.toString(),
        'https://test.supabase.co/storage/v1/object/post-media/user-1/stories/x.jpg',
      );
      expect(request.headers['content-type'], 'image/jpeg');
      expect(request.headers['x-upsert'], 'true');
      expect(request.headers['Authorization'], startsWith('Bearer '));
      expect(request.contentLength, 200 * 1024);
    });

    test('reports growing byte counts that end at the file length', () async {
      final (files, _) = await uploader(200);
      final counts = <int>[];
      await files.upload(
        path: 'p',
        file: file,
        contentType: 'image/jpeg',
        onBytes: counts.add,
      );
      expect(counts, isNotEmpty);
      expect(counts, orderedEquals([...counts]..sort()));
      expect(counts.last, 200 * 1024);
    });

    test('a refused upload is a server failure', () async {
      final (files, _) = await uploader(403);
      Object? error;
      try {
        await files.upload(path: 'p', file: file, contentType: 'image/jpeg');
      } catch (e) {
        error = e;
      }
      expect(error, isA<ServerFailure>());
      expect((error as ServerFailure).statusCode, 403);
    });

    test('a refused upload is not tried again', () async {
      final (files, sent) = await uploader(403);
      await expectLater(
        files.upload(path: 'p', file: file, contentType: 'image/jpeg'),
        throwsA(isA<ServerFailure>()),
      );
      expect(sent, hasLength(1));
      expect(waits, isEmpty);
    });

    test('a busy server is tried again and the upload succeeds', () async {
      final (files, sent) = await uploader(0, answers: [503, 429, 200]);
      await files.upload(path: 'p', file: file, contentType: 'image/jpeg');

      expect(sent, hasLength(3));
      expect(waits, hasLength(2));
      // 1 s then 2 s, each kept between half and the full delay.
      expect(waits[0].inMilliseconds, inInclusiveRange(500, 1000));
      expect(waits[1].inMilliseconds, inInclusiveRange(1000, 2000));
    });

    test('a dropped connection is tried again', () async {
      final (files, sent) = await uploader(
        0,
        answers: [const SocketException('reset'), 200],
      );
      await files.upload(path: 'p', file: file, contentType: 'image/jpeg');

      expect(sent, hasLength(2));
    });

    test('after three failed tries the last error is a failure', () async {
      final (files, sent) = await uploader(500);
      await expectLater(
        files.upload(path: 'p', file: file, contentType: 'image/jpeg'),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'status', 500),
        ),
      );
      expect(sent, hasLength(3));
      expect(waits, hasLength(2));
    });

    test('three dropped connections are a network failure', () async {
      final (files, sent) = await uploader(
        0,
        answers: [http.ClientException('down')],
      );
      await expectLater(
        files.upload(path: 'p', file: file, contentType: 'image/jpeg'),
        throwsA(isA<NetworkFailure>()),
      );
      expect(sent, hasLength(3));
    });

    test('the request can be stopped through the cancel signal', () async {
      final (files, sent) = await uploader(200);
      final cancel = CancelSignal();
      await files.upload(
        path: 'p',
        file: file,
        contentType: 'image/jpeg',
        cancel: cancel,
      );
      final request = sent.single as http.Abortable;
      expect(request.abortTrigger, same(cancel.whenCancelled));
    });

    test('a cancelled upload fails and is not tried again', () async {
      final (files, sent) = await uploader(
        0,
        answers: [http.RequestAbortedException()],
      );
      final cancel = CancelSignal()..cancel();
      await expectLater(
        files.upload(
          path: 'p',
          file: file,
          contentType: 'image/jpeg',
          cancel: cancel,
        ),
        throwsA(isA<Failure>()),
      );
      expect(sent, hasLength(1));
      expect(waits, isEmpty);
    });

    test('a missing file fails at once without a request', () async {
      final (files, sent) = await uploader(200);
      await expectLater(
        files.upload(
          path: 'p',
          file: File('${dir.path}/gone.bin'),
          contentType: 'image/jpeg',
        ),
        throwsA(isA<Failure>()),
      );
      expect(sent, isEmpty);
      expect(waits, isEmpty);
    });
  });

  test('listFiles returns the names in the folder', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {'name': '0.jpg'},
        {'name': '1.mp4'},
      ]),
    );
    final files = SupabaseMediaFilesDatasource(backend.client, http.Client());

    expect(await files.listFiles('user-1/p1'), ['0.jpg', '1.mp4']);
    final listing = backend.requests.singleWhere(
      (r) => r.url.path.contains('/object/list/'),
    );
    expect((jsonDecode(listing.body) as Map)['prefix'], 'user-1/p1');
  });

  test('a failed listFiles throws', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json({'message': 'boom'}, status: 500),
    );
    final files = SupabaseMediaFilesDatasource(backend.client, http.Client());

    await expectLater(files.listFiles('user-1/p1'), throwsA(isA<Failure>()));
  });

  test('listFolder returns full paths under the signed-in user', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json([
        {'name': '0.jpg'},
        {'name': '1.mp4'},
      ]),
    );
    final files = SupabaseMediaFilesDatasource(backend.client, http.Client());

    expect(await files.listFolder('p1'), [
      '${BackendDouble.uid}/p1/0.jpg',
      '${BackendDouble.uid}/p1/1.mp4',
    ]);
  });

  test('a failed listing is an empty list', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json({'message': 'boom'}, status: 500),
    );
    final files = SupabaseMediaFilesDatasource(backend.client, http.Client());

    expect(await files.listFolder('p1'), isEmpty);
  });

  test('remove sends the paths; a failure is ignored', () async {
    final backend = await signedIn(
      (_) async => BackendDouble.json({'message': 'boom'}, status: 500),
    );
    final files = SupabaseMediaFilesDatasource(backend.client, http.Client());

    await expectLater(files.remove(['a/b.jpg']), completes);

    final request = backend.requests.singleWhere(
      (r) => r.url.path.endsWith('/object/post-media'),
    );
    expect((jsonDecode(request.body) as Map)['prefixes'], ['a/b.jpg']);
  });

  test('remove with no paths sends nothing', () async {
    final backend = await signedIn((_) async => BackendDouble.json([]));
    await SupabaseMediaFilesDatasource(
      backend.client,
      http.Client(),
    ).remove(const []);

    expect(
      backend.requests.where((r) => r.url.path.contains('/object/')),
      isEmpty,
    );
  });
}
