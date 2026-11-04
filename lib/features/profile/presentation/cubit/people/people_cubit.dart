import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../../../follow/domain/use_case/toggle_follow_use_case.dart';
import '../../../data/datasource/people_datasource.dart';
import '../../../data/datasource/profile_page_datasource.dart';
import '../../../data/enums/people_kind.dart';
import '../../../data/model/person_model.dart';
import '../../../domain/use_case/get_current_user_id_use_case.dart';
import '../../utils/enums/profile_status.dart';
import '../../utils/people_limits.dart';
import 'people_state.dart';

/// One list of people on a profile (docs/specs/profile/screens/s13-people-list.md): pages, a search that
/// waits for a pause in typing, and a Follow pill on every row that answers at once and is put back
/// when the request fails.
@injectable
class PeopleCubit extends BaseCubit<PeopleState> {
  PeopleCubit(
    this._people,
    this._pages,
    this._toggleFollow,
    GetCurrentUserIdUseCase currentUserId,
    @factoryParam this.kind,
    @factoryParam this.userId,
  ) : super(PeopleState(userId: currentUserId()));

  final PeopleDatasource _people;
  final ProfilePageDatasource _pages;
  final ToggleFollowUseCase _toggleFollow;
  final PeopleKind kind;
  final String userId;

  Timer? _debounce;

  /// Counts the loads from the top: an answer for an older search or a reloaded list is dropped.
  int _generation = 0;

  /// People with a follow request in flight: a second tap waits.
  final _followPending = <String>{};

  /// Loads the first page of what is typed (also the retry).
  Future<void> load() {
    final generation = ++_generation;
    return run(
      () => _firstPage(),
      loading: state.copyWith(
        status: ProfileStatus.loading,
        people: const [],
        hasMore: false,
        more: LoadMoreStatus.idle,
        isLocked: false,
      ),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              status: ProfileStatus.ready,
              people: page.people,
              hasMore: page.people.length == PeopleDatasource.pageSize,
              more: LoadMoreStatus.idle,
              isLocked: page.isLocked,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(status: ProfileStatus.failed),
    );
  }

  /// Pull to refresh: reads the first page again and keeps the rows until it is in. A failure keeps them.
  Future<void> refresh() {
    final generation = ++_generation;
    return run(
      () => _firstPage(),
      prevent: state.isRefreshing,
      loading: state.copyWith(isRefreshing: true),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              status: ProfileStatus.ready,
              people: page.people,
              hasMore: page.people.length == PeopleDatasource.pageSize,
              more: LoadMoreStatus.idle,
              isLocked: page.isLocked,
              isRefreshing: false,
            ),
      onFailure: (failure) => generation != _generation
          ? null
          : state.copyWith(isRefreshing: false, failure: failure),
    );
  }

  /// Search as you type: one request per pause; blank again shows everyone.
  void queryChanged(String query) {
    if (query.trim() == state.query.trim()) return;
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _generation++;
    _debounce = Timer(PeopleLimits.searchDelay, load);
  }

  /// Loads the next page. A failed page waits for [retry] (the list calls this on every scroll).
  Future<void> loadMore({bool retry = false}) {
    final generation = _generation;
    return run(
      () => _fetch(before: state.people.last),
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
              hasMore: page.length == PeopleDatasource.pageSize,
              more: LoadMoreStatus.idle,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(more: LoadMoreStatus.failed),
    );
  }

  /// Follows [person], or unfollows (or cancels the request to) them when you already do.
  Future<void> toggleFollow(PersonModel person) async {
    final id = person.id;
    if (id == null || id == state.userId || !_followPending.add(id)) return;
    final before = person.followStatus ?? FollowStatus.none;
    final follow = before == FollowStatus.none;
    _setFollow(id, follow ? FollowStatus.accepted : FollowStatus.none);
    await run(
      () => _toggleFollow(id, follow: follow),
      onSuccess: (status) {
        _followPending.remove(id);
        _setFollow(id, status);
      },
      onFailure: (failure) {
        _followPending.remove(id);
        _setFollow(id, before);
        emit(state.copyWith(failure: failure));
      },
    );
  }

  String? get _query {
    final text = state.query.trim();
    return text.isEmpty ? null : text;
  }

  Future<List<PersonModel>> _fetch({PersonModel? before}) =>
      _people.getPeople(kind, userId, query: _query, before: before);

  /// The first page; when it is empty and nothing is typed, whether that is because the account is
  /// private and not followed (the server answers nothing for it).
  Future<({List<PersonModel> people, bool isLocked})> _firstPage() async {
    final people = await _fetch();
    if (people.isNotEmpty || _query != null || kind == PeopleKind.mutual) {
      return (people: people, isLocked: false);
    }
    return (people: people, isLocked: await _isLocked());
  }

  Future<bool> _isLocked() async {
    if (userId == state.userId) return false;
    try {
      final page = await _pages.getProfilePage(userId);
      return page?.isPrivate == true &&
          FollowStatus.fromJson(page?.iFollow) != FollowStatus.accepted;
    } on Failure {
      return false;
    }
  }

  void _setFollow(String id, FollowStatus status) => emit(
    state.copyWith(
      people: [
        for (final person in state.people)
          person.id == id ? person.withFollow(status) : person,
      ],
    ),
  );

  /// The page after [shown], without anyone already on screen (a follow made while paging shifts the pages).
  List<PersonModel> _withoutRepeats(
    List<PersonModel> shown,
    List<PersonModel> page,
  ) {
    final ids = {for (final person in shown) person.id};
    return [
      ...shown,
      for (final person in page)
        if (!ids.contains(person.id)) person,
    ];
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
