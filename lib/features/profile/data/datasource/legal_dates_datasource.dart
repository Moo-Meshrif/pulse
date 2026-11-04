import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/utils/json_mapper.dart';

abstract interface class LegalDatesDatasource {
  Future<Map<String, DateTime>> getUpdatedDates(String locale);
}

@LazySingleton(as: LegalDatesDatasource)
final class SupabaseLegalDatesDatasource implements LegalDatesDatasource {
  SupabaseLegalDatesDatasource(this._client);
  final SupabaseClient _client;

  @override
  Future<Map<String, DateTime>> getUpdatedDates(String locale) =>
      Guard.run(() async {
        final rows = await _client.rpc<List<dynamic>>(
          'legal_updated_dates',
          params: {'p_locale': locale},
        );
        final dates = <String, DateTime>{};
        for (final row in rows) {
          if (row is! Map) continue;
          final type = JsonMapper.string(row['type']);
          final date = JsonMapper.date(row['updated_at']);
          if (type != null && date != null) dates[type] = date;
        }
        return dates;
      });
}
