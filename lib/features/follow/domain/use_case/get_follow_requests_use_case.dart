import 'package:injectable/injectable.dart';

import '../../data/datasource/follows_datasource.dart';
import '../../data/model/follow_request_model.dart';

/// The follow requests waiting for the signed-in user.
@injectable
class GetFollowRequestsUseCase {
  GetFollowRequestsUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<List<FollowRequestModel>> call({int limit = 20, int offset = 0}) =>
      _follows.getRequests(limit: limit, offset: offset);
}
