import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/cached_picture.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../dimens/post_card_dimens.dart';
import '../../utils/post_card_media.dart';
import 'post_blurhash.dart';
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

  /// The picture to draw; the media's own link when null (a video draws its poster).
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

  String? get _cacheKey => widget.cacheKey ?? widget.media.cacheKey;

  String get _url => widget.url ?? widget.media.url;

  Future<void> _retry() async {
    await forgetPicture(_url, cacheKey: _cacheKey);
    if (mounted) setState(() => _attempt++);
  }

  @override
  Widget build(BuildContext context) {
    final blurhash = PostBlurhash(hash: widget.media.blurhash);
    return Stack(
      fit: StackFit.expand,
      children: [
        blurhash,
        AppImage.network(
          _url,
          key: ValueKey(_attempt),
          cacheKey: _cacheKey,
          fit: widget.fit,
          errorBuilder: (_) =>
              PostRetryBadge(icon: AppAssets.image, onRetry: _retry),
          frameBuilder: (context, child, frame, isSync) => AnimatedOpacity(
            opacity: frame == null && !isSync ? 0 : 1,
            duration: PostMotion.imageFadeIn,
            child: child,
          ),
        ),
      ],
    );
  }
}
