import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../data/model/profile_grid_item_model.dart';
import '../../../data/model/profile_page_model.dart';
import '../../utils/enums/profile_status.dart';
import '../../utils/enums/profile_tab.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    /// The header: the profile and its numbers.
    @Default(ProfileStatus.loading) ProfileStatus status,
    ProfilePageModel? page,

    /// The header is the copy saved on the phone (offline): it has no numbers.
    @Default(false) bool fromDevice,
    @Default(ProfileTab.posts) ProfileTab tab,

    /// The active tab's grid.
    @Default(ProfileStatus.loading) ProfileStatus gridStatus,
    @Default(<ProfileGridItemModel>[]) List<ProfileGridItemModel> items,
    @Default(false) bool hasMore,
    @Default(LoadMoreStatus.idle) LoadMoreStatus loadMore,
    @Default(false) bool isRefreshing,

    /// Short-lived picture links by storage path.
    @Default(<String, String>{}) Map<String, String> urls,

    /// Why the last pull to refresh failed; the screen shows it once.
    Failure? refreshFailure,
  }) = _ProfileState;
}
