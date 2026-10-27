import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/entity/content_publish_status.dart';
import '../../../../../shared/content/domain/use_case/get_privacy_use_case.dart';
import '../../../../../shared/content/domain/use_case/get_publish_status_use_case.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../../data/repository/post_repository.dart';
import '../../../domain/entity/post_mood_entity.dart';
import '../../utils/enums/share_result.dart';
import '../../utils/post_visibility_result.dart';
import '../../utils/tag_choice.dart';
import '../../utils/tag_people_args.dart';
import 'share_sheet_state.dart';

/// The Share sheet (docs/specs/post/screens/s12-share-sheet.md): the words, audience, feeling, place and
/// tagged people of a share of [postId], and Share now. The values stay here while a picker is open.
@injectable
class ShareSheetCubit extends BaseCubit<ShareSheetState> {
  ShareSheetCubit(
    this._posts,
    this._privacy,
    this._publishStatus,
    GetLastAccountUseCase account,
    @factoryParam this.postId,
  ) : me = account(),
      super(const ShareSheetState());

  final PostRepository _posts;
  final GetPrivacyUseCase _privacy;
  final GetPublishStatusUseCase _publishStatus;

  /// The post that is shared; for a share of a share, its original.
  final String postId;

  /// Who is sharing, for the composer; null when this device has no saved account.
  final LastAccountEntity? me;

  /// Starts from the audience the account uses for new posts; if it cannot be read the chip stays Public
  /// and the server applies the account's own default.
  Future<void> loadDefaultAudience() => run(
    _privacy.call,
    prevent: state.isAudienceLocked,
    onSuccess: (privacy) => state.copyWith(
      audience: privacy.defaultVisibility,
      defaultAudience: privacy.defaultVisibility,
    ),
    onFailure: (_) => null,
  );

  /// A share of your own Followers post keeps that audience; the chip only explains why it cannot change.
  void lockAudience(ContentAudience audience) => emit(
    state.copyWith(
      audience: audience,
      defaultAudience: audience,
      isAudienceLocked: true,
    ),
  );

  /// A story is going out now; only one goes at a time, so Add to story waits for it.
  bool get isStoryPosting =>
      _publishStatus(ContentKind.story) is ContentPublishing;

  void captionChanged(String caption) => emit(state.copyWith(caption: caption));

  /// The picker closed with [result]; "use for future posts" makes it the new default.
  void audienceChosen(PostVisibilityResult result) => emit(
    state.copyWith(
      audience: result.audience,
      defaultAudience: result.savedAsDefault
          ? result.audience
          : state.defaultAudience,
    ),
  );

  void moodChanged(PostMoodEntity? mood) => emit(state.copyWith(mood: mood));

  void locationChanged(String? location) =>
      emit(state.copyWith(location: location));

  void tagsChanged(List<TagChoice> tags) => emit(state.copyWith(tags: tags));

  /// What the tag page opens with: a share has no photo, so there is nothing to place a tag on.
  TagPeopleArgs get tagArgs =>
      TagPeopleArgs(chosen: state.tags, photos: const []);

  void clearResult() => emit(state.copyWith(result: null));

  /// Hands the share to the background sender; the sheet closes and Home's banner shows how it goes. The
  /// words are optional.
  void share() {
    final started = _posts.shareToFeed(
      postId,
      caption: state.caption.trim().isEmpty ? null : state.caption.trim(),
      audience: state.audience,
      mood: state.mood,
      location: state.location,
      tags: [for (final tag in state.tags) tag.toTag()],
    );
    emit(
      state.copyWith(result: started ? ShareResult.shared : ShareResult.busy),
    );
  }
}
