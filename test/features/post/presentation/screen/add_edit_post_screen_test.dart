import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/core/theme/app_breakpoints.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/use_case/create_post_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/domain/use_case/update_post_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/add_edit_post_cubit.dart';
import 'package:pulse/features/post/presentation/screen/add_edit_post_screen.dart';
import 'package:pulse/features/post/presentation/utils/new_post_limits.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/post/presentation/view/add_edit_post_view.dart';
import 'package:pulse/features/post/presentation/widgets/add_edit_post/add_media_tile.dart';
import 'package:pulse/features/profile/domain/entity/last_account_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/publish_content_use_case.dart';

import '../../../../helpers/pump_app.dart';

class _CreatePost extends Mock implements CreatePostUseCase {}

class _UpdatePost extends Mock implements UpdatePostUseCase {}

class _SignUrls extends Mock implements SignPostMediaUrlsUseCase {}

class _Picker extends Mock implements MediaPickerService {}

class _Privacy extends Mock implements GetPrivacyUseCase {}

class _Thumbnails extends Mock implements VideoThumbnailService {}

class _Account extends Mock implements GetLastAccountUseCase {}

void main() {
  late _CreatePost createPost;
  late _Picker picker;
  late _Account account;

  setUpAll(() {
    registerFallbackValue(const PickedMedia(path: '/x', isVideo: false));
    registerFallbackValue(
      const NewPostEntity(
        id: 'x',
        commentsEnabled: true,
        visibility: ContentAudience.public,
        media: [],
      ),
    );
  });

  setUp(() async {
    await getIt.reset();
    createPost = _CreatePost();
    final bus = EventBus();
    picker = _Picker();
    final privacy = _Privacy();
    account = _Account();
    when(account.call).thenReturn(null);
    when(privacy.call).thenAnswer(
      (_) async => const PrivacyEntity(
        isPrivate: false,
        defaultVisibility: ContentAudience.public,
      ),
    );
    when(() => createPost(any(), onProgress: any(named: 'onProgress')))
        .thenAnswer((_) async => null);
    getIt.registerFactoryParam<AddEditPostCubit, PostEntity?, dynamic>(
      (post, _) => AddEditPostCubit(
        createPost,
        _UpdatePost(),
        PublishContentUseCase(ContentPublishRepositoryImpl(bus)),
        bus,
        _SignUrls(),
        picker,
        privacy,
        _Thumbnails(),
        account,
        post,
        {},
      ),
    );
  });

  tearDown(getIt.reset);

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double textScale = 1,
    Size size = const Size(390, 844),
  }) async {
    setUpView(tester, textScale: textScale, size: size);
    await tester.pumpApp(const AddEditPostScreen(), locale: locale);
  }

  Finder shareButton() => find.byType(FilledButton);

  bool shareEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(shareButton()).onPressed != null;

  testWidgets('Share is disabled when empty and enabled with text', (
    tester,
  ) async {
    await open(tester);
    expect(find.text(l10nEn.newPostTitle), findsOneWidget);
    expect(find.text(l10nEn.newPostShare), findsOneWidget);
    expect(shareEnabled(tester), isFalse);

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    expect(shareEnabled(tester), isTrue);
  });

  testWidgets('the counter turns danger at 2000', (tester) async {
    await open(tester);
    expect(find.text('0/2000'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'a' * (NewPostLimits.maxCaption + 50),
    );
    await tester.pump();
    final counter = tester.widget<Text>(find.text('2000/2000'));
    expect(counter.style?.color, const Color(0xFFC42B34));
  });

  testWidgets('the Add tile disappears at 10 photos', (tester) async {
    when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
      (_) async => [
        for (var i = 0; i < NewPostLimits.maxMedia; i++)
          PickedMedia(path: '/missing_$i.jpg', isVideo: false),
      ],
    );
    when(() => picker.describe(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as PickedMedia,
    );
    await open(tester);
    expect(find.byType(AddMediaTile), findsOneWidget);

    await tester.tap(find.text(l10nEn.newPostPhotoVideo));
    await tester.pumpAndSettle();
    expect(find.byType(AddMediaTile), findsNothing);
    expect(find.text(l10nEn.newPostAdded(10)), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.newPostRemoveMedia(1)), findsOneWidget);
  });

  group('the headline preview and the feeling row', () {
    const me = LastAccountEntity(id: 'me', username: 'nour', fullName: 'Nour');

    AddEditPostCubit cubitOf(WidgetTester tester) =>
        tester.element(find.byType(AddEditPostView)).read<AddEditPostCubit>();

    Finder rich(String text) => find.textContaining(text, findRichText: true);

    testWidgets('the card says You alone, then what is chosen', (tester) async {
      when(account.call).thenReturn(me);
      await open(tester);
      expect(rich(l10nEn.postHeadlineYou), findsOneWidget);
      expect(rich('feeling'), findsNothing);

      final cubit = cubitOf(tester);
      cubit
        ..moodChanged(
          const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
        )
        ..tagsChanged([
          const TagChoice(id: 'u2', username: 'om', fullName: 'Om'),
        ])
        ..locationChanged('Cairo');
      await tester.pumpAndSettle();

      expect(rich('You is feeling 😊happy with Om'), findsOneWidget);
      expect(find.text('Cairo'), findsNWidgets(2)); // the preview and the row
    });

    testWidgets('the Feeling row shows the value in the primary colour', (
      tester,
    ) async {
      await open(tester);
      expect(find.text(l10nEn.postFeelingValue('😊', 'happy')), findsNothing);

      cubitOf(
        tester,
      ).moodChanged(const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'));
      await tester.pumpAndSettle();

      final value = find.text(
        l10nEn.postFeelingValue('😊', l10nEn.postFeelingHappy),
      );
      expect(value, findsOneWidget);
      expect(tester.widget<Text>(value).style?.color, const Color(0xFF2E6B63));
    });

    testWidgets('Arabic shows the noun with the emoji', (tester) async {
      await open(tester, locale: const Locale('ar'));

      cubitOf(
        tester,
      ).moodChanged(const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10nAr.postFeelingValue('😊', l10nAr.postFeelingHappy)),
        findsOneWidget,
      );
    });
  });

  testWidgets('the comments switch starts on and toggles', (tester) async {
    await open(tester);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    await tester.tap(find.text(l10nEn.newPostAllowComments));
    await tester.pump();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('closing an empty post leaves without asking', (tester) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.newPostDiscardTitle), findsNothing);
  });

  testWidgets('closing with text asks; Keep editing stays', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.newPostDiscardTitle), findsOneWidget);

    await tester.tap(find.text(l10nEn.newPostKeepEditing));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.newPostDiscardTitle), findsNothing);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('Share hands the post over without waiting', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await tester.tap(shareButton());
    await tester.pump();

    verify(() => createPost(any(), onProgress: any(named: 'onProgress')))
        .called(1);
  });

  testWidgets('Arabic at 1.5x text does not overflow', (tester) async {
    await open(tester, locale: const Locale('ar'), textScale: 1.5);
    expect(find.text(l10nAr.newPostTitle), findsOneWidget);
    expect(find.text(l10nAr.newPostShare), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a 320 dp phone at 2.0x text, EN and AR, does not overflow', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await tester.pumpWidget(const SizedBox());
      await open(
        tester,
        locale: locale,
        textScale: 2,
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull, reason: locale.languageCode);
    }
  });

  testWidgets('on a wide window the composer keeps the content width', (
    tester,
  ) async {
    await open(tester, size: const Size(1200, 800));
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(TextField)).width,
      lessThanOrEqualTo(AppBreakpoints.maxContentWidth),
    );
  });
}
