import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/post/data/datasource/post_likes_datasource.dart';
import 'package:pulse/features/post/data/model/liked_by_preview_model.dart';
import 'package:pulse/features/post/domain/use_case/get_liked_by_previews_use_case.dart';

class _MockLikes extends Mock implements PostLikesDatasource {}

void main() {
  test('maps the rows by post id and drops one without a username', () async {
    final likes = _MockLikes();
    when(() => likes.getPreviews(['p1', 'p2'])).thenAnswer(
      (_) async => {
        'p1': const LikedByPreviewModel(
          postId: 'p1',
          firstUsername: 'salma.ash',
          others: 3,
          onlyMe: true,
          avatars: [LikedByAvatarModel(id: 'u1', name: 'Salma')],
        ),
        'p2': const LikedByPreviewModel(postId: 'p2', others: 1),
      },
    );

    final previews = await GetLikedByPreviewsUseCase(likes)(['p1', 'p2']);

    expect(previews.keys, ['p1']);
    expect(previews['p1']?.firstName, 'salma.ash');
    expect(previews['p1']?.others, 3);
    expect(previews['p1']?.isOnlyMe, isTrue);
    expect(previews['p1']?.avatars.single.id, 'u1');
  });
}
