import 'package:injectable/injectable.dart';

import '../../data/datasource/profile_datasource.dart';

/// The signed-in person's id, or null without a session. Lists use it to tell their own posts apart.
@injectable
class GetCurrentUserIdUseCase {
  GetCurrentUserIdUseCase(this._profiles);

  final ProfileDatasource _profiles;

  String? call() => _profiles.currentUserId;
}
