import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/media_picker_service.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../../../../shared/content/domain/use_case/get_privacy_use_case.dart';
import '../../../profile/domain/entity/last_account_entity.dart';
import '../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../domain/entity/new_post_entity.dart';
import '../../domain/entity/new_post_media_entity.dart';
import '../../domain/use_case/create_post_use_case.dart';
import '../utils/enums/new_post_notice.dart';
import '../utils/new_post_limits.dart';
import '../utils/post_visibility_result.dart';
import 'new_post_state.dart';

/// The New post screen (docs/specs/post/screens/s1-new-post.md): caption, photos and videos, place,
/// comments switch and Share.
@injectable
class NewPostCubit extends BaseCubit<NewPostState> {
  NewPostCubit(
    this._createPost,
    this._picker,
    this._privacy,
    this._thumbnails,
    GetLastAccountUseCase account,
  ) : me = account(),
      super(NewPostState(postId: uuidV4()));

  /// A photo whose size is unknown is shared as this square.
  static const _fallbackSide = 1080;

  final CreatePostUseCase _createPost;
  final MediaPickerService _picker;
  final GetPrivacyUseCase _privacy;
  final VideoThumbnailService _thumbnails;

  /// Who is posting, for the author row; null when this device has no saved account.
  final LastAccountEntity? me;

  /// Starts from the audience the account uses for new posts. If it cannot be read the chip stays
  /// Public, and the server applies the account's own default.
  Future<void> loadDefaultVisibility() => run(
    _privacy.call,
    onSuccess: (privacy) => state.copyWith(
      visibility: privacy.defaultVisibility,
      defaultVisibility: privacy.defaultVisibility,
    ),
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

  void removeMedia(int index) => emit(
    state.copyWith(
      media: [
        for (final (i, item) in state.media.indexed)
          if (i != index) item,
      ],
    ),
  );

  Future<void> pickMedia() async {
    if (state.isSharing) return;
    final room = NewPostLimits.maxMedia - state.media.length;
    if (room <= 0) {
      emit(state.copyWith(notice: NewPostNotice.mediaLimit));
      return;
    }
    final picked = await _picker.pickMany(limit: room);
    final accepted = <PickedMedia>[];
    NewPostNotice? notice;
    for (final item in picked) {
      final rejection = NewPostLimits.rejection(item);
      if (rejection == null) {
        accepted.add(item);
      } else {
        notice ??= rejection;
      }
    }
    if (accepted.isEmpty && notice == null) return;
    final posters = await _posters(accepted);
    emit(
      state.copyWith(
        media: [...state.media, ...accepted],
        posters: {...state.posters, ...posters},
        notice: notice,
      ),
    );
  }

  Future<Map<String, String>> _posters(List<PickedMedia> picked) async {
    final posters = <String, String>{};
    await Future.wait([
      for (final item in picked)
        if (item.isVideo) _addPoster(posters, item.path),
    ]);
    return posters;
  }

  Future<void> _addPoster(Map<String, String> posters, String video) async {
    try {
      posters[video] = await _thumbnails.thumbnail(video);
    } on Failure {
      // The thumbnail strip draws a plain tile for it.
    }
  }

  void clearNotice() => emit(state.copyWith(notice: null));

  /// Uploads the files and creates the post. A failure stays on the screen; Retry calls this again with
  /// the same post id.
  Future<void> share() => run(
    () => _createPost(_post()),
    prevent: !state.canShare,
    loading: state.copyWith(isSharing: true),
    onSuccess: (_) => state.copyWith(isSharing: false, isShared: true),
    onFailure: (_) =>
        state.copyWith(isSharing: false, notice: NewPostNotice.shareFailed),
  );

  NewPostEntity _post() {
    final caption = state.caption.trim();
    return NewPostEntity(
      id: state.postId,
      caption: caption.isEmpty ? null : caption,
      location: state.location,
      commentsEnabled: state.commentsEnabled,
      visibility: state.visibility,
      media: [
        for (final item in state.media)
          NewPostMediaEntity(
            filePath: item.path,
            isVideo: item.isVideo,
            width: item.width ?? _fallbackSide,
            height: item.height ?? _fallbackSide,
            durationMs: item.isVideo ? (item.durationMs ?? 0) : null,
            blurhash: item.blurhash,
          ),
      ],
    );
  }
}
