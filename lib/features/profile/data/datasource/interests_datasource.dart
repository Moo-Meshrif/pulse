import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../model/interest_model.dart';

/// The topics a user can follow and the ones they picked.
abstract interface class InterestsDatasource {
  /// Active topics in display order.
  Future<List<InterestModel>> getInterests();

  /// Replaces the user's interests with [interestIds].
  Future<void> saveInterests(List<int> interestIds);
}

/// [InterestsDatasource] as an adapter over Supabase: the `interests` table and `set_user_interests`.
@LazySingleton(as: InterestsDatasource)
final class SupabaseInterestsDatasource implements InterestsDatasource {
  SupabaseInterestsDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<InterestModel>> getInterests() => Guard.run(() async {
    // `order` is descending unless told otherwise.
    final rows = await _client
        .from('interests')
        .select()
        .order('sort_order', ascending: true);
    return [for (final row in rows) InterestModel.fromJson(row)];
  });

  @override
  Future<void> saveInterests(List<int> interestIds) => Guard.run(
    () => _client.rpc<dynamic>(
      'set_user_interests',
      params: {'p_ids': interestIds},
    ),
  );
}
