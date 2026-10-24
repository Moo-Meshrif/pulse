import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// The app's own folders on this device, read once at start-up so they can be used without waiting.
class AppFolders {
  const AppFolders({
    required this.support,
    required this.temporary,
    required this.cache,
  });

  /// Files the app keeps until it deletes them (Application Support on iOS, `files` on Android). It is
  /// part of the phone's backup unless a folder is left out (see `BackupExclusionService`).
  final String support;

  /// Where the system and plugins put short-lived copies (the picker's files, video frames).
  final List<String> temporary;

  /// Copies the app can rebuild (the saved Home). Left out of backups; the system may clear it.
  final String cache;

  static Future<AppFolders> resolve() async => AppFolders(
    support: (await getApplicationSupportDirectory()).path,
    cache: (await getApplicationCacheDirectory()).path,
    // iOS: the picker writes to tmp/ (systemTemp) and path_provider's temporary is Library/Caches.
    temporary: {
      (await getTemporaryDirectory()).path,
      Directory.systemTemp.path,
    }.toList(),
  );

  /// True when [path] is inside one of the [temporary] folders, so the app may move it.
  bool isTemporary(String path) =>
      temporary.any((folder) => path.startsWith('$folder/'));
}
