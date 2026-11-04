import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../data/model/person_model.dart';
import '../../utils/enums/profile_status.dart';

part 'people_state.freezed.dart';

@freezed
abstract class PeopleState with _$PeopleState {
  const PeopleState._();

  const factory PeopleState({
    @Default(ProfileStatus.loading) ProfileStatus status,

    /// What is typed in the search field; blank shows everyone.
    @Default('') String query,
    @Default(<PersonModel>[]) List<PersonModel> people,
    @Default(false) bool hasMore,
    @Default(LoadMoreStatus.idle) LoadMoreStatus more,

    /// A pull to refresh is running; the rows stay.
    @Default(false) bool isRefreshing,

    /// The list is empty because the account is private and the signed-in user does not follow it.
    @Default(false) bool isLocked,

    /// The signed-in user, who has no Follow button on their own row.
    String? userId,

    /// One-shot: a follow or a refresh did not go through (a follow is put back).
    Failure? failure,
  }) = _PeopleState;

  bool get isSearching => query.trim().isNotEmpty;
}
