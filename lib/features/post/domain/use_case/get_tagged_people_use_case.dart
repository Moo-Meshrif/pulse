import 'package:injectable/injectable.dart';

import '../../data/datasource/post_tags_datasource.dart';
import '../../data/enums/follow_state.dart';
import '../entity/tagged_person_entity.dart';

/// Everyone tagged on [postId], with how you follow each. A row missing something the list needs is left
/// out.
@injectable
class GetTaggedPeopleUseCase {
  GetTaggedPeopleUseCase(this._tags);

  final PostTagsDatasource _tags;

  Future<List<TaggedPersonEntity>> call(String postId) async {
    final people = await _tags.getTaggedPeople(postId);
    return [
      for (final person in people)
        if (person.id != null && person.username != null)
          TaggedPersonEntity(
            id: person.id!,
            username: person.username!,
            fullName: person.fullName,
            avatarUrl: person.avatarUrl,
            followState: person.followState ?? FollowState.none,
          ),
    ];
  }
}
