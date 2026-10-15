import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../../../core/enums/report_reason.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/services/gallery_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/enums/mute_scope.dart';
import '../../../../shared/content/domain/event/content_delete_event.dart';
import '../../../../shared/content/domain/use_case/remove_media_files_use_case.dart';
import '../../../../shared/content/domain/use_case/report_content_use_case.dart';
import '../../../../shared/content/domain/use_case/set_mute_use_case.dart';
import '../../data/datasource/stories_datasource.dart';
import '../../data/model/story_model.dart';
import '../../domain/entity/story_rail_item_entity.dart';
import '../../domain/use_case/get_story_rail_use_case.dart';
import '../utils/enums/story_pause_reason.dart';
import '../utils/enums/story_viewer_status.dart';
import '../utils/story_start_index.dart';
import 'story_viewer_state.dart';

/// Walks through the people of the story rail and each person's stories. Playback timing (the bar, the
/// video position) belongs to the widgets; this holds where playback is, why it is paused, the like and
/// the "seen" mark.
@injectable
class StoryViewerCubit extends BaseCubit<StoryViewerState> {
  StoryViewerCubit(
    this._rail,
    this._stories,
    this._gallery,
    this._setMute,
    this._reportContent,
    this._removeFiles,
    this._events,
  ) : super(const StoryViewerState());

  static const seenAfter = Duration(seconds: 1);

  final GetStoryRailUseCase _rail;
  final StoriesDatasource _stories;
  final GalleryService _gallery;
  final SetMuteUseCase _setMute;
  final ReportContentUseCase _reportContent;
  final RemoveMediaFilesUseCase _removeFiles;
  final EventBus _events;

  Timer? _seenTimer;

  /// Stories deleted on screen whose request has not been sent yet, for Undo.
  final _deleting =
      <String, ({StoryModel story, String authorId, int index})>{};

  /// People muted from this viewer and where they stood, for Undo.
  final _muted = <String, ({StoryRailItemEntity person, int index})>{};
  String? _seenTimerStoryId;

  Future<void> load(String authorId) async {
    emit(const StoryViewerState());
    final List<StoryRailItemEntity> people;
    try {
      people = await _rail();
    } on Failure catch (failure) {
      emit(state.copyWith(status: StoryViewerStatus.failed, failure: failure));
      return;
    }
    final index = people.indexWhere((p) => p.authorId == authorId);
    if (index < 0) {
      emit(state.copyWith(isFinished: true));
      return;
    }
    emit(
      state.copyWith(
        status: StoryViewerStatus.ready,
        people: people,
        personIndex: index,
      ),
    );
    await _enter(index);
  }

  Future<void> retry(String authorId) => load(authorId);

  Future<void> retryPerson(String authorId) async {
    emit(
      state.copyWith(failedAuthors: {...state.failedAuthors}..remove(authorId)),
    );
    await _fetch(authorId);
    _afterChange();
  }

  Future<void> showPerson(int index) async {
    if (index < 0 || index >= state.people.length) return;
    if (index == state.personIndex && state.currentStories != null) return;
    emit(state.copyWith(personIndex: index, storyIndex: 0));
    await _enter(index);
  }

  Future<void> _enter(int index, {bool fromStart = false}) async {
    final id = state.people[index].authorId;
    if (state.stories[id] == null) await _fetch(id);
    if (state.personIndex != index) return; // the user moved on while it loaded
    final list = state.stories[id];
    if (list != null && list.isEmpty) {
      await next(); // everything expired meanwhile: nobody to show
      return;
    }
    emit(
      state.copyWith(
        storyIndex: list == null || fromStart ? 0 : storyStartIndex(list),
      ),
    );
    _afterChange();
    final following = index + 1;
    if (following < state.people.length) {
      unawaited(_fetch(state.people[following].authorId));
    }
  }

  Future<void> _fetch(String authorId) async {
    if (state.stories.containsKey(authorId)) return;
    try {
      final list = await _stories.getAuthorStories(authorId);
      emit(state.copyWith(stories: {...state.stories, authorId: list}));
    } on Failure {
      emit(state.copyWith(failedAuthors: {...state.failedAuthors, authorId}));
    }
  }

  /// The next story; after a person's last one, the next person; after the last person, close.
  Future<void> next() async {
    final list = state.currentStories;
    if (list != null && state.storyIndex < list.length - 1) {
      emit(state.copyWith(storyIndex: state.storyIndex + 1));
      _afterChange();
      return;
    }
    final following = state.personIndex + 1;
    if (following >= state.people.length) {
      _seenTimer?.cancel();
      emit(state.copyWith(isFinished: true));
      return;
    }
    await showPerson(following);
  }

