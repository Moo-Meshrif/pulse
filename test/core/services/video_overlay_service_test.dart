import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/video_overlay_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('pulse/video_overlay');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late ChannelVideoOverlayService service;
  late List<MethodCall> calls;

  setUp(() {
    service = ChannelVideoOverlayService();
    calls = [];
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  void answer(Future<Object?> Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, (call) {
      calls.add(call);
      return handler(call);
    });
  }

  test('burn returns the path the native side wrote', () async {
    answer((_) async => '/out.mp4');
    final path = await service.burn('/in.mp4', Uint8List.fromList([1, 2]));
    expect(path, '/out.mp4');
    expect(calls.single.method, 'burn');
    expect((calls.single.arguments as Map)['videoPath'], '/in.mp4');
  });

  test('a native error is an UnexpectedFailure', () async {
    answer((_) async => throw PlatformException(code: 'export_failed'));
    expect(
      service.burn('/in.mp4', Uint8List(1)),
      throwsA(isA<UnexpectedFailure>()),
    );
  });

  test('jobs run one at a time, in order', () async {
    final first = Completer<String>();
    answer((call) {
      final path = (call.arguments as Map)['videoPath'] as String;
      return path == '/a.mp4' ? first.future : Future.value('/b-out.mp4');
    });
    final a = service.burn('/a.mp4', Uint8List(1));
    final b = service.burn('/b.mp4', Uint8List(1));
    await Future<void>.delayed(Duration.zero);
    expect(calls, hasLength(1));
    first.complete('/a-out.mp4');
    expect(await a, '/a-out.mp4');
    expect(await b, '/b-out.mp4');
    expect(calls, hasLength(2));
  });

  test('delete never throws', () async {
    answer((_) async => throw PlatformException(code: 'x'));
    await service.delete('/out.mp4');
  });
}
