import 'package:injectable/injectable.dart';

import '../enums/permission_access.dart';
import '../services/camera_permission_service.dart';
import 'base_cubit.dart';
import 'camera_permission_state.dart';

/// Decides what the camera gate shows from the camera and microphone permissions. It only reads and asks;
/// the gate re-checks when the app comes back from Settings.
@injectable
class CameraPermissionCubit extends BaseCubit<CameraPermissionState> {
  CameraPermissionCubit(this._permissions)
    : super(const CameraPermissionState());

  final CameraPermissionService _permissions;

  bool _askedMicrophone = false;

  Future<void> check() async {
    final camera = await _permissions.camera();
    var microphone = await _permissions.microphone();
    // The camera is allowed but the microphone never was asked: ask now. Sending the person to Settings
    // would show no microphone switch, because iOS lists it only after the first request.
    if (camera == PermissionAccess.granted &&
        microphone == PermissionAccess.denied &&
        !_askedMicrophone) {
      _askedMicrophone = true;
      await _permissions.requestMicrophone();
      microphone = await _permissions.microphone();
    }
    emit(
      CameraPermissionState(
        step: switch (camera) {
          PermissionAccess.granted => CameraPermissionStep.ready,
          PermissionAccess.denied => CameraPermissionStep.ask,
          PermissionAccess.blocked ||
          PermissionAccess.restricted => CameraPermissionStep.blocked,
        },
        camera: camera,
        microphone: microphone,
      ),
    );
  }

  /// "Allow access": the system asks camera then microphone, then the screen is decided again.
  Future<void> allow() async {
    await _permissions.request();
    await check();
  }

  Future<void> openSettings() => _permissions.openSettings();

  /// "Fix" on the microphone pill: the system prompt while it can still be shown, else Settings.
  Future<void> fixMicrophone() async {
    if (state.microphone == PermissionAccess.denied) {
      await _permissions.requestMicrophone();
      await check();
      return;
    }
    await _permissions.openSettings();
  }
}
