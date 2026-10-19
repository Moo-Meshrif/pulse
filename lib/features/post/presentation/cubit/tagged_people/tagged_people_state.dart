import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entity/tagged_person_entity.dart';
import '../../utils/enums/tagged_people_status.dart';

part 'tagged_people_state.freezed.dart';

@freezed
abstract class TaggedPeopleState with _$TaggedPeopleState {
  const factory TaggedPeopleState({
    @Default(TaggedPeopleStatus.loading) TaggedPeopleStatus status,
    @Default(<TaggedPersonEntity>[]) List<TaggedPersonEntity> people,

    /// One-shot: a follow did not go through and was put back.
    Failure? failure,
  }) = _TaggedPeopleState;
}
