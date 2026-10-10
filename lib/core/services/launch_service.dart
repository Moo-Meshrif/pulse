import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

/// Everything the app hands to another app. One method per use, so callers say what they want, not how
/// (intents, URL schemes), and tests mock it. Each returns false when no app can open it.
abstract interface class LaunchService {
  /// Opens the device's mail app on its inbox (not a new message), falling back to a blank message
  /// when the device has no inbox entry point.
  Future<bool> openEmailApp();
}

/// [LaunchService] over `url_launcher`.
@LazySingleton(as: LaunchService)
final class UrlLauncherLaunchService implements LaunchService {
  @override
  Future<bool> openEmailApp() async {
    if (!kIsWeb) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          // The "email app" category opens the default mail app's inbox.
          try {
            await const AndroidIntent(
              action: 'android.intent.action.MAIN',
              category: 'android.intent.category.APP_EMAIL',
              flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
            ).launch();
            return true;
          } on Object {
            break;
          }
        case TargetPlatform.iOS:
          // Apple Mail's inbox; other mail apps have no shared scheme.
          if (await _launch(Uri(scheme: 'message'))) return true;
        default:
          break;
      }
    }
    return _launch(Uri(scheme: 'mailto'));
  }

  Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri);
    } on Object {
      return false;
    }
  }
}
