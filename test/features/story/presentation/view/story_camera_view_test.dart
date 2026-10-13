import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/camera_device.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/story/data/datasource/story_camera_hint_datasource.dart';
import 'package:pulse/features/story/presentation/cubit/story_camera_cubit.dart';
import 'package:pulse/features/story/presentation/view/story_camera_view.dart';
import 'package:pulse/features/story/presentation/widgets/story_camera/story_shutter.dart';

import '../../../../helpers/pump_app.dart';

class _Device extends Mock implements CameraDevice {}

class _Picker extends Mock implements MediaPickerService {}

class _Hint extends Mock implements StoryCameraHintDatasource {}

void main() {
  late _Device device;
  late _Picker picker;
  late _Hint hint;
  late StoryCameraCubit cubit;

  setUpAll(() => registerFallbackValue(CameraLens.back));

  setUp(() {
    device = _Device();
    picker = _Picker();
    hint = _Hint();
    when(() => hint.isSeen).thenReturn(false);
    when(() => hint.markSeen()).thenAnswer((_) async {});
    when(
      () => device.open(
        lens: any(named: 'lens'),
        withAudio: any(named: 'withAudio'),
      ),
    ).thenAnswer((_) async {});
    when(() => device.close()).thenAnswer((_) async {});
    when(() => device.hasFlash).thenReturn(true);
    when(() => device.preview())
        .thenReturn(const ColoredBox(color: Colors.grey));
    when(() => device.startRecording()).thenAnswer((_) async {});
    when(() => device.stopRecording(keep: any(named: 'keep')))
        .thenAnswer((_) async => const CapturedFile(path: '/v.mp4'));
    when(() => device.takePhoto())
        .thenAnswer((_) async => const CapturedFile(path: '/p.jpg'));
    cubit = StoryCameraCubit(device, picker, hint);
  });

  tearDown(() => cubit.close());

  Future<void> open(
    WidgetTester tester, {
    bool micOff = false,
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      Material(
        child: BlocProvider.value(
          value: cubit,
          child: StoryCameraView(isMicOff: micOff, onFixMic: () {}),
        ),
      ),
      locale: locale,
      settle: false,
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('ready: title, X, flash, hint, gallery, shutter, flip', (
    tester,
  ) async {
    await open(tester);
    expect(find.text(l10nEn.storyCameraTitle), findsOneWidget);
    expect(find.text(l10nEn.storyHint), findsOneWidget);
    for (final label in [
      l10nEn.close,
      l10nEn.storyFlash,
      l10nEn.storyGallery,
      l10nEn.storyShutter,
      l10nEn.storyFlipCamera,
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    expect(find.byType(MicOffPill), findsNothing);
    verify(() => device.open(lens: CameraLens.back, withAudio: true));
  });

  testWidgets('the shutter is 80 and the targets are at least 44', (
    tester,
  ) async {
    await open(tester);
    final shutter = tester.getSize(find.byType(StoryShutter));
    expect(shutter.width, greaterThanOrEqualTo(80));
    for (final label in [
      l10nEn.close,
      l10nEn.storyFlash,
      l10nEn.storyGallery,
      l10nEn.storyFlipCamera,
    ]) {
      final size = tester.getSize(find.bySemanticsLabel(label));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    }
  });

  testWidgets('a tap takes a photo', (tester) async {
    await open(tester);
    await tester.tap(find.byType(StoryShutter));
    await tester.pump();
    verify(() => device.takePhoto()).called(1);
    expect(cubit.state.captured!.path, '/p.jpg');
  });

  testWidgets('holding records: red timer chip replaces the title', (
    tester,
  ) async {
    await open(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(StoryShutter)),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await tester.pump(const Duration(seconds: 2));
    expect(cubit.state.isRecording, isTrue);
    expect(find.text(l10nEn.storyCameraTitle), findsNothing);
    expect(find.text('0:02'), findsOneWidget);
    expect(find.text(l10nEn.storyHint), findsNothing);

    await gesture.up();
    await tester.pump();
    expect(cubit.state.isRecording, isFalse);
    expect(cubit.state.captured!.path, '/v.mp4');
  });

  testWidgets('flash toggles', (tester) async {
    when(() => device.setFlash(on: any(named: 'on'))).thenAnswer((_) async {});
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.storyFlash));
    await tester.pump();
    expect(find.bySemanticsLabel(l10nEn.storyFlashOn), findsOneWidget);
  });

  testWidgets('only the microphone off: pill shown, camera opens silent', (
    tester,
  ) async {
    await open(tester, micOff: true);
    expect(find.text(l10nEn.permMicOffPill), findsOneWidget);
    verify(() => device.open(lens: CameraLens.back, withAudio: false));
  });

  testWidgets('a camera that cannot open shows panel 4', (tester) async {
    when(
      () => device.open(
        lens: any(named: 'lens'),
        withAudio: any(named: 'withAudio'),
      ),
    ).thenThrow(const CameraFailure());
    await open(tester);
    expect(find.text(l10nEn.permUnavailableTitle), findsOneWidget);
    expect(find.text(l10nEn.permTryAgain), findsOneWidget);
    expect(find.text(l10nEn.permChooseGallery), findsOneWidget);
  });

  testWidgets('Arabic: title is Arabic, X sits at the right', (tester) async {
    await open(tester, locale: const Locale('ar'));
    expect(find.text(l10nAr.storyCameraTitle), findsOneWidget);
    expect(
      tester.getCenter(find.bySemanticsLabel(l10nAr.close)).dx,
      greaterThan(195),
    );
    expect(
      tester.getCenter(find.bySemanticsLabel(l10nAr.storyFlash)).dx,
      lessThan(195),
    );
  });

  testWidgets('1.5x text: no overflow', (tester) async {
    await open(tester, micOff: true, textScale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the front camera has no flash button, and the title stays '
      'centred', (tester) async {
    await open(tester);
    final centred = tester.getCenter(find.text(l10nEn.storyCameraTitle)).dx;
    expect(find.bySemanticsLabel(l10nEn.storyFlash), findsOneWidget);

    when(() => device.hasFlash).thenReturn(false);
    await tester.tap(find.bySemanticsLabel(l10nEn.storyFlipCamera));
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel(l10nEn.storyFlash), findsNothing);
    expect(find.bySemanticsLabel(l10nEn.storyFlashOn), findsNothing);
    expect(tester.getCenter(find.text(l10nEn.storyCameraTitle)).dx, centred);
    verify(() => device.open(lens: CameraLens.front, withAudio: true));
  });
}
