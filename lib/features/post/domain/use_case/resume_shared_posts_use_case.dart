import 'package:injectable/injectable.dart';

import '../../data/repository/shared_posts_repository.dart';

/// At start: the posts the signed-in user shared that are not out yet go on (only what is missing is
/// sent), finished ones and their files on the device are forgotten, and so is a draft the server says is
/// finished. Home calls it when it opens. Never throws.
@injectable
class ResumeSharedPostsUseCase {
  ResumeSharedPostsUseCase(this._shared);

  final SharedPostsRepository _shared;

  Future<void> call() => _shared.resume();
}
