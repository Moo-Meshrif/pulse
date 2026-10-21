import 'dart:math';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/services/blurhash_service.dart';
import '../../../../../core/services/gallery_service.dart';
import '../../../../../core/services/video_compress_service.dart';
import '../../../../../core/services/video_overlay_service.dart';
import '../../../../../core/services/video_thumbnail_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/policy/media_policy.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../../data/enums/story_media_type.dart';
import '../../../data/enums/story_overlay_type.dart';
import '../../../data/model/new_story_model.dart';
import '../../../data/model/story_overlay_model.dart';
import '../../../data/repository/story_upload_repository.dart';
import '../../../domain/entity/captured_story_media.dart';
import '../../dimens/story_constants.dart';
import '../../utils/enums/story_edit_notice.dart';
import '../../utils/story_sticker.dart';
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
    this._videoOverlay,
    this._compressor,
    GetLastAccountUseCase account,
    @factoryParam CapturedStoryMedia media,
  ) : me = account(),
      super(
        StoryEditState(
          media: media,
          trimEndMs: min(
            media.durationMs ?? 0,
            StoryTiming.maxVideo.inMilliseconds,
          ),
        ),
      );

  /// A photo whose size is unknown is posted as this (the viewer lays it out cover-fit anyway).
  static const fallbackWidth = 1080;
  static const fallbackHeight = 1920;
  static const maxTextLength = 100;

  /// Frames along a long video in the trim bar.
  static const trimFrameCount = 8;

  final StoryUploadRepository _uploads;
  final VideoThumbnailService _thumbnails;
  final BlurhashService _blurhash;
  final GalleryService _gallery;
  final VideoOverlayService _videoOverlay;
  final VideoCompressService _compressor;

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

  /// Puts the place on the story; a story holds one location card, so a new place replaces the old one.
  void setLocation(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final others = state.stickers
        .where((s) => s.overlay.type != StoryOverlayType.location)
        .toList();
    if (others.length >= StoryOverlayModel.maxPerStory) {
      emit(state.copyWith(notice: StoryEditNotice.stickerLimit));
      return;
    }
    emit(
      state.copyWith(
        stickers: [...others, StorySticker.location(_nextId++, clean)],
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
    state.copyWith(stickers: state.stickers.where((s) => s.id != id).toList()),
  );

  /// Reads the frames of a long video for the trim bar; the bar shows empty tiles until they are here, and
  /// stays so when they cannot be read.
  Future<void> loadTrimFrames() async {
    if (!state.isTrimmable) return;
    final duration = state.media.durationMs ?? 0;
    try {
      final frames = await Future.wait([
        for (var i = 0; i < trimFrameCount; i++)
          _thumbnails.frameAt(
            state.media.path,
            timeMs: duration * i ~/ trimFrameCount,
          ),
      ]);
      if (!isClosed) emit(state.copyWith(trimFrames: frames));
    } on Failure {
      // The bar still works without pictures.
    }
  }

  static final _maxTrimMs = StoryTiming.maxVideo.inMilliseconds;
  static final _minTrimMs = StoryTiming.minTrim.inMilliseconds;

  /// Moves the start of the shared part; it keeps at least a second and at most 60 s.
  void trimStart(int ms) {
    if (!state.isTrimmable) return;
    final end = state.trimEndMs;
    emit(
      state.copyWith(
        trimStartMs: ms.clamp(max(0, end - _maxTrimMs), end - _minTrimMs),
      ),
    );
  }

  /// Moves the end of the shared part; it keeps at least a second and at most 60 s.
  void trimEnd(int ms) {
    if (!state.isTrimmable) return;
    final start = state.trimStartMs;
    final duration = state.media.durationMs ?? 0;
    emit(
      state.copyWith(
        trimEndMs: ms.clamp(
          start + _minTrimMs,
          min(duration, start + _maxTrimMs),
        ),
      ),
    );
  }

  /// Slides the shared part so it starts at [startMs]; its length stays and it stays inside the video.
  void trimMove(int startMs) {
    if (!state.isTrimmable) return;
    final start = startMs.clamp(
      0,
      (state.media.durationMs ?? 0) - state.trimLengthMs,
    );
    emit(
      state.copyWith(trimStartMs: start, trimEndMs: start + state.trimLengthMs),
    );
  }

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
          durationMs: isVideo ? state.trimLengthMs : null,
          edit: isVideo ? _videoEdit() : null,
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

  /// What is done to the video before it goes out; null when it goes as it is.
  VideoEdit? _videoEdit() {
    final isTrimmed = state.isTrimmable;
    if (!state.isMuted && !isTrimmed) return null;
    return VideoEdit(
      removeAudio: state.isMuted,
      trimStartMs: isTrimmed ? state.trimStartMs : null,
      trimEndMs: isTrimmed ? state.trimEndMs : null,
    );
  }

  /// Saves a photo with its stickers drawn on ([bytes] come from the screen's snapshot).
  Future<void> saveImage(Uint8List? bytes) => _saveWith(
    () => bytes == null
        ? throw const UnexpectedFailure()
        : _gallery.saveImage(bytes),
  );

  /// Saves the video as it will be posted: only the shared part and with the sound as chosen. With stickers
  /// on it they are drawn on in the same pass ([overlayPng] comes from the screen's snapshot); without, the
  /// part is cut into a copy. The copy is deleted afterwards. [StoryEditState.saveProgress] tells how far it
  /// is.
  Future<void> saveVideo(Uint8List? overlayPng) => _saveWith(() async {
    if (state.stickers.isNotEmpty && overlayPng == null) {
      throw const UnexpectedFailure();
    }
    final edit = _videoEdit();
    final path = state.stickers.isEmpty
        ? await _cutOrSource(edit)
        : await _videoOverlay.burn(
            state.media.path,
            overlayPng!,
            edit: edit,
            onProgress: _reportSave,
          );
    try {
      await _gallery.saveVideoFile(path);
    } finally {
      if (path != state.media.path) {
        await _discardCopy(path, isCut: state.stickers.isEmpty);
      }
    }
  });

  /// The path to save: a cut copy when there is an edit, else the video itself.
  Future<String> _cutOrSource(VideoEdit? edit) async {
    if (edit == null) return state.media.path;
    final limits = MediaPolicy.videoLimits(ContentKind.story);
    final cut = await _compressor.compress(
      state.media.path,
      maxLongSide: limits.maxLongSide,
      videoBitrate: limits.maxBitrate,
      audioBitrate: MediaPolicy.audioBitrate,
      edit: edit,
      onProgress: _reportSave,
    );
    return cut.path;
  }

  Future<void> _discardCopy(String path, {required bool isCut}) =>
      isCut ? _compressor.delete(path) : _videoOverlay.delete(path);

  void _reportSave(double progress) {
    if (!isClosed) emit(state.copyWith(saveProgress: progress));
  }

  Future<void> _saveWith(Future<void> Function() save) async {
    if (state.isSaving) return;
    // The library is asked for first: the dialog comes on the tap, not after the long work.
    try {
      await _gallery.ensureAccess();
    } on Failure {
      emit(state.copyWith(notice: StoryEditNotice.saveFailed));
      return;
    }
    emit(state.copyWith(isSaving: true, saveProgress: 0));
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
