import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../model/audience_summary_model.dart';

/// The numbers behind every "who can see this" choice: your followers, your close friends, the people
/// hidden from you. Core, because stories and posts both show them. Throws a `Failure` on error.
abstract interface class AudienceDatasource {
  Future<AudienceSummaryModel> getSummary();
}

/// [AudienceDatasource] as an adapter over Supabase: the `audience_summary` function.
@LazySingleton(as: AudienceDatasource)
final class SupabaseAudienceDatasource implements AudienceDatasource {
  SupabaseAudienceDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<AudienceSummaryModel> getSummary() => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>('audience_summary');
    final list = List<Map<String, dynamic>>.from(rows);
    return list.isEmpty
        ? const AudienceSummaryModel()
        : AudienceSummaryModel.fromJson(list.first);
  });
}
