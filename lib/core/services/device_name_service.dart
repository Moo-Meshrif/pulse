import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';

/// The name of this phone, e.g. `iPhone 15`. An interface so tests do not need the platform.
abstract interface class DeviceNameService {
  /// Null when the platform does not tell.
  Future<String?> name();
}

/// [DeviceNameService] over `device_info_plus`.
@LazySingleton(as: DeviceNameService)
final class DeviceInfoNameService implements DeviceNameService {
  @override
  Future<String?> name() async {
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isIOS) return (await plugin.iosInfo).name;
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return '${info.manufacturer} ${info.model}';
      }
    } catch (_) {
      // The row falls back to a generic label.
    }
    return null;
  }
}
