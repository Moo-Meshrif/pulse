import 'package:injectable/injectable.dart';

import '../../data/datasource/posts_datasource.dart';

/// Short-lived links for post media paths, by path. Home signs the paths of the posts on screen; a path
/// that cannot be signed is missing from the result.
@injectable
class SignPostMediaUrlsUseCase {
  SignPostMediaUrlsUseCase(this._posts);

  final PostsDatasource _posts;

  Future<Map<String, String>> call(List<String> paths) =>
      _posts.signMediaUrls(paths);
}
