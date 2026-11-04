import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/error_reporter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/services/device_diagnostics_service.dart';
import '../../../../core/services/photo_picker_service.dart';

abstract interface class ProblemReportDatasource {
  Future<void> submit({
    required String category,
    required String message,
    required List<PickedPhoto> photos,
    required bool includeLogs,
    void Function(int completed)? onProgress,
  });
}

@LazySingleton(as: ProblemReportDatasource)
final class SupabaseProblemReportDatasource implements ProblemReportDatasource {
  SupabaseProblemReportDatasource(this._client, this._diagnostics);
  final SupabaseClient _client;
  final DeviceDiagnosticsService _diagnostics;

  @override
  Future<void> submit({
    required String category,
    required String message,
    required List<PickedPhoto> photos,
    required bool includeLogs,
    void Function(int completed)? onProgress,
  }) => Guard.run(() async {
    final uid =
        _client.auth.currentUser?.id ??
        (throw const AuthRejectedException(AuthFailureReason.sessionExpired));
    final bucket = _client.storage.from('problem-reports');
    final paths = <String>[];
    final random = Random.secure();
    final prefix = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    var submitting = false;
    try {
      for (var i = 0; i < photos.length; i++) {
        final photo = photos[i];
        if (photo.bytes.length > 5 * 1024 * 1024) {
          throw const FormatException('Screenshot too large');
        }
        final extension = switch (photo.contentType) {
          'image/png' => 'png',
          'image/webp' => 'webp',
          _ => 'jpg',
        };
        final path = '$uid/$prefix/$i.$extension';
        await bucket.uploadBinary(
          path,
          photo.bytes,
          fileOptions: FileOptions(contentType: photo.contentType),
        );
        paths.add(path);
        onProgress?.call(i + 1);
      }
      final info = includeLogs ? await _diagnostics.collect() : null;
      submitting = true;
      await _client.rpc<dynamic>(
        'submit_problem_report',
        params: {
          'p_category': category,
          'p_message': message.trim(),
          'p_screenshot_paths': paths,
          'p_device_info': info,
          'p_logs': includeLogs ? ErrorReporter.recentErrors.join('\n') : null,
        },
      );
    } catch (_) {
      if (!submitting && paths.isNotEmpty) {
        try {
          await bucket.remove(paths);
        } catch (_) {
          /* Best-effort cleanup. */
        }
      }
      rethrow;
    }
  });
}
