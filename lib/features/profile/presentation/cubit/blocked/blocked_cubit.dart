import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../data/datasource/blocks_datasource.dart';
import '../../../data/model/blocked_person_model.dart';
import '../../utils/enums/profile_status.dart';
import 'blocked_state.dart';

/// Settings > Blocked accounts (docs/specs/profile/screens/s6-blocked-accounts.md): a paged list,
/// newest block first, and a one-tap Unblock that removes the row.
@injectable
class BlockedCubit extends BaseCubit<BlockedState> {
  BlockedCubit(this._blocks) : super(const BlockedState());

  final BlocksDatasource _blocks;

  /// Counts the loads from the top: an answer for an older load is dropped.
  int _generation = 0;

  Future<void> load() {
    final generation = ++_generation;
    return run(
      _blocks.list,
      loading: state.copyWith(
        status: ProfileStatus.loading,
        people: const [],
        hasMore: false,
        more: LoadMoreStatus.idle,
      ),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              status: ProfileStatus.ready,
              people: page,
              hasMore: page.length == BlocksDatasource.pageSize,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(status: ProfileStatus.failed),
    );
  }

  /// Pull to refresh: keeps the rows until the first page is in. A failure keeps them.
  Future<void> refresh() {
    final generation = ++_generation;
    return run(
      _blocks.list,
      prevent: state.isRefreshing,
      loading: state.copyWith(isRefreshing: true),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              status: ProfileStatus.ready,
              people: page,
              hasMore: page.length == BlocksDatasource.pageSize,
              more: LoadMoreStatus.idle,
              isRefreshing: false,
            ),
      onFailure: (failure) => generation != _generation
          ? null
          : state.copyWith(isRefreshing: false, failure: failure),
    );
  }

  /// Loads the next page. A failed page waits for [retry].
  Future<void> loadMore({bool retry = false}) {
    final generation = _generation;
    return run(
      () => _blocks.list(before: state.people.last),
      prevent:
          !state.hasMore ||
          state.people.isEmpty ||
          state.status != ProfileStatus.ready ||
          state.more == LoadMoreStatus.loading ||
          (state.more == LoadMoreStatus.failed && !retry),
      loading: state.copyWith(more: LoadMoreStatus.loading),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              people: _withoutRepeats(state.people, page),
              hasMore: page.length == BlocksDatasource.pageSize,
              more: LoadMoreStatus.idle,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(more: LoadMoreStatus.failed),
    );
  }

  /// Unblocks [person] and removes the row. A failure keeps the row.
  Future<void> unblock(BlockedPersonModel person) async {
    final id = person.id;
    if (id == null || state.unblocking.contains(id)) return;
    emit(state.copyWith(unblocking: {...state.unblocking, id}));
    await run(
      () => _blocks.unblock(id),
      onSuccess: (_) {
        return state.copyWith(
          people: [
            for (final shown in state.people)
              if (shown.id != id) shown,
          ],
          unblocking: {...state.unblocking}..remove(id),
          unblockedUsername: person.username,
        );
      },
      onFailure: (failure) => state.copyWith(
        unblocking: {...state.unblocking}..remove(id),
        failure: failure,
      ),
    );
  }

  List<BlockedPersonModel> _withoutRepeats(
    List<BlockedPersonModel> shown,
    List<BlockedPersonModel> page,
  ) {
    final ids = {for (final person in shown) person.id};
    return [
      ...shown,
      for (final person in page)
        if (!ids.contains(person.id)) person,
    ];
  }
}
