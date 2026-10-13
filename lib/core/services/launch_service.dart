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

  /// Opens [uri] in the device's browser (or the app registered for its scheme, e.g. `mailto:`).
  Future<bool> openUrl(Uri uri);
}

/// [LaunchService] over `url_launcher`.
@LazySingleton(as: LaunchService)
final class UrlLauncherLaunchService implements LaunchService {
  /// Gmail, Outlook, then Apple Mail. Each must also be listed in `LSApplicationQueriesSchemes`.
  static const _iosMailSchemes = ['googlegmail', 'ms-outlook', 'message'];

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
          // No shared inbox scheme exists, so try each known mail app; the first installed one opens.
          for (final scheme in _iosMailSchemes) {
            if (await _launch(Uri(scheme: scheme, host: ''))) return true;
          }
        default:
          break;
      }
    }
    return _launch(Uri(scheme: 'mailto'));
  }

  @override
  Future<bool> openUrl(Uri uri) =>
      _launch(uri, mode: LaunchMode.externalApplication);

  Future<bool> _launch(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      return await launchUrl(uri, mode: mode);
    } on Object {
      return false;
    }
  }
}
