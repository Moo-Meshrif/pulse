import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/utils/post_video_coordinator.dart';

void main() {
  late PostVideoCoordinator coordinator;
  var notified = 0;

  setUp(() {
    notified = 0;
    coordinator = PostVideoCoordinator()..addListener(() => notified++);
  });

  tearDown(() => coordinator.dispose());

  test('nothing plays until a video is 60% visible', () {
    coordinator.report('a', 0.5);
    expect(coordinator.activeId, isNull);
    coordinator.report('a', 0.6);
    expect(coordinator.activeId, 'a');
  });

  test('the most visible one plays when several qualify', () {
    coordinator.report('a', 0.7);
    coordinator.report('b', 0.9);
    expect(coordinator.activeId, 'a'); // already playing and still visible
    coordinator.report('a', 0.4);
    expect(coordinator.activeId, 'b');
  });

  test('the playing one keeps playing while it stays visible enough', () {
    coordinator.report('a', 0.65);
    coordinator.report('b', 1);
    expect(coordinator.activeId, 'a');
  });

  test('a video that leaves the screen stops and the next takes over', () {
    coordinator.report('a', 1);
    coordinator.report('b', 0.8);
    coordinator.report('a', 0);
    expect(coordinator.activeId, 'b');
    coordinator.report('b', 0);
    expect(coordinator.activeId, isNull);
  });

  test('listeners hear a change of the playing video, not a repeat', () {
    coordinator.report('a', 0.8);
    coordinator.report('a', 0.9);
    expect(notified, 1);
  });

  test('videos start muted and the button switches it for the list', () {
    expect(coordinator.isMuted, isTrue);
    coordinator.toggleMute();
    expect(coordinator.isMuted, isFalse);
    expect(notified, 1);
  });
}
