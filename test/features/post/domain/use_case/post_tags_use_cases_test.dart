import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/post/data/datasource/post_tags_datasource.dart';
import 'package:pulse/features/post/data/enums/follow_state.dart';
import 'package:pulse/features/post/data/model/tag_person_model.dart';
import 'package:pulse/features/post/data/model/tagged_person_model.dart';
import 'package:pulse/features/post/domain/use_case/get_tagged_people_use_case.dart';
import 'package:pulse/features/post/domain/use_case/remove_my_tag_use_case.dart';
import 'package:pulse/features/post/domain/use_case/search_tag_people_use_case.dart';

class _MockTags extends Mock implements PostTagsDatasource {}

void main() {
  late _MockTags tags;

  setUp(() => tags = _MockTags());

  test('search maps the people and leaves out a row without a name', () async {
    when(() => tags.searchPeople('sa')).thenAnswer(
      (_) async => const [
        TagPersonModel(id: 'u2', username: 'sara', canTag: true),
        TagPersonModel(id: 'u3', username: 'omar'),
        TagPersonModel(username: 'no-id', canTag: true),
        TagPersonModel(id: 'u5', canTag: true),
      ],
    );

    final people = await SearchTagPeopleUseCase(tags)('sa');

    expect(people.map((p) => p.id), ['u2', 'u3']);
    expect(people.map((p) => p.canTag), [true, false]);
  });

  test('a search with no text asks for the suggested people', () async {
    when(() => tags.searchPeople(null)).thenAnswer((_) async => const []);

    await SearchTagPeopleUseCase(tags)();

    verify(() => tags.searchPeople(null)).called(1);
  });

  test('tagged people default an unknown follow state to none', () async {
    when(() => tags.getTaggedPeople('p1')).thenAnswer(
      (_) async => const [
        TaggedPersonModel(
          id: 'u2',
          username: 'sara',
          followState: FollowState.following,
        ),
        TaggedPersonModel(id: 'u3', username: 'omar'),
        TaggedPersonModel(id: 'u4'),
      ],
    );

    final people = await GetTaggedPeopleUseCase(tags)('p1');

    expect(people.map((p) => p.followState), [
      FollowState.following,
      FollowState.none,
    ]);
  });

  test('remove my tag hands back what the server said', () async {
    when(() => tags.removeMyTag('p1')).thenAnswer((_) async => true);
    when(() => tags.removeMyTag('p2')).thenAnswer((_) async => false);

    final useCase = RemoveMyTagUseCase(tags);

    expect(await useCase('p1'), isTrue);
    expect(await useCase('p2'), isFalse);
  });
}
