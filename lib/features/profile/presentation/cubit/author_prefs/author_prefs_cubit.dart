import 'package:injectable/injectable.dart';

import '../../../../../core/enums/report_reason.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/services/launch_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/data/enums/mute_scope.dart';
import '../../../../../shared/content/domain/use_case/set_mute_use_case.dart';
import '../../../data/datasource/author_prefs_datasource.dart';
import '../../utils/profile_link.dart';
import 'author_prefs_state.dart';

/// Manages preferences and actions for the current profile.
@injectable
class AuthorPrefsCubit extends BaseCubit<AuthorPrefsState> {
  AuthorPrefsCubit(
    this._prefs,
    this._mute,
    this._launch,
    @factoryParam this.userId,
  ) : super(const AuthorPrefsState());

  final AuthorPrefsDatasource _prefs;
  final SetMuteUseCase _mute;
  final LaunchService _launch;
  final String userId;

  Future<void> load() async {
    if (state.busy) return;
    await run(
      () => _prefs.load(userId),
      loading: const AuthorPrefsState(busy: true),
      onSuccess: (values) => AuthorPrefsState(values: values),
      onFailure: (failure) => AuthorPrefsState(failure: failure),
    );
  }

  /// Uses the preference order documented by [AuthorPrefsState.values].
  Future<void> change(int index, bool value) async {
    final previous = state.values;
    if (state.busy || previous == null) return;
    final updated = List<bool>.of(previous)..[index] = value;
    if (index == 2) updated[3] = value;
    await run(
      () => index == 2
          ? _setMute(value, previous[2])
          : _prefs.set(userId, enabled: value, closeFriend: index == 0),
      loading: AuthorPrefsState(values: updated, busy: true),
      onSuccess: (_) => AuthorPrefsState(values: updated),
      onFailure: (failure) =>
          AuthorPrefsState(values: previous, failure: failure),
    );
  }

  Future<void> _setMute(bool value, bool previousPosts) async {
    await _mute(userId, muted: value, scope: MuteScope.posts);
    try {
      await _mute(userId, muted: value, scope: MuteScope.stories);
    } on Failure {
      // Restore the post mute if the story mute fails.
      await _mute(userId, muted: previousPosts, scope: MuteScope.posts);
      rethrow;
    }
  }

  Future<void> report(ReportReason reason, String? note) =>
      _prefs.report(userId, reason, note);
  Future<bool> share() => _launch.shareText(profileLink(userId));
}
