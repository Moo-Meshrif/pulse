import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';

@injectable
class MutualPreviewDatasource {
  MutualPreviewDatasource(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> get(String userId) => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>(
      'mutual_followers_preview',
      params: {'p_user': userId},
    );
    return rows.isEmpty ? {} : Map<String, dynamic>.from(rows.first as Map);
  });
}
