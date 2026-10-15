import 'package:injectable/injectable.dart';

import '../../data/datasource/post_tags_datasource.dart';
import '../entity/tag_person_entity.dart';

/// People you can tag: the ones you follow for a blank [query], otherwise those matching it. A row
/// missing something the list needs is left out.
@injectable
class SearchTagPeopleUseCase {
  SearchTagPeopleUseCase(this._tags);

  final PostTagsDatasource _tags;

  Future<List<TagPersonEntity>> call([String? query]) async {
    final people = await _tags.searchPeople(query);
    return [
      for (final person in people)
        if (person.id != null && person.username != null)
          TagPersonEntity(
            id: person.id!,
            username: person.username!,
            fullName: person.fullName,
            avatarUrl: person.avatarUrl,
            canTag: person.canTag ?? false,
          ),
    ];
  }
}
