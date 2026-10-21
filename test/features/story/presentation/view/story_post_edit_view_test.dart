import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/services/blurhash_service.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/core/services/palette_service.dart';
import 'package:pulse/core/utils/story_post_args.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/features/story/data/enums/story_post_sticker_style.dart';
import 'package:pulse/features/story/data/repository/story_upload_repository.dart';
import 'package:pulse/features/story/presentation/cubit/story_post_edit/story_post_edit_cubit.dart';
import 'package:pulse/features/story/presentation/view/story_post_edit_view.dart';
import 'package:pulse/features/story/presentation/widgets/story_post/story_post_sticker.dart';

import '../../../../helpers/pump_app.dart';

class _Uploads extends Mock implements StoryUploadRepository {}

class _Gallery extends Mock implements GalleryService {}

class _Palette extends Mock implements PaletteService {}

class _Account extends Mock implements GetLastAccountUseCase {}

class _NoBlurhash implements BlurhashService {
  @override
  Future<String?> blurhash(String path) async => null;
}

void main() {
  late StoryPostEditCubit cubit;

  setUp(() {
    final account = _Account();
    when(() => account()).thenReturn(null);
    cubit = StoryPostEditCubit(
      _Uploads(),
      _NoBlurhash(),
      _Gallery(),
      _Palette(),
      account,
      const StoryPostArgs(
        postId: 'p1',
        username: 'nour.adel',
        caption: 'Sunset run',
      ),
    );
  });

  tearDown(() => cubit.close());

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    setUpView(tester, size: size, textScale: textScale);
    await tester.pumpApp(
      BlocProvider.value(
        value: cubit,
        child: Scaffold(body: StoryPostEditView(onClose: () {})),
      ),
      locale: locale,
    );
  }

  testWidgets('shows the card, the hint and the three tools', (tester) async {
    await open(tester);

    expect(find.byType(StoryPostSticker), findsOneWidget);
    expect(find.text(l10nEn.storyPostStickerHint), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyToolText), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyToolBackground), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storySaveToDevice), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyToolLocation), findsNothing);
  });

  testWidgets('tapping the sticker changes its style', (tester) async {
    await open(tester);

    await tester.tap(find.byType(StoryPostSticker));
    await tester.pump();

    expect(cubit.state.style, StoryPostStickerStyle.media);
  });

  testWidgets('the palette tool swaps the hint for six swatches', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.bySemanticsLabel(l10nEn.storyToolBackground));
    await tester.pump();

    expect(find.text(l10nEn.storyPostStickerHint), findsNothing);
    await tester.tap(find.bySemanticsLabel(l10nEn.storyBackgroundOption(2)));
    await tester.pump();
    expect(cubit.state.backgroundIndex, 1);
  });

  for (final (name, locale, size, scale) in [
    ('Arabic', const Locale('ar'), const Size(390, 844), 1.0),
    ('1.5x on a small phone', const Locale('en'), const Size(320, 640), 1.5),
  ]) {
    testWidgets('$name draws without overflow', (tester) async {
      await open(tester, locale: locale, size: size, textScale: scale);
      cubit
        ..cycleStyle()
        ..togglePalette();
      await tester.pump();
      cubit.cycleStyle();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }
}
