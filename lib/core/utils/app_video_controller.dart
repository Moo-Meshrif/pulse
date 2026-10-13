import 'package:video_flux/video_flux.dart';
import 'package:video_player/video_player.dart';

/// A video for `VideoFlux`: its id and its signed link.
class AppVideoItem implements VideoFluxItem {
  const AppVideoItem({required this.id, required this.url});

  @override
  final String id;

  @override
  final String url;
}

/// `video_flux` over `video_player`: [player] is what the viewer draws and listens to.
class AppVideoController extends CustomVideoController {
  AppVideoController(this.dataSource)
    : player = VideoPlayerController.networkUrl(Uri.parse(dataSource));

  @override
  final String dataSource;
  final VideoPlayerController player;

  @override
  bool get isInitialized => player.value.isInitialized;

  @override
  bool get isPlaying => player.value.isPlaying;

  @override
  Future<void> initialize() => player.initialize();

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> dispose() => player.dispose();

  /// Decodes the first frame so the video paints at once.
  @override
  Future<void> warmUp() async {
    await player.seekTo(Duration.zero);
    await player.pause();
  }
}
