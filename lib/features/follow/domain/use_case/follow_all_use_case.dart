import 'package:injectable/injectable.dart';

import '../../data/datasource/follows_datasource.dart';

/// "Follow all": follows several people at once; returns how many were new.
@injectable
class FollowAllUseCase {
  FollowAllUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<int> call(List<String> userIds) => _follows.followAll(userIds);
}