  /// The story before; before a person's first one, the person before (from their first story); before
  /// the very first, this story again.
  Future<void> previous() async {
    if (state.storyIndex > 0) {
      emit(state.copyWith(storyIndex: state.storyIndex - 1));
      _afterChange();
      return;
    }
    if (state.personIndex > 0) {
      final before = state.personIndex - 1;
      emit(state.copyWith(personIndex: before, storyIndex: 0));
      await _enter(before, fromStart: true);
      return;
    }
    emit(state.copyWith(restarts: state.restarts + 1));
    _afterChange();
  }

  void pause(StoryPauseReason reason) {
    if (state.pauses.contains(reason)) return;
    emit(state.copyWith(pauses: {...state.pauses, reason}));
    _afterChange();
  }

  void resume(StoryPauseReason reason) {
    if (!state.pauses.contains(reason)) return;
    emit(state.copyWith(pauses: {...state.pauses}..remove(reason)));
    _afterChange();
  }

  /// Likes the story on screen, or takes the like back. Shows at once and goes back if the call fails.
  Future<void> toggleLike() async {
    final story = state.story;
    final id = story?.id;
    if (story == null || id == null) return;
    final liked = !(story.likedByMe ?? false);
    _replace(id, (s) => s.copyWith(likedByMe: liked));
    await run(
      () => _stories.setLiked(id, liked: liked),
      onSuccess: (_) => null,
      onFailure: (_) => _replace(id, (s) => s.copyWith(likedByMe: !liked)),
    );
  }

  /// The audience of [storyId] changed (the Who can see this sheet saved it).
  void updateAudience(String storyId, ContentAudience audience) =>
      _replace(storyId, (s) => s.copyWith(audience: audience));

  /// Hides the person on screen from the rail and skips them. Null when it worked, else why not.
  Future<Failure?> muteCurrent() async {
    final authorId = state.person?.authorId;
    if (authorId == null) return null;
    Failure? failed;
    await run(
      () => _mute(authorId, muted: true),
      onSuccess: (_) {
        _removeCurrentPerson();
        return null;
      },
      onFailure: (failure) {
        failed = failure;
        return null;
      },
    );
    return failed;
  }

  /// Takes a mute back and brings the person back into the viewer, at their place, where it stops on
  /// their first story.
  Future<Failure?> unmute(String authorId) async {
    final failure = await _attempt(() => _mute(authorId, muted: false));
    if (failure == null) _restorePerson(authorId);
    return failure;
  }

  /// Delete, step 1: the story on screen (yours) goes at once, then your next one shows, or the viewer
  /// closes after the last. The request waits for [commitDelete], so Undo can still bring it back.
  /// Returns the story's id, or null when there is nothing to delete.
  String? deleteCurrent() {
    final story = state.story;
    final authorId = state.person?.authorId;
    final id = story?.id;
    if (story == null || id == null || authorId == null) return null;
    final list = state.stories[authorId] ?? const <StoryModel>[];
    _deleting[id] = (
      story: story,
      authorId: authorId,
      index: max(0, list.indexWhere((s) => s.id == id)),
    );
    _announce(id, ContentDeleteStage.pending);
    _removeStory(authorId, id);
    return id;
  }

  /// Delete, step 2 (the notice ended without Undo): sends the request. A failure puts the story back
  /// and is returned for the caller to show. Safe after the viewer closed.
  Future<Failure?> commitDelete(String storyId) async {
    final pending = _deleting[storyId];
    if (pending == null) return null;
    final failure = await _attempt(() => _delete(pending.story));
    if (failure != null) {
      _restoreStory(storyId);
    } else {
      _deleting.remove(storyId);
      _announce(storyId, ContentDeleteStage.deleted);
    }
    return failure;
  }

  /// Takes the delete back: the story returns to the rail and, if the viewer is still open, to its
  /// place.
  void undoDelete(String storyId) => _restoreStory(storyId);

  void _announce(String storyId, ContentDeleteStage stage) =>
      _events.fire(ContentDeleteEvent(ContentKind.story, storyId, stage));

  void _restoreStory(String storyId) {
    final pending = _deleting.remove(storyId);
    if (pending == null) return;
    _announce(storyId, ContentDeleteStage.restored);
    if (isClosed || state.isFinished) return;
    final list = [...?state.stories[pending.authorId]];
    final index = min(pending.index, list.length);
    list.insert(index, pending.story);
    emit(
      state.copyWith(
        stories: {...state.stories, pending.authorId: list},
        storyIndex: index,
        restarts: state.restarts + 1,
      ),
    );
    _afterChange();
  }

