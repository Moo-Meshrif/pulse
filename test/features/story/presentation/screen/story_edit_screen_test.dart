import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/services/blurhash_service.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/core/services/video_compress_service.dart';
import 'package:pulse/core/services/video_overlay_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/model/new_story_model.dart';
import 'package:pulse/features/story/data/repository/story_upload_repository.dart';
import 'package:pulse/features/story/domain/entity/captured_story_media.dart';
import 'package:pulse/features/story/presentation/cubit/story_edit/story_edit_cubit.dart';
import 'package:pulse/features/story/presentation/screen/story_edit_screen.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../../../../helpers/fake_video_player_platform.dart';
import '../../../../helpers/pump_app.dart';

class _Uploads extends Mock implements StoryUploadRepository {}

class _NoBlurhash implements BlurhashService {
  @override
  Future<String?> blurhash(String path) async => null;
}

class _Thumbs extends Mock implements VideoThumbnailService {}

class _Gallery extends Mock implements GalleryService {}

class _Compressor extends Mock implements VideoCompressService {}

class _VideoOverlay extends Fake implements VideoOverlayService {}

class _Account extends Mock implements GetLastAccountUseCase {}

const _photo = CapturedStoryMedia(
  path: '/nowhere/p.jpg',
  type: StoryMediaType.image,
  width: 1080,
  height: 1920,
);
const _video = CapturedStoryMedia(
  path: '/nowhere/v.mp4',
  type: StoryMediaType.video,
  durationMs: 9000,
);

