import '../../../post/domain/entity/post_entity.dart';
import '../../../post/domain/entity/post_media_entity.dart';
import '../../../post/domain/use_case/sign_post_media_urls_use_case.dart';
import '../../../post/presentation/utils/post_card_media.dart';
import '../../../post/presentation/utils/post_media_paths.dart';
import 'feed_post.dart';

/// Turns posts into [FeedPost]s with their media links signed.
class FeedPostSigner {
  const FeedPostSigner(this._signMedia);

  final SignPostMediaUrlsUseCase _signMedia;

  /// The posts with the links of all their media signed in a single request. A file whose link could not be
  /// made is left out of its post.
  Future<List<FeedPost>> sign(List<PostEntity> posts) async {
    final paths = posts
        .expand((post) => [...post.media, ...?post.original?.media])
        .pathsToSign;
    final links = paths.isEmpty
        ? const <String, String>{}
        : await _signMedia(paths);
    return posts
        .map(
          (post) => FeedPost(
            entity: post,
            media: _cardMediaOf(post.media, links),
            originalMedia: _cardMediaOf(
              post.original?.media ?? const [],
              links,
            ),
          ),
        )
        .toList();
  }

  /// The posts with no request: every media is kept with no link, only its cache key, sizes and blurhash.
  /// For the copy saved on the phone, whose links expired long ago.
  List<FeedPost> unsigned(List<PostEntity> posts) => posts
      .map(
        (post) => FeedPost(
          entity: post,
          media: post.media.map(_unsignedMedia).toList(),
          originalMedia: (post.original?.media ?? const [])
              .map(_unsignedMedia)
              .toList(),
        ),
      )
      .toList();

  PostCardMedia _unsignedMedia(PostMediaEntity item) => PostCardMedia(
    isVideo: item.isVideo,
    posterCacheKey: item.thumbPath,
    cacheKey: item.path,
    width: item.width,
    height: item.height,
    durationMs: item.durationMs,
    blurhash: item.blurhash,
  );

  List<PostCardMedia> _cardMediaOf(
    List<PostMediaEntity> media,
    Map<String, String> links,
  ) => media.map((item) => _cardMedia(item, links)).nonNulls.toList();

  /// Null when the file's link could not be made.
  PostCardMedia? _cardMedia(PostMediaEntity item, Map<String, String> links) {
    final url = links[item.path];
    if (url == null) return null;
    return PostCardMedia(
      isVideo: item.isVideo,
      url: url,
      posterUrl: links[item.thumbPath],
      posterCacheKey: item.thumbPath,
      cacheKey: item.path,
      width: item.width,
      height: item.height,
      durationMs: item.durationMs,
      blurhash: item.blurhash,
    );
  }
}
