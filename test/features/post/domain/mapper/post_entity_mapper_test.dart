import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/domain/mapper/post_entity_mapper.dart';

import '../../post_fixtures.dart';

void main() {
  test('a post saved on the device reads back as the same post', () {
    final original = testPost('orig', media: [testMedia('a/1.jpg')]);
    final post = PostEntity(
      id: 'p1',
      authorId: 'author',
      username: 'nour.adel',
      fullName: 'Nour Adel',
      caption: 'hello',
      location: 'Cairo',
      likeCount: 4,
      commentCount: 1,
      commentsEnabled: false,
      visibility: testPost('x').visibility,
      createdAt: DateTime.utc(2026, 10, 14),
      likedByMe: true,
      savedByMe: true,
      media: [
        testMedia('a/1.jpg'),
        testMedia('a/2.mp4', thumbPath: 'a/2.jpg'),
      ],
      mood: const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
      tags: const [
        PostTagEntity(
          userId: 'u1',
          username: 'sam',
          mediaPosition: 0,
          x: 0.2,
          y: 0.4,
        ),
      ],
      tagCount: 3,
      iAmTagged: true,
      isShare: true,
      original: original,
    );

    final back = PostEntityMapper.fromModel(PostEntityMapper.toModel(post));

    expect(back, post);
  });
}
