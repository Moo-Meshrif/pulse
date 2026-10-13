import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../../data/datasource/stories_datasource.dart';
import '../../data/enums/story_audience.dart';
import '../utils/enums/story_audience_status.dart';
import 'story_audience_state.dart';

/// The Who can see this sheet (docs/specs/story/screenshots/stories-board-v3.png, panel 11): the audience
/// of one story and the numbers under each row. A choice is saved at once ("Changes apply right away").
@injectable
class StoryAudienceCubit extends BaseCubit<StoryAudienceState> {
  StoryAudienceCubit(
    this._stories,
    @factoryParam this.storyId,
    @factoryParam StoryAudience audience,
  ) : super(StoryAudienceState(audience: audience));

  final StoriesDatasource _stories;

  final String storyId;

  /// Loads the counts. The first load (and a retry) shows the loader; a reload after a list screen keeps
  /// the sheet as it is until the new numbers arrive, and as it is if they do not.
  Future<void> load() async {
    final isShowing = state.status == StoryAudienceStatus.ready;
    await run(
      _stories.getAudienceSummary,
      loading: isShowing
          ? null
          : state.copyWith(status: StoryAudienceStatus.loading),
      onSuccess: (summary) =>
          state.copyWith(summary: summary, status: StoryAudienceStatus.ready),
      onFailure: (_) =>
          isShowing ? null : state.copyWith(status: StoryAudienceStatus.failed),
    );
    // A Close friends story with nobody on the list goes back to Followers (the server does the same the
    // moment the list is emptied; this covers a story that was already in that state).
    if (state.status == StoryAudienceStatus.ready &&
        state.audience == StoryAudience.closeFriends &&
        state.summary.closeFriends == 0) {
      await select(StoryAudience.followers);
    }
  }

  /// A list screen saved: the counts moved. The first people added to an empty Close friends list also
  /// mark Close friends as the audience (the person went there to choose them); editing a list that
  /// already had people leaves the audience alone.
  Future<void> listEdited({required bool isCloseFriends}) async {
    final hadNoCloseFriends = (state.summary.closeFriends ?? 0) == 0;
    await load();
    if (isCloseFriends &&
        hadNoCloseFriends &&
        (state.summary.closeFriends ?? 0) > 0 &&
        state.audience == StoryAudience.followers) {
      await select(StoryAudience.closeFriends);
    }
  }

  /// Shows [audience] at once and saves it; goes back to the one before when saving fails.
  Future<void> select(StoryAudience audience) async {
    final before = state.audience;
    if (audience == before) return;
    emit(state.copyWith(audience: audience, failure: null));
    await run(
      () => _stories.setAudience(storyId, audience),
      onSuccess: (_) => null,
      onFailure: (failure) =>
          state.copyWith(audience: before, failure: failure),
    );
  }

  void clearFailure() => emit(state.copyWith(failure: null));
}
