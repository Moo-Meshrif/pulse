import 'package:injectable/injectable.dart';

import '../../../../core/services/media_picker_service.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../../../../shared/content/domain/use_case/get_privacy_use_case.dart';
import '../../../profile/domain/entity/last_account_entity.dart';
import '../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../domain/entity/edit_post_entity.dart';
import '../../domain/entity/new_post_entity.dart';
import '../../domain/entity/new_post_media_entity.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/use_case/create_post_use_case.dart';
import '../../domain/use_case/sign_post_media_urls_use_case.dart';
import '../../domain/use_case/update_post_use_case.dart';
import '../utils/enums/new_post_notice.dart';
import '../utils/media_intake.dart';
import '../utils/new_post_limits.dart';
import '../utils/post_visibility_result.dart';
import 'add_edit_post_state.dart';

/// The Add post and Edit post screen (docs/specs/post/screens/s1-new-post.md, s5-edit-post.md): caption,
/// photos and videos, place, audience, comments switch and Share or Save. It edits [post] when given one.
/// Editing keeps the post's own media in [AddEditPostState.kept] and sends only what changed.
@injectable
class AddEditPostCubit extends BaseCubit<AddEditPostState> {
  AddEditPostCubit(
    this._createPost,
    this._updatePost,
    this._signUrls,
    MediaPickerService picker,
    this._privacy,
    VideoThumbnailService thumbnails,
    GetLastAccountUseCase account,
    @factoryParam PostEntity? post,
  ) : _intake = MediaIntake(picker, thumbnails),
      me = account(),
      super(
        post == null
            ? AddEditPostState(postId: uuidV4())
            : AddEditPostState.editing(post),
      );

  /// A photo whose size is unknown is shared as this square.
  static const _fallbackSide = 1080;

  final CreatePostUseCase _createPost;
  final UpdatePostUseCase _updatePost;
  final SignPostMediaUrlsUseCase _signUrls;
  final MediaIntake _intake;
  final GetPrivacyUseCase _privacy;

  /// Who is posting, for the author row; null when this device has no saved account.
  final LastAccountEntity? me;

  /// Adding starts from the audience the account uses for new posts; editing keeps the post's own and only
  /// learns the default for the chip. If it cannot be read the chip stays Public, and the server applies
  /// the account's own default.
  Future<void> loadDefaultVisibility() => run(
    _privacy.call,
    onSuccess: (privacy) => state.copyWith(
      visibility: state.isEditing
          ? state.visibility
          : privacy.defaultVisibility,
      defaultVisibility: privacy.defaultVisibility,
    ),
    onFailure: (_) => null,
  );

  /// Editing: signs the post's own photos and posters for the strip. Without links the strip draws plain
  /// tiles.
  Future<void> loadUrls() => run(
    () => _signUrls([
      for (final item in state.kept) ...[item.path, ?item.thumbPath],
    ]),
    prevent: !state.isEditing,
    onSuccess: (urls) => state.copyWith(urls: urls),
    onFailure: (_) => null,
  );

  void captionChanged(String caption) => emit(state.copyWith(caption: caption));

  /// The picker closed with [result]. When it saved the audience as the default, that is the new default.
  void audienceChosen(PostVisibilityResult result) => emit(
    state.copyWith(
      visibility: result.audience,
      defaultVisibility: result.savedAsDefault
          ? result.audience
          : state.defaultVisibility,
    ),
  );

  void commentsChanged(bool enabled) =>
      emit(state.copyWith(commentsEnabled: enabled));

  void locationChanged(String? location) =>
      emit(state.copyWith(location: location));

  /// Removes the item at [index] of the strip: the post's own media first, then the picked files.
  void removeMedia(int index) {
    final keptCount = state.kept.length;
    if (index < keptCount) {
      emit(
        state.copyWith(
          kept: [
            for (final (i, item) in state.kept.indexed)
              if (i != index) item,
          ],
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        media: [
          for (final (i, item) in state.media.indexed)
            if (i != index - keptCount) item,
        ],
      ),
    );
  }

  Future<void> pickMedia() async {
    if (state.isSaving) return;
    final room = NewPostLimits.maxMedia - state.mediaCount;
    if (room <= 0) {
      emit(state.copyWith(notice: NewPostNotice.mediaLimit));
      return;
    }
    final batch = await _intake.pick(room: room);
    if (batch.isEmpty) return;
    emit(
      state.copyWith(
        media: [...state.media, ...batch.accepted],
        posters: {...state.posters, ...batch.posters},
        notice: batch.notice,
      ),
    );
  }

  void clearNotice() => emit(state.copyWith(notice: null));

  /// Uploads the files and creates the post, or saves the edited one. A failure stays on the screen; Retry
  /// calls this again (a new post keeps its id, so the files already uploaded are not sent twice).
  Future<void> save() => run(
    _send,
    prevent: !state.canSave,
    loading: state.copyWith(isSaving: true),
    onSuccess: (_) => state.copyWith(isSaving: false, isSaved: true),
    onFailure: (_) => state.copyWith(
      isSaving: false,
      notice: state.isEditing
          ? NewPostNotice.saveFailed
          : NewPostNotice.shareFailed,
    ),
  );

  Future<void> _send() {
    final caption = state.caption.trim();
    final original = state.original;
    if (original == null) {
      return _createPost(
        NewPostEntity(
          id: state.postId,
          caption: caption.isEmpty ? null : caption,
          location: state.location,
          commentsEnabled: state.commentsEnabled,
          visibility: state.visibility,
          media: _pickedFiles(),
          authorUsername: me?.username,
          authorFullName: me?.fullName,
          authorAvatarUrl: me?.avatarUrl,
        ),
      );
    }
    return _updatePost(
      EditPostEntity(
        id: state.postId,
        caption: caption.isEmpty ? null : caption,
        location: state.location,
        kept: state.kept,
        added: _pickedFiles(),
        commentsEnabled: state.commentsEnabled,
        visibility: state.visibility,
      ),
      before: original,
    );
  }

  List<NewPostMediaEntity> _pickedFiles() => [
    for (final item in state.media)
      NewPostMediaEntity(
        filePath: item.path,
        isVideo: item.isVideo,
        width: item.width ?? _fallbackSide,
        height: item.height ?? _fallbackSide,
        durationMs: item.isVideo ? (item.durationMs ?? 0) : null,
        blurhash: item.blurhash,
      ),
  ];
}
