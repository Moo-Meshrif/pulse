import '../enums/permission_access.dart';
import '../utils/equatable.dart';

/// What the camera gate shows (docs/specs/story/screens/s5-camera-permissions.md).
enum CameraPermissionStep {
  /// Reading the permissions.
  checking,

  /// Panel 1: the first ask (also when the camera was refused but can still be asked).
  ask,

  /// Panel 2: the camera is off for good.
  blocked,

  /// The camera is allowed: the camera opens (panel 3's pill when [CameraPermissionState.isMicOff]).
  ready,
}

class CameraPermissionState extends Equatable {
  const CameraPermissionState({
    this.step = CameraPermissionStep.checking,
    this.camera = PermissionAccess.denied,
    this.microphone = PermissionAccess.denied,
  });

  final CameraPermissionStep step;
  final PermissionAccess camera;
  final PermissionAccess microphone;

  bool get isMicOff => microphone != PermissionAccess.granted;

  /// Parental controls: panel 2 without Open settings.
  bool get isRestricted => camera == PermissionAccess.restricted;

  @override
  List<Object?> get props => [step, camera, microphone];
}
