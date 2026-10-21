import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/services/blurhash_service.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/core/services/palette_service.dart';
import 'package:pulse/core/utils/story_post_args.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/enums/story_post_sticker_style.dart';
import 'package:pulse/features/story/data/model/new_story_model.dart';
import 'package:pulse/features/story/data/repository/story_upload_repository.dart';
import 'package:pulse/features/story/presentation/cubit/story_post_edit/story_post_edit_cubit.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_edit_notice.dart';
import 'package:pulse/features/story/presentation/utils/story_post_background.dart';

class _Uploads extends Mock implements StoryUploadRepository {}

class _Gallery extends Mock implements GalleryService {}

class _Palette extends Mock implements PaletteService {}

class _Account extends Mock implements GetLastAccountUseCase {}

class _NoBlurhash implements BlurhashService {
  @override
  Future<String?> blurhash(String path) async => null;
}

const _post = StoryPostArgs(
  postId: 'p1',
  username: 'nour.adel',
  mediaUrl: 'https://x/p.jpg',
);

void main() {
  late _Uploads uploads;
  late _Gallery gallery;
  late _Palette palette;
  late _Account account;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(
      NewStoryModel(
        filePath: '',
        type: StoryMediaType.image,
        width: 1,
        height: 1,
      ),
    );
  });

  setUp(() {
    uploads = _Uploads();
    gallery = _Gallery();
    palette = _Palette();
    account = _Account();
    when(() => account()).thenReturn(null);
    when(() => uploads.enqueue(any())).thenReturn(true);
    when(gallery.ensureAccess).thenAnswer((_) async {});
    when(() => gallery.saveImage(any())).thenAnswer((_) async {});
    when(() => palette.dominantColors(any()))
        .thenAnswer((_) async => const [Color(0xFFF0A070), Color(0xFF503060)]);
  });

  StoryPostEditCubit build({StoryPostArgs post = _post}) => StoryPostEditCubit(
    uploads,
    _NoBlurhash(),
    gallery,
    palette,
    account,
    post,
  );

  final image = (bytes: Uint8List.fromList([1, 2, 3]), width: 390, height: 844);

  test('starts as a card, tilted, with the post in the upper middle', () {
    final state = build().state;
    expect(state.style, StoryPostStickerStyle.card);
    expect(state.rotation, -2);
    expect(state.x, 0.5);
    expect(state.backgroundIndex, 0);
    expect(state.backgrounds, hasLength(6));
  });

  test('a tap goes card, media, compact, then card again', () {
    final cubit = build();
    final seen = <StoryPostStickerStyle>[];
    for (var i = 0; i < 4; i++) {
      cubit.cycleStyle();
      seen.add(cubit.state.style);
    }
    expect(seen, [
      StoryPostStickerStyle.media,
      StoryPostStickerStyle.compact,
      StoryPostStickerStyle.card,
      StoryPostStickerStyle.media,
    ]);
  });

  test('size stays between half and double, and the post stays on screen', () {
    final cubit = build()..transformPost(scale: 5, x: 1.4, y: -0.2);
    expect(cubit.state.scale, 2);
    expect(cubit.state.x, 1);
    expect(cubit.state.y, 0);
    cubit.transformPost(scale: 0.1);
    expect(cubit.state.scale, 0.5);
  });

  test(
    'the first background takes the post picture colors once read',
    () async {
      final cubit = build();
      await cubit.loadMediaColors();
      expect(cubit.state.backgrounds.first.kind, StoryPostBackground.media);
      expect(cubit.state.backgrounds.first.colors, [
        const Color(0xFFF0A070),
        const Color(0xFF503060),
      ]);
    },
  );

  test(
    'without readable colors the first background is the primary gradient',
    () async {
      when(() => palette.dominantColors(any()))
          .thenAnswer((_) async => const []);
      final cubit = build();
      final before = cubit.state.backgrounds;
      await cubit.loadMediaColors();
      expect(cubit.state.backgrounds, before);
      expect(cubit.state.backgrounds.first.colors, before[2].colors);
    },
  );

  test('a post without a picture reads no colors', () async {
    final cubit = build(
      post: const StoryPostArgs(postId: 'p', username: 'a'),
    );
    await cubit.loadMediaColors();
    verifyNever(() => palette.dominantColors(any()));
  });

  test(
    'share sends the sticker, its post and the text over the chosen background',
    () async {
      final cubit = build()
        ..addText('Hello')
        ..chooseBackground(1)
        ..cycleStyle();
      await cubit.share(image);

      final story =
          verify(() => uploads.enqueue(captureAny())).captured.single
              as NewStoryModel;
      expect(story.sharedPostId, 'p1');
      expect(story.sticker?.style, StoryPostStickerStyle.media);
      expect(story.sticker?.backgroundKind, StoryPostBackground.dark);
      expect(story.overlays, hasLength(1));
      expect(story.width, 390);
      expect(cubit.state.isShared, isTrue);
    },
  );

  test('share without a picture fails with a notice', () async {
    final cubit = build();
    await cubit.share(null);
    expect(cubit.state.notice, StoryEditNotice.shareFailed);
    verifyNever(() => uploads.enqueue(any()));
  });

  test('share while another story goes out says so and stays', () async {
    when(() => uploads.enqueue(any())).thenReturn(false);
    final cubit = build();
    await cubit.share(image);
    expect(cubit.state.notice, StoryEditNotice.uploadBusy);
    expect(cubit.state.isShared, isFalse);
    expect(cubit.state.isSharing, isFalse);
  });

  test('save puts the picture in the gallery', () async {
    final cubit = build();
    await cubit.saveImage(image.bytes);
    expect(cubit.state.notice, StoryEditNotice.saved);
    verify(() => gallery.saveImage(image.bytes)).called(1);
  });
}
