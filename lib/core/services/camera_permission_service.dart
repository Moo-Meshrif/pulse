import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../enums/permission_access.dart';

/// Camera and microphone permissions, for every camera flow (story, short, profile photo). Tests mock it.
abstract interface class CameraPermissionService {
  Future<PermissionAccess> camera();

  Future<PermissionAccess> microphone();

  /// Shows the system prompt for the camera, then (when it was allowed) for the microphone.
  Future<void> request();

  /// Shows the system prompt for the microphone alone. iOS lists an app's microphone switch in Settings
  /// only after it has asked once.
  Future<void> requestMicrophone();

  /// Opens the app's page in the device Settings. False when it cannot.
  Future<bool> openSettings();
}

/// [CameraPermissionService] over `permission_handler`.
@LazySingleton(as: CameraPermissionService)
final class HandlerCameraPermissionService implements CameraPermissionService {
  @override
  Future<PermissionAccess> camera() async =>
      _map(await Permission.camera.status);

  @override
  Future<PermissionAccess> microphone() async =>
      _map(await Permission.microphone.status);

  @override
  Future<void> request() async {
    final camera = await Permission.camera.request();
    if (camera.isGranted) await Permission.microphone.request();
  }

  @override
  Future<void> requestMicrophone() async {
    await Permission.microphone.request();
  }

  @override
  Future<bool> openSettings() => openAppSettings();

  PermissionAccess _map(PermissionStatus status) {
    if (status.isGranted || status.isLimited || status.isProvisional) {
      return PermissionAccess.granted;
    }
    if (status.isPermanentlyDenied) return PermissionAccess.blocked;
    if (status.isRestricted) return PermissionAccess.restricted;
    return PermissionAccess.denied;
  }
}
