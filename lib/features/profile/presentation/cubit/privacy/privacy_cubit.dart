import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../data/datasource/blocks_datasource.dart';
import '../../../data/datasource/privacy_settings_datasource.dart';
import '../../../data/enums/comment_audience.dart';
import '../../../data/enums/message_audience.dart';
import '../../../data/model/privacy_settings_model.dart';
import 'privacy_state.dart';

/// Settings > Privacy (docs/specs/profile/screens/s5-privacy.md): each choice saves at once, shown first
/// and put back if the save fails.
@injectable
class PrivacyCubit extends BaseCubit<PrivacyState> {
  PrivacyCubit(this._privacy, this._blocks) : super(const PrivacyState());

  final PrivacySettingsDatasource _privacy;
  final BlocksDatasource _blocks;

  Future<void> load() => run(
    () => (_privacy.get(), _blocks.count()).wait,
    loading: state.copyWith(loadFailed: false),
    onSuccess: (data) =>
        state.copyWith(settings: data.$1, blockedCount: data.$2),
    onFailure: (_) => state.copyWith(loadFailed: true),
  );

  /// Reads the blocked count again (after the blocked list was open). A failure keeps the old number.
  Future<void> reloadBlockedCount() => run(
    _blocks.count,
    onSuccess: (count) => state.copyWith(blockedCount: count),
    onFailure: (_) => null,
  );

  Future<void> setPrivate(bool value) => _change(
    (s) => s.isPrivate,
    (s, v) => s.copyWith(isPrivate: v),
    value,
    _privacy.setPrivate,
  );

  Future<void> setWhoCanMessage(MessageAudience value) => _change(
    (s) => s.whoCanMessage,
    (s, v) => s.copyWith(whoCanMessage: v),
    value,
    _privacy.setWhoCanMessage,
  );

  Future<void> setWhoCanComment(CommentAudience value) => _change(
    (s) => s.whoCanComment,
    (s, v) => s.copyWith(whoCanComment: v),
    value,
    _privacy.setWhoCanComment,
  );

  Future<void> setShowActivity(bool value) => _change(
    (s) => s.showActivity,
    (s, v) => s.copyWith(showActivity: v),
    value,
    _privacy.setShowActivity,
  );

  Future<void> setAppearInSearch(bool value) => _change(
    (s) => s.appearInSearch,
    (s, v) => s.copyWith(appearInSearch: v),
    value,
    _privacy.setAppearInSearch,
  );

  Future<void> _change<T>(
    T Function(PrivacySettingsModel) read,
    PrivacySettingsModel Function(PrivacySettingsModel, T) write,
    T value,
    Future<void> Function(T) save,
  ) async {
    final current = state.settings;
    if (current == null || read(current) == value) return;
    final before = read(current);
    emit(state.copyWith(settings: write(current, value), failure: null));
    await run(
      () => save(value),
      onSuccess: (_) => null,
      // Only this choice goes back: another one may have changed meanwhile.
      onFailure: (failure) => state.copyWith(
        settings: state.settings == null
            ? null
            : write(state.settings!, before),
        failure: failure,
      ),
    );
  }
}
