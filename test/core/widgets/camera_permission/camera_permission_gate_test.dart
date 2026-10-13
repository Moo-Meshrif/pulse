import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/permission_access.dart';
import 'package:pulse/core/services/camera_permission_service.dart';
import 'package:pulse/core/state/camera_permission_cubit.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

class _Permissions extends Mock implements CameraPermissionService {}

void main() {
  late _Permissions permissions;
  late int gallery;
  late int closed;
  var camera = PermissionAccess.denied;
  var microphone = PermissionAccess.denied;

  setUp(() async {
    permissions = _Permissions();
    gallery = 0;
    closed = 0;
    camera = PermissionAccess.denied;
    microphone = PermissionAccess.denied;
    when(() => permissions.camera()).thenAnswer((_) async => camera);
    when(() => permissions.microphone()).thenAnswer((_) async => microphone);
    when(() => permissions.openSettings()).thenAnswer((_) async => true);
    when(() => permissions.requestMicrophone()).thenAnswer((_) async {});
    when(() => permissions.request()).thenAnswer((_) async {
      camera = PermissionAccess.granted;
      microphone = PermissionAccess.granted;
    });
    await getIt.reset();
    getIt.registerFactory<CameraPermissionCubit>(
      () => CameraPermissionCubit(permissions),
    );
  });

  tearDown(getIt.reset);

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      CameraPermissionGate(
        onGallery: () => gallery++,
        onClose: () => closed++,
        cameraBuilder: (context, isMicOff, onFix) => Material(
          child: Column(
            children: [
              const Text('camera'),
              if (isMicOff) MicOffPill(onFix: onFix),
            ],
          ),
        ),
      ),
      locale: locale,
      settle: false,
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('panel 1: pair of icons, card with Needed, Allow and Not now', (
    tester,
  ) async {
    await open(tester);
    expect(find.text(l10nEn.permAllowTitle), findsOneWidget);
    expect(find.text(l10nEn.permAllowBody), findsOneWidget);
    expect(find.text(l10nEn.permNeeded), findsNWidgets(2));
    expect(find.text(l10nEn.permNotNow), findsOneWidget);
    expect(find.text('camera'), findsNothing);

    await tester.tap(find.text(l10nEn.permNotNow));
    expect(closed, 1);
  });

  testWidgets('Allow access asks, then opens the camera', (tester) async {
    await open(tester);
    await tester.tap(find.text(l10nEn.permAllowAccess));
    await tester.pump();
    await tester.pump();
    verify(() => permissions.request()).called(1);
    expect(find.text('camera'), findsOneWidget);
    expect(find.byType(MicOffPill), findsNothing);
  });

  testWidgets(
    'panel 2: camera off for good, Off in the card, settings + gallery',
    (tester) async {
      camera = PermissionAccess.blocked;
      microphone = PermissionAccess.granted;
      await open(tester);
      expect(find.text(l10nEn.permCameraOffTitle), findsOneWidget);
      expect(find.text(l10nEn.permOff), findsOneWidget);

      await tester.tap(find.text(l10nEn.permOpenSettings));
      verify(() => permissions.openSettings()).called(1);
      await tester.tap(find.text(l10nEn.permChooseGallery));
      expect(gallery, 1);
    },
  );

  testWidgets('restricted: no Open settings', (tester) async {
    camera = PermissionAccess.restricted;
    await open(tester);
    expect(find.text(l10nEn.permCameraRestrictedBody), findsOneWidget);
    expect(find.text(l10nEn.permOpenSettings), findsNothing);
    expect(find.text(l10nEn.permChooseGallery), findsOneWidget);
  });

  testWidgets(
    'panel 3: only the microphone off shows the camera with the pill',
    (tester) async {
      camera = PermissionAccess.granted;
      microphone = PermissionAccess.blocked;
      await open(tester);
      expect(find.text('camera'), findsOneWidget);
      expect(find.text(l10nEn.permMicOffPill), findsOneWidget);

      await tester.tap(find.text(l10nEn.permFix));
      verify(() => permissions.openSettings()).called(1);
      verifyNever(() => permissions.requestMicrophone());
    },
  );

  testWidgets('a microphone never asked is asked on opening, not sent to '
      'Settings', (tester) async {
    camera = PermissionAccess.granted;
    when(() => permissions.requestMicrophone()).thenAnswer((_) async {
      microphone = PermissionAccess.granted;
    });
    await open(tester);
    verify(() => permissions.requestMicrophone()).called(1);
    expect(find.text('camera'), findsOneWidget);
    expect(find.byType(MicOffPill), findsNothing);
  });

  testWidgets('coming back from Settings re-checks and continues', (
    tester,
  ) async {
    camera = PermissionAccess.blocked;
    await open(tester);
    expect(find.text(l10nEn.permCameraOffTitle), findsOneWidget);

    camera = PermissionAccess.granted;
    microphone = PermissionAccess.granted;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(find.text('camera'), findsOneWidget);
  });

  testWidgets('panel 4: Try again and Choose from gallery', (tester) async {
    setUpView(tester);
    var again = 0;
    await tester.pumpApp(
      CameraUnavailableView(
        onTryAgain: () => again++,
        onGallery: () => gallery++,
        onClose: () => closed++,
      ),
    );
    expect(find.text(l10nEn.permUnavailableTitle), findsOneWidget);
    expect(find.text(l10nEn.permUnavailableBody), findsOneWidget);
    await tester.tap(find.text(l10nEn.permTryAgain));
    await tester.tap(find.text(l10nEn.permChooseGallery));
    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    expect([again, gallery, closed], [1, 1, 1]);
  });

  testWidgets('Arabic: panel 1 is Arabic and the X sits at the right', (
    tester,
  ) async {
    await open(tester, locale: const Locale('ar'));
    expect(find.text(l10nAr.permAllowTitle), findsOneWidget);
    final x = tester.getCenter(find.bySemanticsLabel(l10nAr.close));
    expect(x.dx, greaterThan(195));
  });

  testWidgets('1.5x text: no overflow on panels 1 and 2', (tester) async {
    await open(tester, textScale: 1.5);
    expect(tester.takeException(), isNull);
    camera = PermissionAccess.blocked;
    await tester.pumpWidget(const SizedBox());
    await open(tester, textScale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the close button and the actions are at least 44 high', (
    tester,
  ) async {
    await open(tester);
    for (final finder in [
      find.bySemanticsLabel(l10nEn.close),
      find.ancestor(
        of: find.text(l10nEn.permAllowAccess),
        matching: find.byType(FilledButton),
      ),
      find.ancestor(
        of: find.text(l10nEn.permNotNow),
        matching: find.byType(InkWell),
      ),
    ]) {
      final size = tester.getSize(finder);
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width, greaterThanOrEqualTo(44));
    }
  });
}
