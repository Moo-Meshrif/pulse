import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../data/repository/post_repository.dart';
import '../../../domain/entity/tag_person_entity.dart';
import '../../utils/enums/tag_people_status.dart';
import '../../utils/new_post_limits.dart';
import '../../utils/tag_choice.dart';
import '../../utils/tag_people_args.dart';
import 'tag_people_state.dart';

/// The Tag people page (docs/specs/post/screens/s6-tag-people.md): suggested people or search matches, and
/// up to [TagLimits.maxPeople] chosen. It only chooses people; their spots on photos are set on Tag in photo.
@injectable
class TagPeopleCubit extends BaseCubit<TagPeopleState> {
  TagPeopleCubit(this._posts, @factoryParam TagPeopleArgs args)
    : _initial = args.chosen,
      super(TagPeopleState(chosen: args.chosen));

  final PostRepository _posts;
  final List<TagChoice> _initial;

  Timer? _debounce;

  /// A newer search makes an older answer stale.
  int _request = 0;

  /// Something differs from what the page opened with.
  bool get hasChanges => !listEquals(state.chosen, _initial);

  /// Loads the suggested people (also the retry of whatever is typed).
  Future<void> load() => _fetch();

  /// Search as you type: one request per pause; blank again goes back to the suggested people.
  void queryChanged(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _request++;
    _debounce = Timer(TagLimits.searchDelay, _fetch);
  }

  /// A row tap: tags the person, or takes them off. Someone who does not allow tags, or a full post,
  /// ignores it (the full post says so once).
  void toggle(TagPersonEntity person) {
    if (state.isChosen(person.id)) {
      remove(person.id);
      return;
    }
    if (!person.canTag) return;
    if (state.isFull) {
      emit(state.copyWith(isOverLimit: true));
      return;
    }
    emit(state.copyWith(chosen: [...state.chosen, TagChoice.person(person)]));
  }

  void remove(String id) => emit(
    state.copyWith(
      chosen: state.chosen.where((choice) => choice.id != id).toList(),
    ),
  );

  /// Tag in photo returned: the chosen people with their spots.
  void spotsChanged(List<TagChoice> chosen) =>
      emit(state.copyWith(chosen: chosen));

  void clearOverLimit() => emit(state.copyWith(isOverLimit: false));

  Future<void> _fetch() {
    final request = ++_request;
    final text = state.query.trim();
    return run(
      () => _posts.searchTagPeople(text.isEmpty ? null : text),
      loading: state.copyWith(status: TagPeopleStatus.loading),
      onSuccess: (people) => request == _request
          ? state.copyWith(status: TagPeopleStatus.ready, people: people)
          : null,
      onFailure: (_) => request == _request
          ? state.copyWith(status: TagPeopleStatus.failed)
          : null,
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