  /// Sends a report for [storyId]. Throws a [Failure] when it cannot (the report sheet shows it).
  Future<void> report(
    String storyId,
    ReportReason reason,
    String? note,
  ) async =>
      await _reportContent(ContentKind.story, storyId, reason, note: note);

  /// Mutes the person's stories (core), then tells the rail on screen elsewhere to reload.
  Future<void> _mute(String authorId, {required bool muted}) async {
    await _setMute(authorId, muted: muted, scope: MuteScope.stories);
    _stories.notifyRailChanged();
  }

  /// Deletes the row, then its files (best effort).
  Future<void> _delete(StoryModel story) async {
    await _stories.deleteStory(story);
    await _removeFiles([?story.path, ?story.thumbPath]);
  }

  /// After a report was sent: on to the next story.
  Future<void> skipReported() => next();

  Future<Failure?> saveImage(Uint8List bytes) =>
      _attempt(() => _gallery.saveImage(bytes));

  Future<Failure?> saveVideo(String url) =>
      _attempt(() => _gallery.saveVideoFromUrl(url));

  Future<Failure?> _attempt(Future<void> Function() action) async {
    Failure? failed;
    await run(
      action,
      onSuccess: (_) => null,
      onFailure: (failure) {
        failed = failure;
        return null;
      },
    );
    return failed;
  }

  void _removeCurrentPerson() {
    final index = state.personIndex;
    final id = state.person?.authorId;
    if (id == null) return;
    _seenTimer?.cancel();
    _muted[id] = (person: state.person!, index: index);
    final people = [...state.people]..removeAt(index);
    final stories = {...state.stories}..remove(id);
    if (index >= people.length) {
      emit(state.copyWith(people: people, stories: stories, isFinished: true));
      return;
    }
    emit(state.copyWith(people: people, stories: stories, storyIndex: 0));
    unawaited(_enter(index, fromStart: true));
  }

  void _restorePerson(String authorId) {
    final muted = _muted.remove(authorId);
    // A viewer that already closed has nothing to show: Home's rail reloads by itself.
    if (muted == null || isClosed || state.isFinished) return;
    if (state.people.any((p) => p.authorId == authorId)) return;
    final index = min(muted.index, state.people.length);
    emit(
      state.copyWith(
        people: [...state.people]..insert(index, muted.person),
        personIndex: index,
        storyIndex: 0,
      ),
    );
    unawaited(_enter(index, fromStart: true));
  }

  void _removeStory(String authorId, String storyId) {
    final list = state.stories[authorId] ?? const <StoryModel>[];
    final left = [
      for (final s in list)
        if (s.id != storyId) s,
    ];
    if (left.isEmpty) {
      _seenTimer?.cancel();
      emit(
        state.copyWith(
          stories: {...state.stories, authorId: left},
          isFinished: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        stories: {...state.stories, authorId: left},
        storyIndex: state.storyIndex.clamp(0, left.length - 1),
        restarts: state.restarts + 1,
      ),
    );
    _afterChange();
  }

  StoryViewerState? _replace(
    String id,
    StoryModel Function(StoryModel) change,
  ) {
    final stories = {
      for (final entry in state.stories.entries)
        entry.key: [for (final s in entry.value) s.id == id ? change(s) : s],
    };
    final next = state.copyWith(stories: stories);
    emit(next);
    return next;
  }

  void _afterChange() => _syncSeenTimer();

  void _syncSeenTimer() {
    final story = state.story;
    final id = story?.id;
    final mine = state.person?.isMe ?? false;
    final playing = !state.isPaused && !state.isFinished;
    final needsMark = id != null && !mine && story?.seenByMe != true;
    if (!playing || !needsMark) {
      _seenTimer?.cancel();
      _seenTimer = null;
      _seenTimerStoryId = null;
      return;
    }
    if (_seenTimerStoryId == id) return;
    _seenTimer?.cancel();
    _seenTimerStoryId = id;
    _seenTimer = Timer(seenAfter, () => _mark(id));
  }

  Future<void> _mark(String id) async {
    _seenTimer = null;
    _seenTimerStoryId = null;
    _replace(id, (s) => s.copyWith(seenByMe: true));
    try {
      await _stories.markViewed(id);
    } on Failure {
      // Not worth interrupting the viewer for; the next visit marks it again.
    }
  }

  @override
  Future<void> close() {
    _seenTimer?.cancel();
    return super.close();
  }
}
