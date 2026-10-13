import 'package:injectable/injectable.dart';

import '../../../../core/services/launch_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../data/datasource/legal_datasource.dart';
import 'legal_state.dart';

/// Loads one legal page (Terms or Privacy) and opens the links inside it.
@injectable
class LegalCubit extends BaseCubit<LegalState> {
  LegalCubit(this._datasource, this._launch) : super(const LegalState());

  final LegalDatasource _datasource;
  final LaunchService _launch;

  String _type = '';
  String _languageCode = 'en';

  /// Loads the document of [type] in [languageCode]; also the Retry.
  Future<void> load(String type, String languageCode) {
    _type = type;
    _languageCode = languageCode;
    return run(
      () => _datasource.getDocument(type, languageCode),
      loading: const LegalState(),
      onSuccess: (document) => LegalState(loading: false, document: document),
      onFailure: (failure) => LegalState(loading: false, failure: failure),
    );
  }

  Future<void> retry() => load(_type, _languageCode);

  /// A tapped link in the page: the browser (or the mail app for `mailto:`). Links that are not
  /// absolute web or mail addresses are ignored.
  Future<void> openLink(String? url) async {
    final uri = Uri.tryParse(url ?? '');
    if (uri == null ||
        !const {'http', 'https', 'mailto'}.contains(uri.scheme)) {
      return;
    }
    await _launch.openUrl(uri);
  }
}
