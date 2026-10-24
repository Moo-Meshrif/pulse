import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/home/presentation/utils/feed_post_signer.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';

import '../../../post/post_fixtures.dart';

class _Sign extends Mock implements SignPostMediaUrlsUseCase {}

void main() {
  test('unsigned keeps every media with no link, and asks for none', () {
    final sign = _Sign();
    final posts = FeedPostSigner(sign).unsigned([
      testPost(
        'p1',
        media: [
          testMedia('a/1.jpg'),
          testMedia('a/2.mp4', thumbPath: 'a/2.jpg'),
        ],
      ),
    ]);

    final media = posts.single.media;
    expect(media, hasLength(2));
    expect(media.map((m) => m.url), [null, null]);
    expect(media.map((m) => m.posterUrl), [null, null]);
    expect(media.map((m) => m.cacheKey), ['a/1.jpg', 'a/2.mp4']);
    expect(media.last.posterCacheKey, 'a/2.jpg');
    expect(media.last.isVideo, isTrue);
    verifyNever(() => sign(any()));
  });
}
