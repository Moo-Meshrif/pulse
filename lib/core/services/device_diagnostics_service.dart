import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';

import 'app_version_service.dart';

abstract interface class DeviceDiagnosticsService {
  Future<Map<String, String?>> collect();
}

@LazySingleton(as: DeviceDiagnosticsService)
final class DeviceInfoDiagnosticsService implements DeviceDiagnosticsService {
  DeviceInfoDiagnosticsService(this._version);
  final AppVersionService _version;

  @override
  Future<Map<String, String?>> collect() async {
    final plugin = DeviceInfoPlugin();
    String? model;
    try {
      if (Platform.isIOS) model = (await plugin.iosInfo).utsname.machine;
      if (Platform.isAndroid) model = (await plugin.androidInfo).model;
    } on Object {
      model = null;
    }
    String? version;
    try {
      version = await _version.version();
    } on Object {
      version = null;
    }
    return {
      'model': model,
      'os': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'app_version': version,
    };
  }
}
