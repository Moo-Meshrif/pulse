import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/blurhash_service.dart';
import '../../../../core/services/gallery_service.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../profile/domain/entity/last_account_entity.dart';
import '../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../data/enums/story_media_type.dart';
import '../../data/model/new_story_model.dart';
import '../../data/model/story_overlay_model.dart';
import '../../data/repository/story_upload_repository.dart';
import '../../domain/entity/captured_story_media.dart';
import '../utils/enums/story_edit_notice.dart';
import '../utils/story_sticker.dart';
import 'story_edit_state.dart';

/// The edit screen (docs/specs/story/screens/s3-create-edit.md): stickers over the captured media, the
/// mute and save tools, and Share, which hands the story to the background upload.
@injectable
class StoryEditCubit extends BaseCubit<StoryEditState> {
  StoryEditCubit(
    this._uploads,
    this._thumbnails,
    this._blurhash,
    this._gallery,
    GetLastAccountUseCase account,
    @factoryParam CapturedStoryMedia media,
  ) : me = account(),
      super(StoryEditState(media: media));

  /// A photo whose size is unknown is posted as this (the viewer lays it out cover-fit anyway).
  static const fallbackWidth = 1080;
  static const fallbackHeight = 1920;
  static const maxTextLength = 100;

  final StoryUploadRepository _uploads;
  final VideoThumbnailService _thumbnails;
  final BlurhashService _blurhash;
  final GalleryService _gallery;

  /// Who is posting, for the "Your story" pill; null when this device has no saved account.
  final LastAccountEntity? me;

  int _nextId = 0;

  bool get canAddSticker =>
      state.stickers.length < StoryOverlayModel.maxPerStory;

  void addText(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    if (!canAddSticker) {
      emit(state.copyWith(notice: StoryEditNotice.stickerLimit));
      return;
    }
    emit(
      state.copyWith(
        stickers: [...state.stickers, StorySticker.text(_nextId++, clean)],
      ),
    );
  }

  /// New words for a sticker; empty words remove it.
  void updateText(int id, String text) {
    final clean = text.trim();
    if (clean.isEmpty) {
      remove(id);
      return;
    }
    _change(id, (s) => s.copyWith(text: clean));
  }

  void transform(
    int id, {
    double? x,
    double? y,
    double? scale,
    double? rotation,
  }) => _change(
    id,
    (s) => s.copyWith(
      x: x?.clamp(0.0, 1.0),
      y: y?.clamp(0.0, 1.0),
      scale: scale,
      rotation: rotation,
    ),
  );

  void remove(int id) => emit(
    state.copyWith(
      stickers: [
        for (final s in state.stickers)
          if (s.id != id) s,
      ],
    ),
  );

  void toggleMute() => emit(state.copyWith(isMuted: !state.isMuted));

  /// Hands the story to the upload. The screen goes back to Home when [StoryEditState.isShared] turns on.
  Future<void> share() async {
    if (state.isSharing) return;
    emit(state.copyWith(isSharing: true));
    final media = state.media;
    try {
      final isVideo = media.type == StoryMediaType.video;
      final thumb = isVideo ? await _thumbnails.thumbnail(media.path) : null;
      final hashSource = isVideo ? thumb : media.path;
      final blurhash = hashSource == null
          ? null
          : await _blurhash.blurhash(hashSource);
      final started = _uploads.enqueue(
        NewStoryModel(
          filePath: media.path,
          type: media.type,
          thumbFilePath: thumb,
          width: media.width ?? fallbackWidth,
          height: media.height ?? fallbackHeight,
          durationMs: isVideo ? (media.durationMs ?? 0) : null,
          blurhash: blurhash,
          overlays: [for (final s in state.stickers) s.overlay],
        ),
      );
      emit(
        started
            ? state.copyWith(isSharing: false, isShared: true)
            : state.copyWith(
                isSharing: false,
                notice: StoryEditNotice.uploadBusy,
              ),
      );
    } on Failure {
      emit(
        state.copyWith(isSharing: false, notice: StoryEditNotice.shareFailed),
      );
    }
  }

  /// Saves a photo with its stickers drawn on ([bytes] come from the screen's snapshot).
  Future<void> saveImage(Uint8List? bytes) => _saveWith(
    () => bytes == null
        ? throw const UnexpectedFailure()
        : _gallery.saveImage(bytes),
  );

  /// Saves the video as it is: the stickers are not burned in yet.
  // TODO(story-plan T4): video saved without overlays; burn-in later (P4).
  Future<void> saveVideo() =>
      _saveWith(() => _gallery.saveVideoFile(state.media.path));

  Future<void> _saveWith(Future<void> Function() save) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));
    await run(
      save,
      onSuccess: (_) =>
          state.copyWith(isSaving: false, notice: StoryEditNotice.saved),
      onFailure: (_) =>
          state.copyWith(isSaving: false, notice: StoryEditNotice.saveFailed),
    );
  }

  void clearNotice() => emit(state.copyWith(notice: null));

  void _change(int id, StorySticker Function(StorySticker) change) => emit(
    state.copyWith(
      stickers: [for (final s in state.stickers) s.id == id ? change(s) : s],
    ),
  );
}
