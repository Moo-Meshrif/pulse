import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../data/model/blocked_person_model.dart';
import '../../utils/enums/profile_status.dart';

part 'blocked_state.freezed.dart';

@freezed
abstract class BlockedState with _$BlockedState {
  const factory BlockedState({
    @Default(ProfileStatus.loading) ProfileStatus status,
    @Default(<BlockedPersonModel>[]) List<BlockedPersonModel> people,
    @Default(false) bool hasMore,
    @Default(LoadMoreStatus.idle) LoadMoreStatus more,

    /// A pull to refresh is running; the rows stay.
    @Default(false) bool isRefreshing,

    /// People whose Unblock is in flight.
    @Default(<String>{}) Set<String> unblocking,

    /// One-shot: a refresh or an unblock did not go through.
    Failure? failure,

    /// One-shot: the @username just unblocked, for the "Unblocked @name" notice.
    String? unblockedUsername,
  }) = _BlockedState;
}
