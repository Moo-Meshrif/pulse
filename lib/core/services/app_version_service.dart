import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The installed app's version. An interface so tests do not need the platform.
abstract interface class AppVersionService {
  /// The version name, e.g. `1.2.0`.
  Future<String> version();
}

/// [AppVersionService] over `package_info_plus`.
@LazySingleton(as: AppVersionService)
final class PackageInfoVersionService implements AppVersionService {
  @override
  Future<String> version() async => (await PackageInfo.fromPlatform()).version;
}
