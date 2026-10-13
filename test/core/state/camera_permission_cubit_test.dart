import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/permission_access.dart';
import 'package:pulse/core/services/camera_permission_service.dart';
import 'package:pulse/core/state/camera_permission_cubit.dart';
import 'package:pulse/core/state/camera_permission_state.dart';

class _Permissions extends Mock implements CameraPermissionService {}

void main() {
  late _Permissions permissions;
  late CameraPermissionCubit cubit;

  void stub(PermissionAccess camera, PermissionAccess microphone) {
    when(() => permissions.camera()).thenAnswer((_) async => camera);
    when(() => permissions.microphone()).thenAnswer((_) async => microphone);
    when(() => permissions.requestMicrophone()).thenAnswer((_) async {});
  }

  setUp(() {
    permissions = _Permissions();
    cubit = CameraPermissionCubit(permissions);
  });

  tearDown(() => cubit.close());

  const table = {
    (PermissionAccess.granted, PermissionAccess.granted): (
      CameraPermissionStep.ready,
      false,
    ),
    (PermissionAccess.granted, PermissionAccess.denied): (
      CameraPermissionStep.ready,
      true,
    ),
    (PermissionAccess.granted, PermissionAccess.blocked): (
      CameraPermissionStep.ready,
      true,
    ),
    (PermissionAccess.denied, PermissionAccess.denied): (
      CameraPermissionStep.ask,
      true,
    ),
    (PermissionAccess.denied, PermissionAccess.granted): (
      CameraPermissionStep.ask,
      false,
    ),
    (PermissionAccess.blocked, PermissionAccess.granted): (
      CameraPermissionStep.blocked,
      false,
    ),
    (PermissionAccess.restricted, PermissionAccess.denied): (
      CameraPermissionStep.blocked,
      true,
    ),
  };

  table.forEach((key, expected) {
    test('camera ${key.$1.name} + microphone ${key.$2.name} -> '
        '${expected.$1.name}', () async {
      stub(key.$1, key.$2);
      await cubit.check();
      expect(cubit.state.step, expected.$1);
      expect(cubit.state.isMicOff, expected.$2);
    });
  });

  test('restricted is told apart from blocked', () async {
    stub(PermissionAccess.restricted, PermissionAccess.denied);
    await cubit.check();
    expect(cubit.state.isRestricted, isTrue);
  });

  test('allow asks the system, then decides again', () async {
    when(() => permissions.request()).thenAnswer((_) async {});
    stub(PermissionAccess.granted, PermissionAccess.granted);
    await cubit.allow();
    verify(() => permissions.request()).called(1);
    expect(cubit.state.step, CameraPermissionStep.ready);
  });

  test('openSettings goes to the service', () async {
    when(() => permissions.openSettings()).thenAnswer((_) async => true);
    await cubit.openSettings();
    verify(() => permissions.openSettings()).called(1);
  });

  group('microphone', () {
    test(
      'camera allowed, microphone never asked: the system asks once',
      () async {
        var mic = PermissionAccess.denied;
        when(() => permissions.camera())
            .thenAnswer((_) async => PermissionAccess.granted);
        when(() => permissions.microphone()).thenAnswer((_) async => mic);
        when(() => permissions.requestMicrophone()).thenAnswer((_) async {
          mic = PermissionAccess.granted;
        });
        await cubit.check();
        verify(() => permissions.requestMicrophone()).called(1);
        expect(cubit.state.isMicOff, isFalse);
      },
    );

    test('a refusal is not asked again on the next check', () async {
      when(() => permissions.camera())
          .thenAnswer((_) async => PermissionAccess.granted);
      when(() => permissions.microphone())
          .thenAnswer((_) async => PermissionAccess.denied);
      when(() => permissions.requestMicrophone()).thenAnswer((_) async {});
      await cubit.check();
      await cubit.check();
      verify(() => permissions.requestMicrophone()).called(1);
      expect(cubit.state.isMicOff, isTrue);
    });

    test(
      'a microphone refused for good is never asked, only fixed in Settings',
      () async {
        stub(PermissionAccess.granted, PermissionAccess.blocked);
        when(() => permissions.openSettings()).thenAnswer((_) async => true);
        await cubit.check();
        verifyNever(() => permissions.requestMicrophone());
        await cubit.fixMicrophone();
        verify(() => permissions.openSettings()).called(1);
      },
    );

    test('Fix asks again while the system still can, Settings after', () async {
      when(() => permissions.camera())
          .thenAnswer((_) async => PermissionAccess.granted);
      var mic = PermissionAccess.denied;
      when(() => permissions.microphone()).thenAnswer((_) async => mic);
      var asks = 0;
      when(() => permissions.requestMicrophone()).thenAnswer((_) async {
        asks++;
        if (asks == 2) mic = PermissionAccess.blocked; // refused in the prompt
      });
      when(() => permissions.openSettings()).thenAnswer((_) async => true);
      await cubit
          .check(); // asks once on its own: refused softly (still denied)
      await cubit.fixMicrophone(); // asks again: now refused for good
      expect(cubit.state.microphone, PermissionAccess.blocked);
      await cubit.fixMicrophone(); // nothing left to ask: Settings
      verify(() => permissions.openSettings()).called(1);
    });
  });
}
