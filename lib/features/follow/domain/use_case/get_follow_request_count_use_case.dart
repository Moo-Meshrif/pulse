import 'package:injectable/injectable.dart';

import '../../data/datasource/follows_datasource.dart';

/// How many follow requests are waiting (the badge on Activity).
@injectable
class GetFollowRequestCountUseCase {
  GetFollowRequestCountUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<int> call() => _follows.getRequestCount();
}
