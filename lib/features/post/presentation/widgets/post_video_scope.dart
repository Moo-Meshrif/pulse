import 'package:flutter/material.dart';
import 'package:video_flux/video_flux.dart';

import '../../../../core/utils/app_video_controller.dart';
import '../utils/post_video_coordinator.dart';

/// What a video card reads from its [PostVideoScope].
class PostVideos {
  const PostVideos({required this.coordinator, required this.flux});

  final PostVideoCoordinator coordinator;
  final VideoFlux<AppVideoItem> flux;
}

/// Wrap a list of posts in this so only one video plays at a time. [videos] are the feed's videos in order
/// (`postVideos`); one `video_flux` window keeps the playing one and its neighbours ready and frees the rest.
/// A card outside one keeps its video still, with its poster.
class PostVideoScope extends StatefulWidget {
  const PostVideoScope({
    super.key,
    this.videos = const [],
    required this.child,
  });

  final List<AppVideoItem> videos;
  final Widget child;

  /// The nearest scope's coordinator and player window, or null. It never rebuilds the caller: the caller
  /// listens to what it needs.
  static PostVideos? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PostVideoInherited>()?.videos;

  @override
  State<PostVideoScope> createState() => _PostVideoScopeState();
}

class _PostVideoScopeState extends State<PostVideoScope> {
  static const _config = VideoFluxConfig(
    preloadBackward: 1,
    preloadForward: 2,
    windowSize: 4,
    scrollDebounce: Duration(milliseconds: 150),
  );

  final _coordinator = PostVideoCoordinator();
  late final VideoFlux<AppVideoItem> _flux;
  late final PostVideos _videos;
  String? _selectedId;
  bool _wasMuted = true;

  @override
  void initState() {
    super.initState();
    _flux = VideoFlux<AppVideoItem>(
      items: widget.videos,
      controllerFactory: (url) => AppVideoController(
        url,
        isLooping: true,
        volume: () => _coordinator.isMuted ? 0 : 1,
      ),
      config: _config,
    );
    _videos = PostVideos(coordinator: _coordinator, flux: _flux);
    _coordinator.addListener(_onCoordinator);
  }

  @override
  void didUpdateWidget(PostVideoScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSame(oldWidget.videos, widget.videos)) {
      _flux.replaceItems(widget.videos).then((_) => _select());
    }
  }

  @override
  void dispose() {
    _coordinator
      ..removeListener(_onCoordinator)
      ..dispose();
    _flux.disposeAll();
    super.dispose();
  }

  bool _isSame(List<AppVideoItem> a, List<AppVideoItem> b) =>
      a.length == b.length &&
      Iterable<int>.generate(a.length)
          .every((i) => a[i].id == b[i].id && a[i].url == b[i].url);

  void _onCoordinator() {
    if (_wasMuted != _coordinator.isMuted) {
      _wasMuted = _coordinator.isMuted;
      for (final controller in _flux.getActiveControllers()) {
        if (controller is AppVideoController) {
          controller.player.setVolume(_wasMuted ? 0 : 1);
        }
      }
    }
    _select();
  }

  /// Hands the picked video to the window (it plays it and pauses the others), or pauses all.
  void _select() {
    final id = _coordinator.activeId;
    if (id == _selectedId) return;
    if (id == null) {
      _selectedId = null;
      _flux.pauseAll();
    } else if (_flux.getItemById(id) != null) {
      _selectedId = id;
      _flux.scrollToId(id);
    }
  }

  @override
  Widget build(BuildContext context) =>
      _PostVideoInherited(videos: _videos, child: widget.child);
}

class _PostVideoInherited extends InheritedWidget {
  const _PostVideoInherited({required this.videos, required super.child});

  final PostVideos videos;

  @override
  bool updateShouldNotify(_PostVideoInherited oldWidget) => false;
}
