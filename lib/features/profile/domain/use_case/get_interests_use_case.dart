import 'package:injectable/injectable.dart';

import '../../../../core/error/result.dart';
import '../../data/datasource/interests_datasource.dart';
import '../../data/model/interest_model.dart';

/// The topics offered on the Interests step, in display order. The entry point other features call.
@injectable
class GetInterestsUseCase {
  GetInterestsUseCase(this._interests);

  final InterestsDatasource _interests;

  Future<Result<List<InterestModel>>> call() => _interests.getInterests();
}
