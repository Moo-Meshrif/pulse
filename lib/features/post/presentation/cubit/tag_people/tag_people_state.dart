import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/tag_person_entity.dart';
import '../../utils/enums/tag_people_status.dart';
import '../../utils/new_post_limits.dart';
import '../../utils/tag_choice.dart';

part 'tag_people_state.freezed.dart';

@freezed
abstract class TagPeopleState with _$TagPeopleState {
  const TagPeopleState._();

  const factory TagPeopleState({
    /// Who is being tagged, in the order they were picked.
    required List<TagChoice> chosen,
    @Default('') String query,
    @Default(TagPeopleStatus.loading) TagPeopleStatus status,

    /// The suggested people, or the matches for [query].
    @Default(<TagPersonEntity>[]) List<TagPersonEntity> people,

    /// One-shot: someone was picked while the post already has the most people.
    @Default(false) bool isOverLimit,
  }) = _TagPeopleState;

  bool get isFull => chosen.length >= TagLimits.maxPeople;

  bool get isSearching => query.trim().isNotEmpty;

  bool isChosen(String id) => chosen.any((choice) => choice.id == id);
}
