import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/cached_picture.dart';

void main() {
  test(
    'the cache key is the one given, so a new signed link reuses the file',
    () {
      final first = cachedPicture(
        'https://x.test/a.jpg?token=1',
        cacheKey: 'u/a.jpg',
      );
      final second = cachedPicture(
        'https://x.test/a.jpg?token=2',
        cacheKey: 'u/a.jpg',
      );
      expect(first.url, isNot(second.url));
      expect(first.cacheKey, second.cacheKey);
    },
  );

  test('without a key the link is the key', () {
    expect(cachedPicture('https://x.test/avatar.jpg').cacheKey, isNull);
  });
}
