import 'package:injectable/injectable.dart';

import '../../data/datasource/follows_datasource.dart';
import '../../data/enums/follow_status.dart';

/// Where the signed-in user's follow of one person stands now. Throws a `Failure` on error.
@injectable
class GetFollowStatusUseCase {
  GetFollowStatusUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<FollowStatus> call(String userId) => _follows.getStatus(userId);
}
