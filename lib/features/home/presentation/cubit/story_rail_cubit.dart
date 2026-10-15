import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/events/event_bus.dart';
import '../../../../core/events/event_cubit_mixin.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/domain/event/content_delete_event.dart';
import '../../../post/domain/event/feed_refresh_requested.dart';
import '../../../story/domain/entity/story_rail_item_entity.dart';
import '../../../story/domain/entity/story_upload_status.dart';
import '../../../story/domain/event/story_rail_changed.dart';
import '../../../story/domain/use_case/get_story_rail_use_case.dart';
import '../../../story/domain/use_case/retry_story_upload_use_case.dart';
import 'story_rail_state.dart';

/// The Stories rail of Home: the people with a story, and how posting your own is going.
@injectable
class StoryRailCubit extends BaseCubit<StoryRailState>
    with EventCubitMixin<StoryRailState> {
  StoryRailCubit(this._rail, this._events, this._retryUpload)
    : super(
        StoryRailState(
          upload:
              _events.latest<StoryUploadStatus>() ?? const StoryUploadIdle(),
        ),
      );

  final GetStoryRailUseCase _rail;
  final EventBus _events;
  final RetryStoryUploadUseCase _retryUpload;

  @override
  EventBus get events => _events;

  /// The rail as the server sent it; the state shows it without the stories being deleted.
  List<StoryRailItemEntity> _loaded = const [];

  /// Your stories hidden while their delete can still be undone.
  final _pendingDeletes = <String>{};
  bool _isLoading = false;
  bool _reloadAgain = false;

  /// Loads the rail and keeps it current: a mute or delete reloads it, and so does a story that finished
  /// posting or a refresh of Home.
  Future<void> start() {
    listenTo<StoryRailChanged>((_) => load());
    listenTo<ContentDeleteEvent>(_onDelete);
    listenTo<FeedRefreshRequested>((_) => load());
    listenTo<StoryUploadStatus>(_onUpload);
    return load();
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
          return state.copyWith(items: _visible());
        },
        onFailure: (_) => null,
      );
    } while (_reloadAgain && !isClosed);
    _isLoading = false;
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
    return [
      for (final item in _loaded)
        if (!item.isMe)
          item
        else if (item.storyCount > _pendingDeletes.length)
          item.copyWith(storyCount: item.storyCount - _pendingDeletes.length),
    ];
  }

  void retryUpload() => _retryUpload();

  void _onUpload(StoryUploadStatus status) {
    emit(state.copyWith(upload: status));
    if (status is StoryUploadDone) load();
  }
}
