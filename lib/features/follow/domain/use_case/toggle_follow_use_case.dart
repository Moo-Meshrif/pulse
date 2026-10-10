import 'package:injectable/injectable.dart';

import '../../data/datasource/follows_datasource.dart';
import '../../data/enums/follow_status.dart';

/// The follow button: follows or unfollows one person and returns where the follow stands afterwards.
/// A private profile answers [FollowStatus.pending] (a request); unfollowing, or cancelling a request,
/// answers [FollowStatus.none].
@injectable
class ToggleFollowUseCase {
  ToggleFollowUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<FollowStatus> call(String userId, {required bool follow}) async {
    if (follow) return _follows.follow(userId);
    await _follows.unfollow(userId);
    return FollowStatus.none;
  }
}
