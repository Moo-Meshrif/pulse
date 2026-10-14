import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../enums/permission_access.dart';
import '../utils/equatable.dart';
import 'permission_access_mapper.dart';

/// Where the device is, once.
class DevicePosition extends Equatable {
  const DevicePosition({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

/// The device's location permission and its position at one moment (never tracking). Tests mock it.
abstract interface class LocationService {
  Future<PermissionAccess> permission();

  /// Shows the system prompt.
  Future<void> request();

  /// Opens the app's page in the device Settings. False when it cannot.
  Future<bool> openSettings();

  /// The position now, or null when location is off, not allowed, or no fix came in time.
  Future<DevicePosition?> currentPosition();
}

/// [LocationService]: the permission through `permission_handler` (as the camera does), the position
/// through `geolocator`.
@LazySingleton(as: LocationService)
final class GeolocatorLocationService implements LocationService {
  /// A rough fix is enough to name a neighborhood, and it comes sooner on a coarse-only permission.
  static const _accuracy = LocationAccuracy.medium;
  static const _fixTimeout = Duration(seconds: 10);

  @override
  Future<PermissionAccess> permission() async =>
      permissionAccessOf(await Permission.locationWhenInUse.status);

  @override
  Future<void> request() async {
    await Permission.locationWhenInUse.request();
  }

  @override
  Future<bool> openSettings() => openAppSettings();

  @override
  Future<DevicePosition?> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: _accuracy,
          timeLimit: _fixTimeout,
        ),
      );
      return DevicePosition(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on Object {
      // Off, refused or no fix in time: the caller shows the screen without nearby places.
      return null;
    }
  }
}
