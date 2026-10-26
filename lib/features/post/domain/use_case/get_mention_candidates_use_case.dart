import 'package:injectable/injectable.dart';

import '../../data/datasource/comments_datasource.dart';
import '../../data/model/mention_person_model.dart';
import '../entity/mention_person_entity.dart';

/// People to suggest while typing `@query` in a comment on [postId]: people in the thread first, then
/// your followers. A row missing something the list needs is left out. Throws a `Failure` on error.
@injectable
class GetMentionCandidatesUseCase {
  GetMentionCandidatesUseCase(this._comments);

  final CommentsDatasource _comments;

  Future<List<MentionPersonEntity>> call(String postId, String query) async {
    final people = await _comments.getMentionCandidates(postId, query);
    return [for (final person in people) ?_entity(person)];
  }

  MentionPersonEntity? _entity(MentionPersonModel person) {
    final id = person.id;
    final username = person.username;
    if (id == null || username == null) return null;
    return MentionPersonEntity(
      id: id,
      username: username,
      fullName: person.fullName,
      avatarUrl: person.avatarUrl,
    );
  }
}