void main() {
  late _Uploads uploads;
  late _Gallery gallery;
  var started = true;

  setUpAll(() {
    registerFallbackValue(
      NewStoryModel(
        filePath: '',
        type: StoryMediaType.image,
        width: 1,
        height: 1,
      ),
    );
  });

  setUp(() async {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
    started = true;
    uploads = _Uploads();
    gallery = _Gallery();
    final account = _Account();
    when(() => account()).thenReturn(null);
    when(() => uploads.enqueue(any())).thenAnswer((_) => started);
    when(gallery.ensureAccess).thenAnswer((_) async {});
    when(() => gallery.saveVideoFile(any())).thenAnswer((_) async {});
    await getIt.reset();
    getIt.registerFactoryParam<StoryEditCubit, CapturedStoryMedia, void>(
      (media, _) => StoryEditCubit(
        uploads,
        _Thumbs(),
        _NoBlurhash(),
        gallery,
        _VideoOverlay(),
        _Compressor(),
        account,
        media,
      ),
    );
  });

  tearDown(getIt.reset);

  Future<void> open(
    WidgetTester tester, {
    CapturedStoryMedia media = _photo,
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      Navigator(
        initialRoute: AppRoutes.home,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => settings.name == AppRoutes.home
              ? Builder(
                  builder: (context) {
                    return Scaffold(
                      body: TextButton(
                        onPressed: () => Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            settings: const RouteSettings(name: '/edit'),
                            builder: (_) => StoryEditScreen(media: media),
                          ),
                        ),
                        child: const Text('open'),
                      ),
                    );
                  },
                )
              : const SizedBox(),
        ),
      ),
      locale: locale,
      settle: false,
    );
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> addText(WidgetTester tester, String text) async {
    await tester.tap(find.bySemanticsLabel(l10nEn.storyToolText));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.text(l10nEn.storyTextDone));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('photo: close, text and save tools, pill and Share; no mute', (
    tester,
  ) async {
    await open(tester);
    expect(find.bySemanticsLabel(l10nEn.close), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyToolText), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storySaveToDevice), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyToolMute), findsNothing);
    expect(find.text(l10nEn.storyYourStoryPill), findsOneWidget);
    expect(find.text(l10nEn.storyShare), findsOneWidget);
    // The tools are 44 circles.
    final tool = tester.getSize(find.bySemanticsLabel(l10nEn.storyToolText));
    expect(tool.width, greaterThanOrEqualTo(44));
  });

  testWidgets('video: the mute tool toggles its label', (tester) async {
    await open(tester, media: _video);
    await tester.tap(find.bySemanticsLabel(l10nEn.storyToolMute));
    await tester.pump();
    expect(find.bySemanticsLabel(l10nEn.storyToolUnmute), findsOneWidget);
  });

  testWidgets('Text opens the editor; Done puts the sticker on the frame', (
    tester,
  ) async {
    await open(tester);
    await addText(tester, 'Golden hour');
    expect(find.text('Golden hour'), findsOneWidget);
  });

  testWidgets('dragging a sticker moves it', (tester) async {
    await open(tester);
    await addText(tester, 'Move me');
    final before = tester.getCenter(find.text('Move me'));
    await tester.drag(find.text('Move me'), const Offset(60, 120));
    await tester.pump();
    final after = tester.getCenter(find.text('Move me'));
    // The first part of a drag is the touch slop: the sticker follows the rest.
    expect(after.dx - before.dx, greaterThan(30));
    expect(after.dy - before.dy, greaterThan(50));
  });

  testWidgets('dropping a sticker on the trash removes it', (tester) async {
    await open(tester);
    await addText(tester, 'Bye');
    final trash = Offset(
      195,
      844 -
          34 -
          30 -
          52 -
          16 -
          24, // bottom inset, action bottom, pills, gap, half zone
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Bye')),
    );
    await gesture.moveTo(trash);
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(find.text('Bye'), findsNothing);
  });

  testWidgets('tapping a sticker retypes it', (tester) async {
    await open(tester);
    await addText(tester, 'One');
    await tester.tap(find.text('One'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'Two');
    await tester.tap(find.text(l10nEn.storyTextDone));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('One'), findsNothing);
  });

  testWidgets('Share starts the upload with the stickers and goes Home', (
    tester,
  ) async {
    await open(tester);
    await addText(tester, 'Hello');
    await tester.tap(find.text(l10nEn.storyShare));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final story =
        verify(() => uploads.enqueue(captureAny())).captured.single
            as NewStoryModel;
    expect(story.overlays.single.text, 'Hello');
    expect(find.text('open'), findsOneWidget); // back on the home route
  });

  testWidgets('Share while another story posts shows a notice and stays', (
    tester,
  ) async {
    started = false;
    await open(tester);
    await tester.tap(find.text(l10nEn.storyShare));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10nEn.storyUploadBusy), findsOneWidget);
    expect(find.text(l10nEn.storyShare), findsOneWidget);
  });

  testWidgets('X asks before discarding; Keep editing stays', (tester) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10nEn.storyDiscardTitle), findsOneWidget);

    await tester.tap(find.text(l10nEn.storyKeepEditing));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10nEn.storyShare), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(l10nEn.storyDiscard));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('Arabic: strings are Arabic, tools sit at the left edge', (
    tester,
  ) async {
    await open(tester, locale: const Locale('ar'));
    expect(find.text(l10nAr.storyShare), findsOneWidget);
    expect(
      tester.getCenter(find.bySemanticsLabel(l10nAr.storyToolText)).dx,
      lessThan(195),
    );
    expect(
      tester.getCenter(find.bySemanticsLabel(l10nAr.close)).dx,
      greaterThan(195),
    );
  });

  testWidgets('1.5x text: no overflow', (tester) async {
    await open(tester, media: _video, textScale: 1.5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every control is at least 44 x 44, in English and Arabic', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await open(tester, media: _video, locale: locale);
      final l10n = locale.languageCode == 'ar' ? l10nAr : l10nEn;
      for (final label in [
        l10n.close,
        l10n.storyToolText,
        l10n.storyToolMute,
        l10n.storySaveToDevice,
        l10n.storyShare,
      ]) {
        final size = tester.getSize(find.bySemanticsLabel(label));
        expect(size.width, greaterThanOrEqualTo(44), reason: label);
        expect(size.height, greaterThanOrEqualTo(44), reason: label);
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
}
