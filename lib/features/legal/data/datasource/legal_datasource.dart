import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../model/legal_document_model.dart';

/// The Terms and the Privacy Policy, written as HTML by the backend.
abstract interface class LegalDatasource {
  /// The document of [type] (`terms`, `privacy`) in [languageCode], or in English when that language
  /// has none. Throws [NotFoundFailure] when the document does not exist at all.
  Future<LegalDocumentModel> getDocument(String type, String languageCode);
}

/// [LegalDatasource] as an adapter over Supabase: the `legal_document` function (open to signed-out
/// users, because the sign-up form links to these pages).
@LazySingleton(as: LegalDatasource)
final class SupabaseLegalDatasource implements LegalDatasource {
  SupabaseLegalDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<LegalDocumentModel> getDocument(String type, String languageCode) =>
      Guard.run(() async {
        final rows = await _client.rpc<List<dynamic>>(
          'legal_document',
          params: {'p_type': type, 'p_locale': languageCode},
        );
        if (rows.isEmpty) throw const NotFoundFailure();
        return LegalDocumentModel.fromJson(rows.first as Map<String, dynamic>);
      });
}
