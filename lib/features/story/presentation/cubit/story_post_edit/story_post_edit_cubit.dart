import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/services/blurhash_service.dart';
import '../../../../../core/services/gallery_service.dart';
import '../../../../../core/services/palette_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/utils/story_post_args.dart';
import '../../../../../core/utils/uuid_v4.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../../data/enums/story_media_type.dart';
import '../../../data/enums/story_post_sticker_style.dart';
import '../../../data/model/new_story_model.dart';
import '../../../data/model/story_overlay_model.dart';
import '../../../data/model/story_post_sticker_model.dart';
import '../../../data/repository/story_upload_repository.dart';
import '../../dimens/story_dimens.dart';
import '../../utils/enums/story_edit_notice.dart';
import '../../utils/story_post_background.dart';
import '../../utils/story_snapshot.dart';
import '../../utils/story_sticker.dart';
import 'story_post_edit_state.dart';

/// The editor of a story that shows a post (docs/specs/post/screens/s13-add-to-story.md): the post as a
/// sticker you drag, size, turn and restyle, a gradient background, and your own text. Share renders the
/// background and the text to a photo and hands it to the background upload with the sticker's data; the
/// viewer draws the sticker live, so a deleted post shows as unavailable.
@injectable
class StoryPostEditCubit extends BaseCubit<StoryPostEditState> {
  StoryPostEditCubit(
    this._uploads,
    this._blurhash,
    this._gallery,
    this._palette,
    GetLastAccountUseCase account,
    @factoryParam StoryPostArgs post,
  ) : me = account(),
      super(
        StoryPostEditState(
          post: post,
          backgrounds: StoryPostBackground.options(),
        ),
      );

  final StoryUploadRepository _uploads;
  final BlurhashService _blurhash;
  final GalleryService _gallery;
  final PaletteService _palette;

  /// Who is posting, for the "Your story" pill; null when this device has no saved account.
  final LastAccountEntity? me;

  int _nextId = 0;

  bool get canAddSticker =>
      state.stickers.length < StoryOverlayModel.maxPerStory;

  /// Reads the post's picture for the colors of the first background; without a picture or colors that
  /// background stays the primary gradient.
  Future<void> loadMediaColors() async {
    final url = state.post.mediaUrl;
    if (url == null) return;
    final colors = await _palette.dominantColors(url);
    if (colors.isEmpty) return;
    emit(
      state.copyWith(
        backgrounds: StoryPostBackground.options(fromPost: colors),
      ),
    );
  }

  /// Card, then media only, then compact, then card again.
  void cycleStyle() {
    const styles = StoryPostStickerStyle.values;
    emit(
      state.copyWith(
        style: styles[(styles.indexOf(state.style) + 1) % styles.length],
      ),
    );
  }

  /// Moves, sizes or turns the post sticker; it stays on the screen and between half and double size.
  void transformPost({double? x, double? y, double? scale, double? rotation}) =>
      emit(
        state.copyWith(
          x: x?.clamp(0.0, 1.0) ?? state.x,
          y: y?.clamp(0.0, 1.0) ?? state.y,
          scale:
              scale?.clamp(
                StoryPostDimens.minScale,
                StoryPostDimens.maxScale,
              ) ??
              state.scale,
          rotation: rotation ?? state.rotation,
        ),
      );

  void chooseBackground(int index) {
    if (index < 0 || index >= state.backgrounds.length) return;
    emit(state.copyWith(backgroundIndex: index));
  }

  void togglePalette() =>
      emit(state.copyWith(isPaletteOpen: !state.isPaletteOpen));

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

  /// New words for a text; empty words remove it.
  void updateText(int id, String text) {
    final clean = text.trim();
    if (clean.isEmpty) {
      remove(id);
      return;
    }
    _change(id, (s) => s.copyWith(text: clean));
  }

  void transformText(
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

  /// Hands the story to the upload with [image], the background and text drawn by the screen (null when it
  /// could not be drawn). The screen goes back to Home when [StoryPostEditState.isShared] turns on.
  Future<void> share(StoryImage? image) async {
    if (state.isSharing) return;
    if (image == null) {
      emit(state.copyWith(notice: StoryEditNotice.shareFailed));
      return;
    }
    emit(state.copyWith(isSharing: true));
    await run(
      () => _enqueue(image),
      onSuccess: (started) => state.copyWith(
        isSharing: false,
        isShared: started,
        notice: started ? null : StoryEditNotice.uploadBusy,
      ),
      onFailure: (_) =>
          state.copyWith(isSharing: false, notice: StoryEditNotice.shareFailed),
    );
  }

  /// Saves the background and text as a photo ([bytes] come from the screen's snapshot).
  Future<void> saveImage(Uint8List? bytes) async {
    if (state.isSaving) return;
    try {
      await _gallery.ensureAccess();
    } on Failure {
      emit(state.copyWith(notice: StoryEditNotice.saveFailed));
      return;
    }
    emit(state.copyWith(isSaving: true));
    await run(
      () => bytes == null
          ? throw const UnexpectedFailure()
          : _gallery.saveImage(bytes),
      onSuccess: (_) =>
          state.copyWith(isSaving: false, notice: StoryEditNotice.saved),
      onFailure: (_) =>
          state.copyWith(isSaving: false, notice: StoryEditNotice.saveFailed),
    );
  }

  void clearNotice() => emit(state.copyWith(notice: null));

  /// False when another story is still going out.
  Future<bool> _enqueue(StoryImage image) async {
    final file = File('${Directory.systemTemp.path}/story_${uuidV4()}.png');
    await file.writeAsBytes(image.bytes);
    final blurhash = await _blurhash.blurhash(file.path);
    final background = state.backgrounds[state.backgroundIndex];
    return _uploads.enqueue(
      NewStoryModel(
        filePath: file.path,
        type: StoryMediaType.image,
        width: image.width,
        height: image.height,
        blurhash: blurhash,
        overlays: [for (final s in state.stickers) s.overlay],
        sharedPostId: state.post.postId,
        sticker: StoryPostStickerModel(
          style: state.style,
          x: state.x,
          y: state.y,
          scale: state.scale,
          rotation: state.rotation,
          backgroundKind: background.kind,
          backgroundColors: background.hex,
        ),
      ),
    );
  }

  void _change(int id, StorySticker Function(StorySticker) change) => emit(
    state.copyWith(
      stickers: [for (final s in state.stickers) s.id == id ? change(s) : s],
    ),
  );
}
