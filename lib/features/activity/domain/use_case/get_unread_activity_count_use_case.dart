import 'package:injectable/injectable.dart';

import '../../data/datasource/activity_datasource.dart';

/// How many things wait in Activity: unread notifications plus follow requests. Home's bell shows its dot
/// while this is above zero.
@injectable
class GetUnreadActivityCountUseCase {
  GetUnreadActivityCountUseCase(this._activity);

  final ActivityDatasource _activity;

  Future<int> call() async {
    final unread = await _activity.getUnreadCount();
    return (unread.activity ?? 0) + (unread.followRequests ?? 0);
  }
}
