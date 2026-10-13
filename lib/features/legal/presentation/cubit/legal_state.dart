import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/model/legal_document_model.dart';

part 'legal_state.freezed.dart';

/// State of a legal page: loading until the document arrives or the load fails.
@freezed
abstract class LegalState with _$LegalState {
  const factory LegalState({
    @Default(true) bool loading,
    LegalDocumentModel? document,

    /// Why the load failed; the page shows it with a Retry.
    Failure? failure,
  }) = _LegalState;
}
