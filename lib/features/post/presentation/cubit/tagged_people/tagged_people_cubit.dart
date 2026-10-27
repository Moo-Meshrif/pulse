import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../../../follow/domain/use_case/toggle_follow_use_case.dart';
import '../../../data/enums/follow_state.dart';
import '../../../data/repository/post_repository.dart';
import '../../../domain/entity/tagged_person_entity.dart';
import '../../utils/enums/tagged_people_status.dart';
import 'tagged_people_state.dart';

/// The tagged people sheet of one post: the list, and Follow / Following / Requested on each row, shown at
/// once and put back when the request fails.
@injectable
class TaggedPeopleCubit extends BaseCubit<TaggedPeopleState> {
  TaggedPeopleCubit(this._posts, this._toggleFollow, @factoryParam this.postId)
    : super(const TaggedPeopleState());

  final PostRepository _posts;
  final ToggleFollowUseCase _toggleFollow;
  final String postId;

  /// People whose follow request is in flight: a second tap waits.
  final _pending = <String>{};

  /// Loads the list (also the retry).
  Future<void> load() => run(
    () => _posts.taggedPeople(postId),
    loading: state.copyWith(status: TaggedPeopleStatus.loading),
    onSuccess: (people) =>
        state.copyWith(status: TaggedPeopleStatus.ready, people: people),
    onFailure: (_) => state.copyWith(status: TaggedPeopleStatus.failed),
  );

  /// Follows [person], or unfollows / cancels the request when they are already followed or requested.
  Future<void> toggleFollow(TaggedPersonEntity person) async {
    final current = _find(person.id);
    if (current == null ||
        current.followState == FollowState.me ||
        !_pending.add(person.id)) {
      return;
    }
    final follow = current.followState == FollowState.none;
    _set(person.id, follow ? FollowState.following : FollowState.none);
    await run(
      () => _toggleFollow(person.id, follow: follow),
      onSuccess: (status) {
        _pending.remove(person.id);
        _set(person.id, switch (status) {
          FollowStatus.accepted => FollowState.following,
          FollowStatus.pending => FollowState.pending,
          FollowStatus.none => FollowState.none,
        });
      },
      onFailure: (failure) {
        _pending.remove(person.id);
        return _withState(
          person.id,
          current.followState,
        ).copyWith(failure: failure);
      },
    );
  }

  TaggedPersonEntity? _find(String id) =>
      state.people.where((person) => person.id == id).firstOrNull;

  void _set(String id, FollowState followState) =>
      emit(_withState(id, followState));

  TaggedPeopleState _withState(String id, FollowState followState) =>
      state.copyWith(
        failure: null,
        people: state.people
            .map(
              (person) => person.id == id
                  ? TaggedPersonEntity(
                      id: person.id,
                      username: person.username,
                      fullName: person.fullName,
                      avatarUrl: person.avatarUrl,
                      followState: followState,
                    )
                  : person,
            )
            .toList(),
      );
}
