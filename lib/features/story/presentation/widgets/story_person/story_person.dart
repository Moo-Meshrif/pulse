import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_flux/video_flux.dart';

import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/utils/app_video_controller.dart';
import '../../../data/enums/story_media_type.dart';
import '../../../data/model/story_model.dart';
import '../../../domain/entity/story_rail_item_entity.dart';
import '../../cubit/story_viewer_cubit.dart';
import '../../cubit/story_viewer_state.dart';
import '../../utils/enums/story_pause_reason.dart';
import '../../utils/story_picture.dart';
import '../../utils/story_start_index.dart';
import '../story_media/story_media.dart';
import '../story_overlays_layer.dart';
import '../story_shades.dart';
import 'story_chrome.dart';
import 'story_waiting.dart';

/// One page of the viewer: one person's stories. Only the page on screen plays; the next one keeps its
/// first story ready.
class StoryPerson extends StatefulWidget {
  const StoryPerson({super.key, required this.index, required this.person});

  final int index;
  final StoryRailItemEntity person;

  @override
  State<StoryPerson> createState() => _StoryPersonState();
}

class _StoryPersonState extends State<StoryPerson> {
  final _progress = ValueNotifier<double>(0);
  VideoFlux<AppVideoItem>? _flux;
  List<StoryModel> _videos = const [];
  final _failedVideos = <String>{};
  String? _selectedVideoId;
  final _preloaded = <String>{};

  @override
  void dispose() {
    _flux?.disposeAll();
    _progress.dispose();
    super.dispose();
  }

  /// Gives the person's videos to the preloader once their stories are known: it keeps the playing video
  /// and the next one ready.
  void _ensureFlux(List<StoryModel> stories) {
    if (_flux != null) return;
    _videos = [
      for (final s in stories)
        if (s.type == StoryMediaType.video &&
            s.id != null &&
            s.mediaUrl != null)
          s,
    ];
    if (_videos.isEmpty) return;
    _flux = VideoFlux<AppVideoItem>(
      items: [
        for (final v in _videos) AppVideoItem(id: v.id!, url: v.mediaUrl!),
      ],
      controllerFactory: AppVideoController.new,
      config: const VideoFluxConfig(
        preloadBackward: 0,
        preloadForward: 1,
        windowSize: 2,
        scrollDebounce: Duration.zero,
        handleAppLifecycle: false,
      ),
      onControllerInitialized: (_) {
        if (mounted) setState(() {});
      },
      onControllerInitializationError: (controller, _, _) {
        final id = _videos
            .where((v) => v.mediaUrl == controller.dataSource)
            .firstOrNull
            ?.id;
        if (id != null && mounted) setState(() => _failedVideos.add(id));
      },
    );
  }

  /// Tells the preloader which video is playing (after the frame: it may start work).
  void _select(StoryModel story, bool isActive) {
    final id = story.id;
    if (!isActive || id == null || story.type != StoryMediaType.video) return;
    if (_selectedVideoId == id) return;
    _selectedVideoId = id;
    final index = _videos.indexWhere((v) => v.id == id);
    if (index < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _flux?.scroll(index);
    });
  }

  /// While a story plays, loads the picture of the next one of this person, so it shows at once. The next
  /// person's first story is loaded by their page, which the viewer builds beside this one.
  void _preloadNext(List<StoryModel> stories, int index) {
    if (index + 1 >= stories.length) return;
    final next = stories[index + 1];
    final id = next.id;
    if (id == null || !_preloaded.add(id)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) preloadStoryPicture(context, next);
    });
  }

  AppVideoController? _controllerFor(StoryModel story) {
    final index = _videos.indexWhere((v) => v.id == story.id);
    if (index < 0) return null;
    final controller = _flux?.getControllerAtIndex(index);
    return controller is AppVideoController ? controller : null;
  }

  /// Starts the preloader over with fresh controllers (a video that failed to open).
  void _retryVideo(StoryModel story) {
    _flux?.disposeAll();
    setState(() {
      _flux = null;
      _selectedVideoId = null;
      _failedVideos.remove(story.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoryViewerCubit>();
    return BlocBuilder<StoryViewerCubit, StoryViewerState>(
      builder: (context, state) {
        final id = widget.person.authorId;
        final stories = state.stories[id];
        if (stories == null) {
          return StoryWaiting(
            person: widget.person,
            hasFailed: state.failedAuthors.contains(id),
            onRetry: () => cubit.retryPerson(id),
            onClose: () => AppNavigator.back(context),
          );
        }
        if (stories.isEmpty) return const SizedBox.expand();
        _ensureFlux(stories);

        final isActive = state.personIndex == widget.index;
        final storyIndex = isActive
            ? state.storyIndex
            : storyStartIndex(stories);
        final story = stories[storyIndex];
        _select(story, isActive);
        if (isActive) _preloadNext(stories, storyIndex);

        return Stack(
          fit: StackFit.expand,
          children: [
            KeyedSubtree(
              key: ValueKey(story.id),
              child: StoryMedia(
                story: story,
                isRunning: isActive && !state.isPaused,
                progress: _progress,
                restarts: state.restarts,
                onCompleted: () {
                  if (isActive) cubit.next();
                },
                video: _controllerFor(story),
                hasVideoFailed: _failedVideos.contains(story.id),
                onRetryVideo: () => _retryVideo(story),
              ),
            ),
            const StoryShades(),
            StoryOverlaysLayer(overlays: story.overlays ?? const []),
            StoryChrome(
              isVisible: !(isActive && state.isHolding),
              person: widget.person,
              story: story,
              count: stories.length,
              index: storyIndex,
              progress: _progress,
              isActive: isActive,
              isOverlayOpen:
                  isActive && state.pauses.contains(StoryPauseReason.overlay),
            ),
          ],
        );
      },
    );
  }
}
