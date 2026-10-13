import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/enums/audience_tab.dart';
import '../../data/model/audience_person_model.dart';
import '../utils/enums/audience_list_status.dart';

part 'audience_list_state.freezed.dart';

@freezed
abstract class AudienceListState with _$AudienceListState {
  const AudienceListState._();

  const factory AudienceListState({
    @Default(AudienceListStatus.loading) AudienceListStatus status,
    @Default(AudienceTab.suggested) AudienceTab tab,
    @Default('') String query,
    @Default([]) List<AudiencePersonModel> people,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
    @Default(false) bool loadMoreFailed,

    /// How many were on the list when the screen opened.
    @Default(0) int savedCount,

    /// What was tapped, by user id: the new state of that person, not yet saved.
    @Default({}) Map<String, bool> changes,

    /// Where each tapped person stood on the server when first tapped (to tell add from remove).
    @Default({}) Map<String, bool> original,
    @Default(false) bool isSaving,

    /// One-shot: the list was saved; the screen closes.
    @Default(false) bool isSaved,

    /// One-shot: saving failed.
    Failure? failure,
  }) = _AudienceListState;

  bool isSelected(AudiencePersonModel person) =>
      changes[person.userId] ?? person.selected ?? false;

  /// Something was ticked or unticked and not saved yet (Done is only for that).
  bool get hasChanges =>
      changes.entries.any((e) => e.value != (original[e.key] ?? false));

  /// The list's size as it will be after Done.
  int get selectedCount {
    var count = savedCount;
    for (final entry in changes.entries) {
      final was = original[entry.key] ?? false;
      if (entry.value && !was) count++;
      if (!entry.value && was) count--;
    }
    return count;
  }
}
