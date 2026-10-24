import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A network picture cached on the device, in memory and on disk, under [cacheKey] (default: the [url]).
/// For pictures behind signed links, pass the storage path as the key: the link changes every time it is
/// fetched, the path never does, so a picture seen before is not downloaded again. Show it with
/// `Image(image: cachedPicture(...))`.
CachedNetworkImageProvider cachedPicture(String url, {String? cacheKey}) =>
    CachedNetworkImageProvider(url, cacheKey: cacheKey);

/// A picture that is only read from the device cache under [cacheKey], never from the network. It fails
/// when the file is not cached, so the place that shows it falls back to its error look.
ImageProvider savedPicture(String cacheKey) => _SavedPicture(cacheKey);

class _SavedPicture extends ImageProvider<_SavedPicture> {
  const _SavedPicture(this.cacheKey);

  final String cacheKey;

  @override
  Future<_SavedPicture> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _SavedPicture key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(
    codec: _decode(decode),
    scale: 1,
    debugLabel: cacheKey,
  );

  Future<ui.Codec> _decode(ImageDecoderCallback decode) async {
    final file = await CachedNetworkImageProvider.defaultCacheManager
        .getFileFromCache(cacheKey);
    if (file == null) throw StateError('Picture $cacheKey is not cached');
    final bytes = await ui.ImmutableBuffer.fromUint8List(
      await file.file.readAsBytes(),
    );
    return decode(bytes);
  }

  @override
  bool operator ==(Object other) =>
      other is _SavedPicture && other.cacheKey == cacheKey;

  @override
  int get hashCode => cacheKey.hashCode;
}

/// Loads [picture] in the background so it shows at once later. A failure is ignored: the place that shows
/// it loads it again, and handles its own error.
Future<void> preloadPicture(BuildContext context, ImageProvider picture) =>
    precacheImage(picture, context, onError: (_, _) {});

/// Forgets a cached picture, in memory and on disk (Retry after it failed to load).
Future<void> forgetPicture(String url, {String? cacheKey}) async {
  await cachedPicture(url, cacheKey: cacheKey).evict();
  await CachedNetworkImageProvider.defaultCacheManager.removeFile(
    cacheKey ?? url,
  );
}
