import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

/// Everything the app hands to another app. One method per use, so callers say what they want, not how
/// (`mailto:`), and tests mock it. Each returns false when no app can open it.
abstract interface class LaunchService {
  /// Opens the device's mail app.
  Future<bool> openEmailApp();
}

/// [LaunchService] over `url_launcher`.
@LazySingleton(as: LaunchService)
final class UrlLauncherLaunchService implements LaunchService {
  @override
  Future<bool> openEmailApp() => _launch(Uri(scheme: 'mailto'));

  Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri);
    } on Object {
      return false;
    }
  }
}
