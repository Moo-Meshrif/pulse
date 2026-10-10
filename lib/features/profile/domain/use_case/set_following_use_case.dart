import 'package:injectable/injectable.dart';

import '../../data/datasource/follows_datasource.dart';

/// Follows or unfollows one person, or follows several at once ("Follow all").
@injectable
class SetFollowingUseCase {
  SetFollowingUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<void> call(String userId, {required bool following}) =>
      following ? _follows.follow(userId) : _follows.unfollow(userId);

  Future<void> all(List<String> userIds) => _follows.followAll(userIds);
}
