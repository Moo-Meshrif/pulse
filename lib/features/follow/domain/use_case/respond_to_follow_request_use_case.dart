import 'package:injectable/injectable.dart';

import '../../data/datasource/follows_datasource.dart';

/// Accepts or declines one follow request, or accepts them all ("Accept all").
@injectable
class RespondToFollowRequestUseCase {
  RespondToFollowRequestUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<void> call(String followerId, {required bool accept}) => accept
      ? _follows.acceptRequest(followerId)
      : _follows.declineRequest(followerId);

  Future<void> acceptAll() => _follows.acceptAllRequests();
}
