import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../../data/model/profile_grid_item_model.dart';
import '../../../data/model/profile_page_model.dart';
import '../../utils/enums/profile_status.dart';

part 'other_profile_state.freezed.dart';

@freezed
abstract class OtherProfileState with _$OtherProfileState {
  const factory OtherProfileState({
    @Default(ProfileStatus.loading) ProfileStatus status,
    ProfilePageModel? page,
    @Default(false) bool notFound,
    @Default(FollowStatus.none) FollowStatus follow,
    @Default(0) int followers,
    @Default(false) bool busy,
    @Default(0) int tab,
    @Default(ProfileStatus.loading) ProfileStatus gridStatus,
    @Default(<ProfileGridItemModel>[]) List<ProfileGridItemModel> items,
    @Default(<String, String>{}) Map<String, String> urls,
    @Default(false) bool hasMore,
    @Default(LoadMoreStatus.idle) LoadMoreStatus more,
    @Default(false) bool refreshing,
    @Default(<String, dynamic>{}) Map<String, dynamic> mutual,
    Failure? failure,
    @Default(false) bool requestSent,
  }) = _OtherProfileState;
}
