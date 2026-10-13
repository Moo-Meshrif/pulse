import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/story/data/datasource/story_media_uploader.dart';

import '../../../../helpers/backend_double.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('story_upload_test');
    file = File('${dir.path}/a.bin')
      ..writeAsBytesSync(List.filled(200 * 1024, 7));
  });

  tearDown(() => dir.delete(recursive: true));

  Future<(HttpStoryMediaUploader, List<http.BaseRequest>)> uploader(
    int status,
  ) async {
    final backend = BackendDouble(
      (_) => Future.value(BackendDouble.sessionResponse()),
    );
    await backend.signIn();
    final sent = <http.BaseRequest>[];
    final client = MockClient.streaming((request, bodyStream) async {
      sent.add(request);
      await bodyStream.drain<void>();
      return http.StreamedResponse(Stream.value([]), status);
    });
    return (HttpStoryMediaUploader(backend.client, client), sent);
  }

  test('posts the file to the bucket with the session token', () async {
    final (up, sent) = await uploader(200);
    await up.upload(
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
    final (up, _) = await uploader(200);
    final counts = <int>[];
    await up.upload(
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
    final (up, _) = await uploader(403);
    Object? error;
    try {
      await up.upload(path: 'p', file: file, contentType: 'image/jpeg');
    } catch (e) {
      error = e;
    }
    expect(error, isA<ServerFailure>());
    expect((error as ServerFailure).statusCode, 403);
  });
}
