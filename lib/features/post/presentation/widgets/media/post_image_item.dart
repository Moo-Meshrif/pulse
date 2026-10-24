import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/cached_picture.dart';
import '../../../../../core/widgets/app_blurhash.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../utils/post_card_media.dart';
import 'post_retry_badge.dart';

/// One photo of a post: the blurhash until it loads, then the picture fades in. If it fails the blurhash
/// stays with a retry badge.
class PostImageItem extends StatefulWidget {
  const PostImageItem({
    super.key,
    required this.media,
    this.url,
    this.cacheKey,
    this.fit = BoxFit.contain,
  });

  final PostCardMedia media;

  /// The picture to draw; the media's own link when null (a video draws its poster). With no link at all
  /// (a saved post) the picture is read from the device cache.
  final String? url;

  /// The cache key of [url]; the media's own when null.
  final String? cacheKey;

  /// The image fit
  final BoxFit fit;

  @override
  State<PostImageItem> createState() => _PostImageItemState();
}

class _PostImageItemState extends State<PostImageItem> {
  int _attempt = 0;

  /// The post came from the phone with no link: its picture may be on the device. Null until known.
  bool _startedSaved = false;
  bool? _isOnPhone;

  String? get _cacheKey => widget.cacheKey ?? widget.media.cacheKey;

  String? get _url => widget.url ?? widget.media.url;

  Future<void> _checkPhone() async {
    _startedSaved = true;
    final key = _cacheKey;
    final file = key == null
        ? null
        : await CachedNetworkImageProvider.defaultCacheManager.getFileFromCache(
            key,
          );
    if (mounted) setState(() => _isOnPhone = file != null);
  }

  /// A picture that is on the phone (or may be, until we know) shows no blurhash while the linked one
  /// loads: the saved one is already on screen or about to be.
  bool get _showsBlurhash => !_startedSaved || _isOnPhone == false;

  Future<void> _retry() async {
    final url = _url;
    if (url == null) return;
    await forgetPicture(url, cacheKey: _cacheKey);
    if (mounted) setState(() => _attempt++);
  }

  @override
  void initState() {
    super.initState();
    if (_url == null) _checkPhone();
  }

  @override
  Widget build(BuildContext context) {
    final blurhash = AppBlurhash(hash: widget.media.blurhash);
    final url = _url;
    final cacheKey = _cacheKey;
    if (url == null && cacheKey == null) return blurhash;
    // The posts saved on the phone have no link yet. The saved picture shows no blurhash while it is read
    // (a picture on the phone is not "loading"; the blurhash only stands in when it is not there). Both
    // pictures share one key and play gapless, so when the link arrives the saved one stays on screen until
    // the linked one is ready.
    final key = ValueKey(_attempt);
    if (url == null) {
      return AppImage.saved(
        cacheKey!,
        key: key,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_) => blurhash,
      );
    }
    return AppImage.network(
      url,
      key: key,
      cacheKey: cacheKey,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (_) => Stack(
        fit: StackFit.expand,
        children: [
          blurhash,
          PostRetryBadge(icon: AppAssets.image, onRetry: _retry),
        ],
      ),
      frameBuilder: (context, child, frame, isSync) =>
          frame == null && !isSync && _showsBlurhash ? blurhash : child,
    );
  }
}
