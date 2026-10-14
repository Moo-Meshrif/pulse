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
  AppVideoController(this.dataSource, {this.volume, this.isLooping = false})
    : player = VideoPlayerController.networkUrl(Uri.parse(dataSource));

  @override
  final String dataSource;
  final VideoPlayerController player;

  /// The volume to start with (0 to 1), read when the video is ready; the player's own when null.
  final double Function()? volume;
  final bool isLooping;

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

  /// Sets volume and looping, then decodes the first frame so the video paints at once.
  @override
  Future<void> warmUp() async {
    final startVolume = volume;
    if (startVolume != null) await player.setVolume(startVolume());
    if (isLooping) await player.setLooping(true);
    await player.seekTo(Duration.zero);
    await player.pause();
  }
}
