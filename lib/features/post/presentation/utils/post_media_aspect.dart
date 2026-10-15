import '../dimens/post_card_dimens.dart';
import 'post_card_media.dart';

/// The media's width over height, kept inside the allowed range.
double postMediaAspect(PostCardMedia first) {
  final raw = first.height <= 0 ? 1.0 : first.width / first.height;
  return raw.clamp(
    PostCardDimens.mediaMinAspect,
    PostCardDimens.mediaMaxAspect,
  );
}
