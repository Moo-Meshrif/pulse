import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/data/enums/follow_state.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/domain/entity/tag_person_entity.dart';
import 'package:pulse/features/post/domain/entity/tagged_person_entity.dart';
import 'package:pulse/features/post/presentation/cubit/tag_in_photo/tag_in_photo_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/tag_people/tag_people_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/tagged_people/tagged_people_cubit.dart';
import 'package:pulse/features/post/presentation/screen/feeling_screen.dart';
import 'package:pulse/features/post/presentation/screen/tag_in_photo_screen.dart';
import 'package:pulse/features/post/presentation/screen/tag_people_screen.dart';
import 'package:pulse/features/post/presentation/utils/post_card_callbacks.dart';
import 'package:pulse/features/post/presentation/utils/post_card_data.dart';
import 'package:pulse/features/post/presentation/utils/post_card_media.dart';
import 'package:pulse/features/post/presentation/utils/post_tag_removal.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/post/presentation/utils/tag_people_args.dart';
import 'package:pulse/features/post/presentation/utils/tag_photo.dart';
import 'package:pulse/features/post/presentation/widgets/media/post_tag_badge.dart';
import 'package:pulse/features/post/presentation/widgets/post_card.dart';
import 'package:pulse/features/post/presentation/widgets/post_video_scope.dart';
import 'package:pulse/features/post/presentation/widgets/tagged_people/tagged_people_sheet.dart';

import '../../../helpers/pump_app.dart';
import '../post_doubles.dart';

class _Follow extends Mock implements ToggleFollowUseCase {}

/// The tag and feeling screens, the tagged people sheet, the remove dialog and the new card states at the
/// sizes the design names: a 320 dp phone at twice the text, the design phone at 1.5x, and a wide window,
/// in English and Arabic. None may overflow.
void main() {
  const people = [
    TagPersonEntity(
      id: 'u1',
      username: 'omar.khaled.long.username',
      fullName: 'Omar Khaled Abdelrahman Mohamed',
      canTag: true,
    ),
    TagPersonEntity(
      id: 'u2',
      username: 'sam',
      fullName: 'Sam Private',
      canTag: false,
    ),
  ];
  const chosen = [
    TagChoice(
      id: 'u1',
      username: 'omar.khaled.long.username',
      fullName: 'Omar Khaled Abdelrahman Mohamed',
      mediaPosition: 0,
      x: 0.9,
      y: 0.05,
    ),
    TagChoice(id: 'u3', username: 'laila', fullName: 'Laila Fouad'),
  ];
  const photos = [
    TagPhoto(position: 0, isVideo: false, aspect: 1.5),
    TagPhoto(position: 1, isVideo: false, aspect: 0.8),
  ];
  const args = TagPeopleArgs(chosen: chosen, photos: photos);

  final variants = <(String, Locale, Size, double)>[
    for (final locale in const [Locale('en'), Locale('ar')]) ...[
      ('320 dp at 2.0x', locale, const Size(320, 640), 2.0),
      ('390 dp at 1.5x', locale, const Size(390, 844), 1.5),
      ('wide window', locale, const Size(1200, 800), 1.0),
    ],
  ];

  setUp(() async {
    await getIt.reset();
    final posts = MockPostRepository();
    when(() => posts.searchTagPeople(any())).thenAnswer((_) async => people);
    when(() => posts.taggedPeople(any())).thenAnswer(
      (_) async => const [
        TaggedPersonEntity(
          id: 'me',
          username: 'me',
          fullName: 'Mona Abdelrahman Mohamed',
          followState: FollowState.me,
        ),
        TaggedPersonEntity(
          id: 'u2',
          username: 'omar.khaled.long.username',
          fullName: 'Omar Khaled Abdelrahman Mohamed',
          followState: FollowState.pending,
        ),
      ],
    );
    getIt
      ..registerFactoryParam<TagPeopleCubit, TagPeopleArgs, void>(
        (a, _) => TagPeopleCubit(posts, a),
      )
      ..registerFactoryParam<TagInPhotoCubit, TagPeopleArgs, void>(
        (a, _) => TagInPhotoCubit(a),
      )
      ..registerFactoryParam<TaggedPeopleCubit, String, void>(
        (id, _) => TaggedPeopleCubit(posts, _Follow(), id),
      );
    addTearDown(getIt.reset);
  });

  for (final (name, locale, size, scale) in variants) {
    final label = '${locale.languageCode} $name';

    Future<void> show(WidgetTester tester, Widget child) async {
      setUpView(tester, size: size, textScale: scale);
      await tester.pumpApp(child, locale: locale);
      await tester.pumpAndSettle();
    }

    testWidgets('Tag people: $label', (tester) async {
      await show(tester, const TagPeopleScreen(args: args));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tag in photo: $label', (tester) async {
      await show(tester, const TagInPhotoScreen(args: args));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Feeling: $label', (tester) async {
      await show(
        tester,
        const FeelingScreen(
          current: PostMoodEntity(kind: MoodKind.feeling, key: 'determined'),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tagged people sheet: $label', (tester) async {
      await show(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => TaggedPeopleSheet.show(context, postId: 'p1'),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Omar Khaled Abdelrahman Mohamed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Remove your tag dialog: $label', (tester) async {
      await show(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => PostTagRemoval.confirmAndRemove(
                context,
                ownerName: 'omar.khaled.long.username',
                remove: () async {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('the card with a feeling, tags and comments off: $label', (
      tester,
    ) async {
      await show(
        tester,
        PostVideoScope(
          child: ListView(
            children: [
              PostCard(
                data: PostCardData(
                  id: 'p1',
                  authorId: 'a1',
                  authorName: 'Dipprokash Sardar Abdelrahman',
                  city: 'Saint Catherine, South Sinai, Egypt',
                  createdAt: DateTime(2026, 10, 14),
                  caption: 'Sunset run',
                  media: const [
                    PostCardMedia(
                      isVideo: false,
                      url: 'https://x.test/p.jpg',
                      cacheKey: 'p',
                      width: 1000,
                      height: 800,
                    ),
                  ],
                  audienceIcon: 'assets/icons/ic_lock.svg',
                  commentsEnabled: false,
                  mood: const PostMoodEntity(
                    kind: MoodKind.feeling,
                    key: 'determined',
                  ),
                  tags: const [
                    PostTagEntity(
                      userId: 'u1',
                      username: 'omar',
                      fullName: 'Omar Khaled Abdelrahman Mohamed',
                      mediaPosition: 0,
                      x: 0.95,
                      y: 0.02,
                    ),
                  ],
                  tagCount: 5,
                ),
                callbacks: const PostCardCallbacks(),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(PostTagBadge));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
