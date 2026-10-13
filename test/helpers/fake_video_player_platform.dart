import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// A video player that opens any file as a 720 x 1280 clip and never plays: for widget tests of screens
/// that show a video. Install with `VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();`.
class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final _events = <int, StreamController<VideoEvent>>{};
  int _next = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async => _next++;

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _next++;
    _events[id] = StreamController<VideoEvent>()
      ..add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 9),
          size: const Size(720, 1280),
        ),
      );
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) =>
      (_events[playerId] ??= StreamController<VideoEvent>()).stream;

  @override
  Future<void> dispose(int playerId) async {
    await _events.remove(playerId)?.close();
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Widget buildView(int playerId) => const SizedBox();
}
