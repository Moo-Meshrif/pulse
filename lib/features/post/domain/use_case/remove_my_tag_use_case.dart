import 'package:injectable/injectable.dart';

import '../../data/datasource/post_tags_datasource.dart';

/// Removes your tag from [postId] (and from every photo on it). Returns false when you were not tagged.
/// The owner is not told, and you cannot be tagged on that post again for 24 hours.
@injectable
class RemoveMyTagUseCase {
  RemoveMyTagUseCase(this._tags);

  final PostTagsDatasource _tags;

  Future<bool> call(String postId) => _tags.removeMyTag(postId);
}
