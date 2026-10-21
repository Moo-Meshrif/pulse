import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/data/model/post_tag_model.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/domain/use_case/share_to_feed_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/use_case/check_content_changes_use_case.dart';

class _MockPosts extends Mock implements PostsDatasource {}

class _MockCheck extends Mock implements CheckContentChangesUseCase {}

class _MockPublish extends Mock implements ContentPublishRepository {}

void main() {
  late _MockPosts posts;
  late _MockPublish publish;
  late _MockCheck check;
  late ShareToFeedUseCase useCase;
  late PublishWork work;

  setUpAll(() => registerFallbackValue(ContentKind.post));

  setUp(() {
    posts = _MockPosts();
    publish = _MockPublish();
    check = _MockCheck();
    when(() => check(any())).thenAnswer((_) async {});
    useCase = ShareToFeedUseCase(posts, publish, check);
    when(
      () => publish.enqueue(
        kind: any(named: 'kind'),
        send: any(named: 'send'),
      ),
    ).thenAnswer((call) {
      work = call.namedArguments[#send] as PublishWork;
      return true;
    });
  });

  void answer() => when(
    () => posts.shareToFeed(
      postId: any(named: 'postId'),
      caption: any(named: 'caption'),
      audience: any(named: 'audience'),
      moodKind: any(named: 'moodKind'),
      moodKey: any(named: 'moodKey'),
      moodText: any(named: 'moodText'),
      location: any(named: 'location'),
      tags: any(named: 'tags'),
    ),
  ).thenAnswer((_) async => 'new-1');

  test('goes out in the post line, and false means the line is full', () {
    expect(useCase('o1'), isTrue);
    verify(
      () => publish.enqueue(
        kind: ContentKind.post,
        send: any(named: 'send'),
      ),
    ).called(1);

    when(
      () => publish.enqueue(
        kind: any(named: 'kind'),
        send: any(named: 'send'),
      ),
    ).thenReturn(false);
    expect(useCase('o1'), isFalse);
  });

  test(
    'sends the words, feeling, place and tags without a photo spot',
    () async {
      answer();

      useCase(
        'o1',
        caption: 'Look',
        audience: ContentAudience.followers,
        mood: const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
        location: 'Cairo',
        tags: const [
          PostTagEntity(userId: 'u2', mediaPosition: 1, x: 0.5, y: 0.5),
        ],
      );
      await work((_) {});

      verify(
        () => posts.shareToFeed(
          postId: 'o1',
          caption: 'Look',
          audience: ContentAudience.followers,
          moodKind: MoodKind.feeling,
          moodKey: 'happy',
          moodText: null,
          location: 'Cairo',
          tags: const [PostTagModel(userId: 'u2')],
        ),
      ).called(1);
    },
  );

  test('runs the change check once the share exists', () async {
    answer();

    useCase('o1');
    await work((_) {});

    verify(() => check(ContentKind.post)).called(1);
  });

  test('a failed share runs no check and passes the failure on', () async {
    when(
      () => posts.shareToFeed(
        postId: any(named: 'postId'),
        caption: any(named: 'caption'),
        audience: any(named: 'audience'),
        moodKind: any(named: 'moodKind'),
        moodKey: any(named: 'moodKey'),
        moodText: any(named: 'moodText'),
        location: any(named: 'location'),
        tags: any(named: 'tags'),
      ),
    ).thenThrow(StateError('offline'));

    useCase('o1');
    await expectLater(work((_) {}), throwsStateError);

    verifyNever(() => check(any()));
  });
}
