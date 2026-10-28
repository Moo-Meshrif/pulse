import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/entity/content_publish_status.dart';
import '../../../../../shared/content/domain/event/content_changed.dart';
import '../../../../../shared/content/domain/event/content_delete_event.dart';
import '../../../../../shared/content/domain/event/content_ping.dart';
import '../../../../../shared/content/domain/use_case/check_content_changes_use_case.dart';
import '../../../../../shared/content/domain/use_case/get_publish_status_use_case.dart';
import '../../../../../shared/content/domain/use_case/retry_publish_use_case.dart';
import '../../../../post/domain/event/feed_refresh_requested.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../../profile/domain/event/profile_updated.dart';
import '../../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../../../story/domain/entity/story_rail_item_entity.dart';
import '../../../../story/domain/event/story_author_seen.dart';
import '../../../../story/domain/event/story_rail_changed.dart';
import '../../../../story/domain/use_case/get_story_rail_use_case.dart';
import 'story_rail_state.dart';

/// The Stories rail of Home: the people with a story, and how posting your own is going.
@injectable
class StoryRailCubit extends BaseCubit<StoryRailState>
    with EventCubitMixin<StoryRailState> {
  StoryRailCubit(
    this._rail,
    this._events,
    GetPublishStatusUseCase uploadStatus,
    this._retryUpload,
    GetLastAccountUseCase account,
    this._checkChanges,
  ) : account = account(),
      super(StoryRailState(upload: uploadStatus(ContentKind.story)));

  final GetStoryRailUseCase _rail;
  final EventBus _events;
  final RetryPublishUseCase _retryUpload;
  final CheckContentChangesUseCase _checkChanges;

  /// You, from the saved account: the photo or initials in the posting ring before you have a story.
  final LastAccountEntity? account;

  @override
  EventBus get events => _events;

  /// The rail as the server sent it; the state shows it without the stories being deleted.
  List<StoryRailItemEntity> _loaded = const [];

  /// Your stories hidden while their delete can still be undone.
  final _pendingDeletes = <String>{};
  bool _isLoading = false;
  bool _reloadAgain = false;

  /// Shows the rail saved on the phone at once (when there is one), then loads the fresh one. Keeps it
  /// current: a mute or delete reloads it, and so does a story that finished
  /// posting, a refresh of Home, or a story that was added or deleted elsewhere (the change check).
  Future<void> start() async {
    listenTo<StoryRailChanged>((_) => load());
    listenTo<ProfileUpdated>((_) => load());
    listenTo<StoryAuthorSeen>(_onAuthorSeen);
    listenTo<ContentDeleteEvent>(_onDelete);
    listenTo<FeedRefreshRequested>((_) => load());
    listenTo<ContentPublishStatus>(_onUpload);
    listenTo<ContentChanged>(_onContentChanged);
    listenTo<ContentPing>((event) {
      if (event.kind == ContentKind.story) unawaited(checkChanges());
    });
    await _showSaved();
    final loading = load();
    unawaited(checkChanges());
    return loading;
  }

  /// The saved rail, until the server's arrives. A saved rail with no one on it counts: the skeleton goes
  /// at once. Nothing happens when none is saved.
  Future<void> _showSaved() => run(
    _rail.saved,
    onSuccess: (items) {
      if (items == null) return null;
      _loaded = items;
      return state.copyWith(items: _visible(), isLoaded: true);
    },
    onFailure: (_) => null,
  );

  /// Asks what changed in stories since the last check; the answer arrives as a [ContentChanged] event.
  /// Quiet when offline. Called when Home opens and when the app comes back.
  Future<void> checkChanges() => _checkChanges(ContentKind.story);

  /// The rail holds one row per person, so a story that came or went is a new read of the rail, quietly
  /// (the rail on screen stays until the answer is in).
  void _onContentChanged(ContentChanged event) {
    if (event.kind != ContentKind.story) return;
    if (event.mustReload ||
        event.upsertedIds.isNotEmpty ||
        event.removedIds.isNotEmpty) {
      load();
    }
  }

  /// A change that comes in while loading runs one more load after it. A load that fails leaves the rail
  /// as it is.
  Future<void> load() async {
    if (_isLoading) {
      _reloadAgain = true;
      return;
    }
    _isLoading = true;
    do {
      _reloadAgain = false;
      await run(
        _rail.call,
        onSuccess: (items) {
          _loaded = items;
          return state.copyWith(items: _visible(), isLoaded: true);
        },
        onFailure: (_) => null,
      );
    } while (_reloadAgain && !isClosed);
    _isLoading = false;
  }

  /// The viewer saw the last story of a person: their ring turns grey now, without a read.
  void _onAuthorSeen(StoryAuthorSeen event) {
    _loaded = [
      for (final item in _loaded)
        item.authorId == event.authorId ? item.copyWith(allSeen: true) : item,
    ];
    emit(state.copyWith(items: _visible()));
    _rail.save(_loaded);
  }

  void _onDelete(ContentDeleteEvent event) {
    if (event.kind != ContentKind.story) return;
    if (event.stage == ContentDeleteStage.pending) {
      _pendingDeletes.add(event.id);
      emit(state.copyWith(items: _visible()));
      return;
    }
    _pendingDeletes.remove(event.id);
    if (event.stage == ContentDeleteStage.restored) {
      emit(state.copyWith(items: _visible()));
    }
    load();
  }

  /// [_loaded] without the stories being deleted: your row loses them and goes when none is left (Home
  /// then shows the "+" tile, as the server's rail has no row for a person without stories).
  List<StoryRailItemEntity> _visible() {
    if (_pendingDeletes.isEmpty) return _loaded;
    return _loaded.map(_withoutPendingDeletes).nonNulls.toList();
  }

  /// Null when none of your stories is left.
  StoryRailItemEntity? _withoutPendingDeletes(StoryRailItemEntity item) {
    if (!item.isMe) return item;
    final left = item.storyCount - _pendingDeletes.length;
    return left > 0 ? item.copyWith(storyCount: left) : null;
  }

  void retryUpload() => _retryUpload(ContentKind.story);

  void _onUpload(ContentPublishStatus status) {
    if (status.kind != ContentKind.story) return;
    emit(state.copyWith(upload: status));
    if (status is ContentPublishDone) load();
  }
}
