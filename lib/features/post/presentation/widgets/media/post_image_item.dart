import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/utils/cached_picture.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../utils/post_card_media.dart';
import 'post_blurhash.dart';
import 'post_retry_badge.dart';

/// One photo of a post: the blurhash until it loads, then the picture fades in. If it fails the blurhash
/// stays with a retry badge.
class PostImageItem extends StatefulWidget {
  const PostImageItem({super.key, required this.media, this.url});

  final PostCardMedia media;

  /// The picture to draw; the media's own link when null (a video draws its poster).
  final String? url;

  @override
  State<PostImageItem> createState() => _PostImageItemState();
}

class _PostImageItemState extends State<PostImageItem> {
  int _attempt = 0;

  String get _url => widget.url ?? widget.media.url;

  Future<void> _retry() async {
    await forgetPicture(_url, cacheKey: widget.media.cacheKey);
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
          cacheKey: widget.media.cacheKey,
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
