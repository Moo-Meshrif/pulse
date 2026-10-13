import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import 'stories_datasource.dart';

/// Uploads a story's files to the private `post-media` bucket and says how many bytes went out.
abstract interface class StoryMediaUploader {
  /// Uploads [file] to [path] (an existing object is replaced, so a retry is safe). [onBytes] is told the
  /// bytes sent so far, growing to the file's length.
  Future<void> upload({
    required String path,
    required File file,
    required String contentType,
    void Function(int sentBytes)? onBytes,
  });
}

/// [StoryMediaUploader] over the storage REST endpoint with the `http` package. The Supabase SDK reports
/// no progress, so the file is streamed here and counted as the connection takes it.
@LazySingleton(as: StoryMediaUploader)
final class HttpStoryMediaUploader implements StoryMediaUploader {
  HttpStoryMediaUploader(this._client, this._http);

  final SupabaseClient _client;
  final http.Client _http;

  @override
  Future<void> upload({
    required String path,
    required File file,
    required String contentType,
    void Function(int sentBytes)? onBytes,
  }) => Guard.run(() async {
    final length = await file.length();
    final token = _client.auth.currentSession?.accessToken;
    final request =
        http.StreamedRequest(
            'POST',
            Uri.parse(
              '${_client.storage.url}/object/'
              '${SupabaseStoriesDatasource.bucket}/$path',
            ),
          )
          ..contentLength = length
          ..headers.addAll({
            ..._client.storage.headers,
            // The storage headers can carry the public key only; the policies need the user's token.
            'Authorization': ?(token == null ? null : 'Bearer $token'),
            'content-type': contentType,
            'x-upsert': 'true',
          });

    var sent = 0;
    final body = file.openRead().map((chunk) {
      sent += chunk.length;
      onBytes?.call(sent);
      return chunk;
    });
    request.sink.addStream(body).whenComplete(request.sink.close);

    final response = await http.Response.fromStream(await _http.send(request));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StorageException(
        response.body,
        statusCode: '${response.statusCode}',
      );
    }
  });
}
