import 'package:injectable/injectable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/utils/either.dart';
import '../../data/datasource/follows_datasource.dart';

/// Follows or unfollows one person, or follows several at once ("Follow all").
@injectable
class SetFollowingUseCase {
  SetFollowingUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<Result<Unit>> call(String userId, {required bool following}) =>
      following ? _follows.follow(userId) : _follows.unfollow(userId);

  Future<Result<Unit>> all(List<String> userIds) async =>
      (await _follows.followAll(userIds)).map((_) => unit);
}
