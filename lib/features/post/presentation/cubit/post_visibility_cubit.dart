import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/domain/use_case/get_audience_summary_use_case.dart';
import '../../../../shared/content/domain/use_case/get_privacy_use_case.dart';
import '../../../../shared/content/domain/use_case/save_default_audience_use_case.dart';
import '../../../../shared/content/domain/use_case/set_content_audience_use_case.dart';
import '../../data/datasource/visibility_notice_datasource.dart';
import '../utils/enums/post_visibility_status.dart';
import '../utils/post_visibility_result.dart';
import 'post_visibility_state.dart';

/// The visibility picker (docs/specs/post/screens/s4-visibility.md): one choice, applied on Done. On New
/// post ([postId] null) Done can also save the choice as the default for future posts; on an existing
/// post Save changes that post.
@injectable
class PostVisibilityCubit extends BaseCubit<PostVisibilityState> {
  PostVisibilityCubit(
    this._privacy,
    this._summary,
    this._saveDefault,
    this._setAudience,
    this._notices,
    @factoryParam this.postId,
    @factoryParam ContentAudience audience,
  ) : super(PostVisibilityState(audience: audience, current: audience));

  final GetPrivacyUseCase _privacy;
  final GetAudienceSummaryUseCase _summary;
  final SaveDefaultAudienceUseCase _saveDefault;
  final SetContentAudienceUseCase _setAudience;
  final VisibilityNoticeDatasource _notices;

  /// The post being changed; null on New post.
  final String? postId;

  bool get isNewPost => postId == null;

  /// Loads whether the account is private and how many people each audience reaches (also the retry).
  Future<void> loadChoices() => run(
    () => (_privacy(), _summary()).wait,
    loading: state.copyWith(status: PostVisibilityStatus.loading),
    onSuccess: (data) {
      final (privacy, summary) = data;
      return state.copyWith(
        status: PostVisibilityStatus.ready,
        isPrivate: privacy.isPrivate,
        summary: summary,
        audience: _allowed(state.audience, isPrivate: privacy.isPrivate),
      );
    },
    onFailure: (_) => state.copyWith(status: PostVisibilityStatus.failed),
  );

  /// The close friends list changed: the counts moved. A failed reload leaves the sheet as it is.
  Future<void> reloadCounts() => run(
    _summary.call,
    onSuccess: (summary) => state.copyWith(
      summary: summary,
      audience:
          state.audience == ContentAudience.closeFriends &&
              summary.closeFriends == 0
          ? ContentAudience.followers
          : state.audience,
    ),
    onFailure: (_) => null,
  );

  void select(ContentAudience audience) {
    if (state.isSaving || audience == state.audience) return;
    if (audience == ContentAudience.public && state.isPrivate) return;
    emit(state.copyWith(audience: audience));
  }

  void saveAsDefaultChanged(bool save) =>
      emit(state.copyWith(saveAsDefault: save));

  /// Done (New post) or Save (existing post).
  Future<void> confirm() async {
    if (state.isSaving) return;
    final audience = state.audience;
    if (isNewPost) {
      await run(
        () async {
          if (state.saveAsDefault) await _saveDefault(audience);
        },
        loading: state.copyWith(isSaving: true, failure: null),
        onSuccess: (_) =>
            state.copyWith(isSaving: false, result: _resultFor(audience)),
        onFailure: (failure) =>
            state.copyWith(isSaving: false, failure: failure),
      );
      return;
    }
    await run(
      () async {
        if (audience != state.current) {
          await _setAudience(ContentKind.post, postId!, audience);
        }
      },
      loading: state.copyWith(isSaving: true, failure: null),
      onSuccess: (_) => state.copyWith(
        isSaving: false,
        result: PostVisibilityResult(audience: audience),
      ),
      onFailure: (failure) => state.copyWith(isSaving: false, failure: failure),
    );
  }

  /// The first post to Close friends or Only me comes with a one-time notice; showing it counts as seen.
  PostVisibilityResult _resultFor(ContentAudience audience) {
    final savedAsDefault = state.saveAsDefault;
    final showNotice = audience.hasFirstUseNotice && !_notices.isSeen(audience);
    if (!showNotice) {
      return PostVisibilityResult(
        audience: audience,
        savedAsDefault: savedAsDefault,
      );
    }
    _notices.markSeen(audience);
    return PostVisibilityResult(
      audience: audience,
      savedAsDefault: savedAsDefault,
      firstUseNotice: audience,
      reach: state.summary.closeFriends,
    );
  }

  /// A private account never offers Public.
  ContentAudience _allowed(
    ContentAudience audience, {
    required bool isPrivate,
  }) => isPrivate && audience == ContentAudience.public
      ? ContentAudience.followers
      : audience;
}
