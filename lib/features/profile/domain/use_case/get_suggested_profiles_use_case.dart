import 'package:injectable/injectable.dart';

import '../../../../core/error/result.dart';
import '../../data/datasource/follows_datasource.dart';
import '../../data/enums/suggestion_tab.dart';
import '../../data/model/suggested_profile_model.dart';

/// The people offered on the Follow step for one tab. The entry point other features call.
@injectable
class GetSuggestedProfilesUseCase {
  GetSuggestedProfilesUseCase(this._follows);

  final FollowsDatasource _follows;

  Future<Result<List<SuggestedProfileModel>>> call(SuggestionTab tab) =>
      _follows.getSuggestedProfiles(tab);
}
