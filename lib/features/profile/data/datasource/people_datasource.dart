import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../enums/people_kind.dart';
import '../model/person_model.dart';

/// The lists of people on a profile. Every call throws a `Failure` on error.
abstract interface class PeopleDatasource {
  /// A page of [kind] for [userId], newest first, narrowed by [query] (name or username). [before] is
  /// the last person already shown. A private account the caller does not follow answers an empty list.
  Future<List<PersonModel>> getPeople(
    PeopleKind kind,
    String userId, {
    String? query,
    PersonModel? before,
    int limit = pageSize,
  });

  static const pageSize = 20;
}

/// [PeopleDatasource] as an adapter over `followers_of`, `following_of` and `mutual_followers`.
@LazySingleton(as: PeopleDatasource)
final class SupabasePeopleDatasource implements PeopleDatasource {
  SupabasePeopleDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PersonModel>> getPeople(
    PeopleKind kind,
    String userId, {
    String? query,
    PersonModel? before,
    int limit = PeopleDatasource.pageSize,
  }) => Guard.run(() async {
    final rows = await _client.rpc<List<dynamic>>(
      kind.function,
      params: {
        'p_user': userId,
        'p_q': query,
        'p_limit': limit,
        'p_before_time': before?.sortAt?.toIso8601String(),
        'p_before_id': before?.id,
      },
    );
    return List<Map<String, dynamic>>.from(rows)
        .map(PersonModel.fromJson)
        .toList();
  });
}
