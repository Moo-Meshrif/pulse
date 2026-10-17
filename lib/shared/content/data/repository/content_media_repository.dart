import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/video_compress_service.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import '../../../../core/utils/equatable.dart';
import '../../domain/policy/media_policy.dart';
import '../datasource/media_files_datasource.dart';
import '../enums/content_kind.dart';

/// A photo or video on this device, about to go out.
class MediaToSend extends Equatable {
  const MediaToSend({
    required this.filePath,
    required this.isVideo,
    this.thumbFilePath,
    this.width,
    this.height,
    this.durationMs,
    this.sizeBytes,
  });

  final String filePath;
  final bool isVideo;

  /// A JPEG frame of a video, when the caller already made one; otherwise one is made here.
  final String? thumbFilePath;
  final int? width;
  final int? height;
  final int? durationMs;
  final int? sizeBytes;

  @override
  List<Object?> get props => [
    filePath,
    isVideo,
    thumbFilePath,
    width,
    height,
    durationMs,
    sizeBytes,
  ];
}

/// Where a sent file and its video thumb are in the media bucket.
class SentMedia extends Equatable {
  const SentMedia({required this.path, this.thumbPath});

  final String path;
  final String? thumbPath;

  @override
  List<Object?> get props => [path, thumbPath];
}

/// Sends the files of posts, shorts and stories: checks a file against [MediaPolicy], shrinks a video
/// that is over it, uploads it as `{folder}/{stem}.{ext}` and, for a video, its frame as
/// `{folder}/{stem}_thumb.jpg`. It is a repository because it combines sources (encoder, thumbnails,
/// storage) and keeps a shrunk copy until it is uploaded, so a retry does not encode again.
@lazySingleton
class ContentMediaRepository {
  ContentMediaRepository(this._files, this._thumbnails, this._compressor);

  final MediaFilesDatasource _files;
  final VideoThumbnailService _thumbnails;
  final VideoCompressService _compressor;

  /// Shrunk copies not uploaded yet, by source file.
  final _shrunk = <String, CompressedVideo>{};

  /// Copies left by an earlier run are deleted once, before the first encode (sends do not outlive
  /// the app).
  Future<void>? _leftoversDeleted;

  /// How much of a file's progress encoding takes when it runs; uploading takes the rest.
  static const _encodeShare = 0.3;

  /// Bytes are counted as the connection takes them, before the server has answered; the last of the
  /// bar waits for the answer.
  static const _bytesShare = 0.95;

  /// An encode may end up to this much shorter than its source (container rounding).
  static const _durationSlackMs = 1000;

