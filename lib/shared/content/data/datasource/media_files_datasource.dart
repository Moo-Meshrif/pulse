import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';

/// The files of posts, shorts and stories: the private `post-media` bucket, `{uid}/{id}/…` for a post
/// and `{uid}/stories/…` for a story. Cleanup after a delete is best effort: [listFolder] and [remove]
/// never throw, because the row is already gone and leftover files are not worth failing the delete.
abstract interface class MediaFilesDatasource {
  /// Uploads [file] to [path] (an existing object is replaced, so a retry is safe). A dropped connection
  /// or a busy server is tried again a few times before it throws. [onBytes] is told the bytes sent so
  /// far, growing to the file's length; a retry counts again from zero.
  Future<void> upload({
    required String path,
    required File file,
    required String contentType,
    void Function(int sentBytes)? onBytes,
  });

  /// The names of the files in [folder] (a full path such as `{uid}/{postId}`).
  Future<List<String>> listFiles(String folder);

  /// The paths of the files in the signed-in user's folder [name]; empty when the listing fails.
  Future<List<String>> listFolder(String name);

  /// Removes [paths]; a failure is ignored.
  Future<void> remove(List<String> paths);
}

/// [MediaFilesDatasource] as an adapter over Supabase storage. Uploads go to the storage REST endpoint
/// with the `http` package: the Supabase SDK reports no progress, so the file is streamed here and counted
/// as the connection takes it.
@LazySingleton(as: MediaFilesDatasource)
final class SupabaseMediaFilesDatasource implements MediaFilesDatasource {
  SupabaseMediaFilesDatasource(
    this._client,
    this._http, {
    @ignoreParam Future<void> Function(Duration delay)? wait,
    @ignoreParam Random? random,
  }) : _wait = wait ?? Future<void>.delayed,
       _random = random ?? Random();

  static const _bucket = 'post-media';

  /// Tries of one upload, the first included.
  static const _maxTries = 3;
  static const _firstRetryDelay = Duration(seconds: 1);

  final SupabaseClient _client;
  final http.Client _http;
  final Future<void> Function(Duration delay) _wait;
  final Random _random;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw const AuthRejectedException(AuthFailureReason.sessionExpired));

  @override
  Future<void> upload({
    required String path,
    required File file,
    required String contentType,
    void Function(int sentBytes)? onBytes,
  }) => Guard.run(() async {
    final length = await file.length();
    for (var attempt = 1; ; attempt++) {
      final http.Response response;
      try {
        response = await _send(path, file, length, contentType, onBytes);
      } on Object catch (error) {
        if (attempt == _maxTries || !_isTransient(error)) rethrow;
        await _backoff(attempt);
        continue;
      }
      final status = response.statusCode;
      if (status >= 200 && status < 300) return;
      if (attempt == _maxTries || !_retriedStatuses(status)) {
        throw StorageException(response.body, statusCode: '$status');
      }
      await _backoff(attempt);
    }
  });

  /// One try: streams [file] and counts the bytes from zero, so a retry reports them again.
  Future<http.Response> _send(
    String path,
    File file,
    int length,
    String contentType,
    void Function(int sentBytes)? onBytes,
  ) async {
    final token = _client.auth.currentSession?.accessToken;
    final request =
        http.StreamedRequest(
            'POST',
            Uri.parse('${_client.storage.url}/object/$_bucket/$path'),
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
    // Runs while the request is sent below: the bytes flow in as the server takes them.
    unawaited(request.sink.addStream(body).whenComplete(request.sink.close));

    return http.Response.fromStream(await _http.send(request));
  }

  /// A dropped or timed-out connection; anything else (a missing file, a bad request) fails at once.
  bool _isTransient(Object error) =>
      error is SocketException ||
      error is HttpException ||
      error is http.ClientException ||
      error is TimeoutException;

  /// Request timeout, rate limit and server errors; other 4xx answers will not change on a retry.
  bool _retriedStatuses(int status) =>
      status == 408 || status == 429 || status >= 500;

  /// 1 s then 2 s, each shortened by up to half at random so many clients do not retry together.
  Future<void> _backoff(int attempt) {
    final full = _firstRetryDelay * (1 << (attempt - 1));
    return _wait(full * (0.5 + _random.nextDouble() / 2));
  }

  @override
  Future<List<String>> listFiles(String folder) => Guard.run(() async {
    final objects = await _client.storage.from(_bucket).list(path: folder);
    return objects.map((object) => object.name).toList();
  });

  @override
  Future<List<String>> listFolder(String name) async {
    try {
      final folder = '$_uid/$name';
      final objects = await _client.storage.from(_bucket).list(path: folder);
      return objects.map((object) => '$folder/${object.name}').toList();
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> remove(List<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await _client.storage.from(_bucket).remove(paths);
    } on Object {
      // The content is gone; leftover files are not worth an error.
    }
  }
}
