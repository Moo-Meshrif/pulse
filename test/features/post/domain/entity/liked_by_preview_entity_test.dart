import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/domain/entity/liked_by_preview_entity.dart';

void main() {
  const me = LikedByAvatarEntity(id: 'me', name: 'Sam');
  const other = LikedByAvatarEntity(id: 'o', name: 'Ola', avatarUrl: 'x');
  const row = LikedByPreviewEntity(
    firstName: 'Ola',
    others: 1,
    avatars: [other, me],
  );

  test('replaces only my avatar with the current name and photo', () {
    final next = row.withAvatarOf('me', name: 'Samir', avatarUrl: 'new');
    expect(next.avatars.first, other);
    expect(
      next.avatars.last,
      const LikedByAvatarEntity(id: 'me', name: 'Samir', avatarUrl: 'new'),
    );
    expect(next.others, 1);
  });

  test('a row without me is returned as it is', () {
    expect(identical(row.withAvatarOf('zz', name: 'Z'), row), isTrue);
  });
}
