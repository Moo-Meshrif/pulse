import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Whether this device is too weak for live blur. Decided once at start-up; never throws.
class DeviceTier {
  const DeviceTier({required this.isLow});

  final bool isLow;

  static const normal = DeviceTier(isLow: false);

  // `physicalRamSize` is the total RAM in MB; a 3 GB phone reports a little under 3072.
  /// Low-tier devices keep the frosted look with a lighter blur: its cost grows with the sigma.
  static const lowSigmaFactor = 0.45;

  static const _lowRamMb = 3072;
  static const _minSdk = 29;

  /// Android is low-tier on a low-RAM flag, 3 GB or less, or older than Android 10. iPhones that can run
  /// the app all handle the blur.
  static Future<DeviceTier> detect() async {
    if (!Platform.isAndroid) return normal;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return DeviceTier(
        isLow:
            info.isLowRamDevice ||
            info.physicalRamSize <= _lowRamMb ||
            info.version.sdkInt < _minSdk,
      );
    } catch (_) {
      return normal;
    }
  }
}
