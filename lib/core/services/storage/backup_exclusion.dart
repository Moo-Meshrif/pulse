import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../error/guard.dart';

/// Leaves a folder out of the phone's backup. Android does it with the rules in
/// `android/app/src/main/res/xml/` (a folder there must be listed by name); iOS needs this call.
abstract interface class BackupExclusionService {
  Future<void> exclude(String folder);
}

/// iOS: `pulse/backup` `exclude(path)` sets `isExcludedFromBackup` on the folder (ios/Runner/BackupPlugin.swift).
@LazySingleton(as: BackupExclusionService)
final class PlatformBackupExclusionService implements BackupExclusionService {
  static const _channel = MethodChannel('pulse/backup');

  @override
  Future<void> exclude(String folder) => Guard.run(() async {
    if (!Platform.isIOS) return;
    await _channel.invokeMethod<void>('exclude', {'path': folder});
  });
}