  static const _defaultImage = ('jpg', 'image/jpeg');
  static const _defaultVideo = ('mp4', 'video/mp4');
  static const _contentTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'mp4': 'video/mp4',
    'm4v': 'video/mp4',
    'mov': 'video/quicktime',
  };

  /// The names of the files already in [folder], so a retry only sends what is missing.
  Future<Set<String>> existing(String folder) async =>
      (await _files.listFiles(folder)).toSet();

  /// Never throws: a cleanup must not hide why sending failed.
  Future<void> removeQuietly(List<String> paths) => _files.remove(paths);

  /// Uploads [item] unless a file of its name is in [existing] already; each file sent is added to
  /// [existing], so a caller that keeps the set across retries sends nothing twice. [onProgress] is told
  /// how much is done (0..1): the encode, when one runs, then the bytes of the file and its thumb. A file
  /// the policy refuses, or still too big after shrinking, throws a [ServerFailure] 413 before it is
  /// uploaded, as the bucket would.
  Future<SentMedia> send(
    ContentKind kind,
    MediaToSend item, {
    required String folder,
    required String stem,
    Set<String>? existing,
    void Function(double progress)? onProgress,
  }) async {
    final sent = existing ?? <String>{};
    final decision = await _decide(kind, item);
    // A shrunk copy is always MP4; the name follows the decision, so it is the same on every try.
    final (extension, contentType) = decision is MediaShrink
        ? _defaultVideo
        : _type(item);
    final name = '$stem.$extension';
    final thumbName = '${stem}_thumb.jpg';
    final sendsMain = !sent.contains(name);
    final sendsThumb = item.isVideo && !sent.contains(thumbName);

    var uploadStart = 0.0;
    var main = File(item.filePath);
    if (sendsMain && decision is MediaShrink) {
      final shrunk = await _shrink(item, decision, onProgress);
      if (shrunk != null) {
        main = File(shrunk.path);
        uploadStart = _encodeShare;
      }
    }
    final thumb = sendsThumb
        ? File(item.thumbFilePath ?? await _thumbnails.thumbnail(item.filePath))
        : null;

    // Read once bytes flow, so the files are there.
    int? mainLength;
    int? total;
    void report(int bytes) {
      mainLength ??= sendsMain ? main.lengthSync() : 0;
      total ??= mainLength! + (thumb?.lengthSync() ?? 0);
      final share = total == 0 ? 1.0 : bytes / total!;
      onProgress?.call(uploadStart + (1 - uploadStart) * share * _bytesShare);
    }

    if (sendsMain) {
      await _files.upload(
        path: '$folder/$name',
        file: main,
        contentType: contentType,
        onBytes: report,
      );
      sent.add(name);
      await _forgetShrunk(item.filePath);
    }
    if (thumb != null) {
      await _files.upload(
        path: '$folder/$thumbName',
        file: thumb,
        contentType: 'image/jpeg',
        onBytes: (bytes) {
          mainLength ??= sendsMain ? main.lengthSync() : 0;
          report(mainLength! + bytes);
        },
      );
      sent.add(thumbName);
    }
    onProgress?.call(1);
    return SentMedia(
      path: '$folder/$name',
      thumbPath: item.isVideo ? '$folder/$thumbName' : null,
    );
  }

  /// What [item] needs; a file the policy refuses throws.
  Future<MediaDecision> _decide(ContentKind kind, MediaToSend item) async {
    final decision = MediaPolicy.decide(
      kind,
      isVideo: item.isVideo,
      durationMs: item.durationMs,
      width: item.width,
      height: item.height,
      // Only a video's size changes what happens to it; the bucket still checks a photo's.
      sizeBytes:
          item.sizeBytes ??
          (item.isVideo ? await _lengthOf(item.filePath) : null),
    );
    if (decision is MediaRejected) {
      throw const ServerFailure(statusCode: _tooLarge);
    }
    return decision;
  }

  /// The shrunk copy to upload instead of [item] (made once, kept until it is uploaded), or null when
  /// shrinking would not make it smaller.
  Future<CompressedVideo?> _shrink(
    MediaToSend item,
    MediaShrink target,
    void Function(double progress)? onProgress,
  ) async {
    final ready = _shrunk[item.filePath];
    if (ready != null) return ready;

    await (_leftoversDeleted ??= _compressor.deleteAll());
    final video = await _compressor.compress(
      item.filePath,
      maxLongSide: target.longSide,
      videoBitrate: target.videoBitrate,
      audioBitrate: target.audioBitrate,
      onProgress: (done) => onProgress?.call(_encodeShare * done),
    );
    _checkShrunk(item, video);
    if (video.isOriginal) return null;
    return _shrunk[item.filePath] = video;
  }

  static const _tooLarge = 413;

  void _checkShrunk(MediaToSend item, CompressedVideo video) {
    final source = item.durationMs;
    final cut = source != null && video.durationMs < source - _durationSlackMs;
    if (cut) {
      unawaited(_compressor.delete(video.path));
      throw const UnexpectedFailure();
    }
    if (video.sizeBytes > MediaPolicy.maxBytes) {
      if (!video.isOriginal) unawaited(_compressor.delete(video.path));
      throw const ServerFailure(statusCode: _tooLarge);
    }
  }

  Future<void> _forgetShrunk(String source) async {
    final video = _shrunk.remove(source);
    if (video != null) await _compressor.delete(video.path);
  }

  /// Null when the file cannot be read; the upload then fails on its own.
  Future<int?> _lengthOf(String path) async {
    try {
      return await File(path).length();
    } on FileSystemException {
      return null;
    }
  }

  /// The extension and MIME type from the file name; a name that does not match the kind gets the kind's
  /// default (a photo goes as JPEG, a video as MP4).
  (String, String) _type(MediaToSend item) {
    final path = item.filePath;
    final dot = path.lastIndexOf('.');
    final extension = dot < 0 ? '' : path.substring(dot + 1).toLowerCase();
    final contentType = _contentTypes[extension];
    final matches =
        contentType != null &&
        contentType.startsWith(item.isVideo ? 'video/' : 'image/');
    if (matches) return (extension, contentType);
    return item.isVideo ? _defaultVideo : _defaultImage;
  }
}
