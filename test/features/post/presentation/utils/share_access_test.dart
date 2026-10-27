import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/presentation/utils/enums/share_access.dart';
import 'package:pulse/features/post/presentation/utils/share_access_of.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

PostEntity _post({
  String id = 'p1',
  String authorId = 'a1',
  ContentAudience visibility = ContentAudience.public,
  bool isShare = false,
  PostEntity? original,
}) => PostEntity(
  id: id,
  authorId: authorId,
  username: 'sara',
  likeCount: 0,
  commentCount: 0,
  commentsEnabled: true,
  visibility: visibility,
  createdAt: DateTime(2026, 10, 21),
  likedByMe: false,
  savedByMe: false,
  media: const [],
  isShare: isShare,
  original: original,
);

void main() {
  group('ShareAccess.of (the table in s12-share-sheet.md)', () {
    test('Public: everything, whoever the author', () {
      for (final mine in [true, false]) {
        expect(
          ShareAccess.of(visibility: ContentAudience.public, isMine: mine),
          ShareAccess.full,
        );
      }
    });

    test(
      'Followers: your own goes to the feed and story, others get nothing',
      () {
        expect(
          ShareAccess.of(visibility: ContentAudience.followers, isMine: true),
          ShareAccess.ownFollowers,
        );
        expect(
          ShareAccess.of(visibility: ContentAudience.followers, isMine: false),
          ShareAccess.none,
        );
      },
    );

    test('Close friends and Only me: nothing', () {
      for (final audience in [
        ContentAudience.closeFriends,
        ContentAudience.onlyMe,
      ]) {
        for (final mine in [true, false]) {
          expect(
            ShareAccess.of(visibility: audience, isMine: mine),
            ShareAccess.none,
          );
        }
      }
    });
  });

  group('shareAccessOf', () {
    test('a plain post follows its own audience and author', () {
      final post = _post(visibility: ContentAudience.followers);

      expect(shareAccessOf(post, userId: 'a1'), ShareAccess.ownFollowers);
      expect(shareAccessOf(post, userId: 'u9'), ShareAccess.none);
      expect(shareTarget(post), post);
    });

    test('a share follows its original, and shares the original', () {
      final original = _post(id: 'o1', authorId: 'a2');
      final share = _post(id: 's1', isShare: true, original: original);

      expect(shareAccessOf(share, userId: 'u9'), ShareAccess.full);
      expect(shareTarget(share), original);
    });

    test('a share whose original is gone has nothing to share', () {
      final share = _post(id: 's1', isShare: true);

      expect(shareAccessOf(share, userId: 'a1'), ShareAccess.none);
      expect(shareTarget(share), isNull);
    });
  });
}
