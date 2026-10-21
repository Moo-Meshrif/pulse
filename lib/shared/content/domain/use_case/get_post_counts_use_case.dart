import 'package:injectable/injectable.dart';

import '../../data/model/post_count_model.dart';
import '../../data/repository/content_changes_repository.dart';

/// The current like and comment counts of the posts [ids] a screen shows (at most 100 are answered).
/// Posts the user can no longer see are left out. Throws a `Failure` on error.
@injectable
class GetPostCountsUseCase {
  GetPostCountsUseCase(this._changes);

  final ContentChangesRepository _changes;

  Future<List<PostCountModel>> call(List<String> ids) =>
      _changes.postCounts(ids);
}
