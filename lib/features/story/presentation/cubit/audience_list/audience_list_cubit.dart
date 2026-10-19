import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/domain/use_case/get_audience_summary_use_case.dart';
import '../../../data/datasource/stories_datasource.dart';
import '../../../data/enums/audience_list.dart';
import '../../../data/enums/audience_tab.dart';
import '../../../data/model/audience_person_model.dart';
import '../../utils/enums/audience_list_status.dart';
import 'audience_list_state.dart';

/// A list screen (docs/specs/story/screenshots/stories-board-v3.png, panel 12): your followers with search
/// and the Suggested / Selected tabs. Taps are kept on the screen and saved together by Done.
@injectable
class AudienceListCubit extends BaseCubit<AudienceListState> {
  AudienceListCubit(this._stories, this._summary, @factoryParam this.list)
    : super(const AudienceListState());

  static const searchDelay = Duration(milliseconds: 300);

  /// People per page.
  static const pageSize = 30;

  final StoriesDatasource _stories;
  final GetAudienceSummaryUseCase _summary;

  final AudienceList list;

  Timer? _debounce;

  /// A newer search makes an older answer stale.
  int _request = 0;

  Future<void> start() async {
    try {
      final summary = await _summary();
      emit(
        state.copyWith(
          savedCount: list == AudienceList.closeFriends
              ? summary.closeFriends
              : summary.hidden,
        ),
      );
    } on Object {
      // The count is shown from the people that load; no reason to stop here.
    }
    await _loadFirst();
  }

  Future<void> retry() => _loadFirst();

  void setTab(AudienceTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
    unawaited(_loadFirst());
  }

  /// Search as you type: one request per pause.
  void setQuery(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(searchDelay, _loadFirst);
  }

  void toggle(AudiencePersonModel person) {
    final id = person.userId;
    if (id == null) return;
    final now = !state.isSelected(person);
    emit(
      state.copyWith(
        changes: {...state.changes, id: now},
        original: {
          ...state.original,
          id: state.original[id] ?? (person.selected ?? false),
        },
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status != AudienceListStatus.ready) {
      return;
    }
    final request = _request;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));
    await run(
      () => _stories.getAudiencePeople(
        list,
        tab: state.tab,
        query: state.query,
        limit: pageSize,
        offset: state.people.length,
      ),
      onSuccess: (page) {
        if (request != _request) return null;
        return state.copyWith(
          people: [...state.people, ...page],
          hasMore: page.length >= pageSize,
          isLoadingMore: false,
        );
      },
      onFailure: (_) =>
          state.copyWith(isLoadingMore: false, loadMoreFailed: true),
    );
  }

  /// Done: saves what was added and taken off; closes the screen (via [AudienceListState.isSaved]).
  Future<void> save() async {
    if (state.isSaving) return;
    final changes = state.changes.entries;
    final add = changes
        .where((e) => e.value && !(state.original[e.key] ?? false))
        .map((e) => e.key)
        .toList();
    final remove = changes
        .where((e) => !e.value && (state.original[e.key] ?? false))
        .map((e) => e.key)
        .toList();
    if (add.isEmpty && remove.isEmpty) {
      emit(state.copyWith(isSaved: true));
      return;
    }
    emit(state.copyWith(isSaving: true, failure: null));
    await run(
      () => _stories.updateAudienceList(list, add: add, remove: remove),
      onSuccess: (_) => state.copyWith(isSaving: false, isSaved: true),
      onFailure: (failure) => state.copyWith(isSaving: false, failure: failure),
    );
  }

  void clearFailure() => emit(state.copyWith(failure: null));

  Future<void> _loadFirst() async {
    final request = ++_request;
    emit(
      state.copyWith(
        status: AudienceListStatus.loading,
        people: const [],
        hasMore: false,
        isLoadingMore: false,
        loadMoreFailed: false,
      ),
    );
    await run(
      () => _stories.getAudiencePeople(
        list,
        tab: state.tab,
        query: state.query,
        limit: pageSize,
        offset: 0,
      ),
      onSuccess: (page) {
        if (request != _request) return null;
        return state.copyWith(
          status: AudienceListStatus.ready,
          people: page,
          hasMore: page.length >= pageSize,
        );
      },
      onFailure: (_) {
        if (request != _request) return null;
        return state.copyWith(status: AudienceListStatus.failed);
      },
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
