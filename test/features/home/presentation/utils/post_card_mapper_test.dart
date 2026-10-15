import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/features/home/presentation/utils/post_card_mapper.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

import '../../../post/post_fixtures.dart';

PostEntity _post({String? fullName, ContentAudience? visibility}) {
  final base = testPost('p1', authorId: 'a1', liked: true, saved: true);
  return PostEntity(
    id: base.id,
    authorId: base.authorId,
    username: base.username,
    fullName: fullName,
    location: 'Zamalek, Cairo',
    caption: 'Hello',
    likeCount: base.likeCount,
    commentCount: base.commentCount,
    commentsEnabled: false,
    visibility: visibility ?? base.visibility,
    createdAt: base.createdAt,
    likedByMe: base.likedByMe,
    savedByMe: base.savedByMe,
    media: base.media,
  );
}

void main() {
  group('postCardData', () {
    test('carries the post and shows the place as the city', () {
      final card = postCardData(_post(fullName: 'Nour Adel'), const []);
      expect(card.id, 'p1');
      expect(card.authorName, 'Nour Adel');
      expect(card.city, 'Zamalek, Cairo');
      expect(card.caption, 'Hello');
      expect(card.isLiked, isTrue);
      expect(card.isSaved, isTrue);
      expect(card.likeCount, 10);
      expect(card.commentCount, 2);
    });

    test(
      'carries the feeling, the tags, comments off and whose post it is',
      () {
        final post = PostEntity(
          id: 'p1',
          authorId: 'a1',
          username: 'nour',
          likeCount: 0,
          commentCount: 0,
          commentsEnabled: false,
          visibility: ContentAudience.public,
          createdAt: DateTime(2026),
          likedByMe: false,
          savedByMe: false,
          media: const [],
          mood: const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
          tags: const [PostTagEntity(userId: 'u2', username: 'omar')],
          tagCount: 3,
        );

        final mine = postCardData(post, const [], userId: 'a1');
        final theirs = postCardData(post, const [], userId: 'u9');

        expect(mine.isMine, isTrue);
        expect(theirs.isMine, isFalse);
        expect(mine.commentsEnabled, isFalse);
        expect(mine.mood?.key, 'happy');
        expect(mine.tags.single.userId, 'u2');
        expect(mine.tagCount, 3);
      },
    );

    test('falls back to the username without a name', () {
      expect(postCardData(_post(), const []).authorName, 'nour.adel');
      expect(
        postCardData(_post(fullName: '  '), const []).authorName,
        'nour.adel',
      );
    });

    test('only an Only me post is marked Only me', () {
      expect(postCardData(_post(), const []).isOnlyMe, isFalse);
      expect(
        postCardData(
          _post(visibility: ContentAudience.closeFriends),
          const [],
        ).isOnlyMe,
        isFalse,
      );
      expect(
        postCardData(
          _post(visibility: ContentAudience.onlyMe),
          const [],
        ).isOnlyMe,
        isTrue,
      );
    });

    test('every post shows its audience icon', () {
      expect(postCardData(_post(), const []).audienceIcon, AppAssets.globe);
      expect(
        postCardData(
          _post(visibility: ContentAudience.onlyMe),
          const [],
        ).audienceIcon,
        AppAssets.lock,
      );
    });
  });

  group('postOptionsData', () {
    test('knows whose post it is', () {
      expect(postOptionsData(_post(), userId: 'a1').isMine, isTrue);
      expect(postOptionsData(_post(), userId: 'other').isMine, isFalse);
      expect(postOptionsData(_post(), userId: null).isMine, isFalse);
    });

    test('carries what is set on the post', () {
      final data = postOptionsData(_post(), userId: 'x');
      expect(data.postId, 'p1');
      expect(data.username, 'nour.adel');
      expect(data.isSaved, isTrue);
      expect(data.commentsEnabled, isFalse);
    });
  });
}
