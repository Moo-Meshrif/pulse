import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/presentation/cubit/post_actions/post_actions_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/post_row.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';
import 'package:pulse/shared/content/data/model/post_count_model.dart';
import 'package:pulse/shared/content/domain/event/content_delete_event.dart';

import '../../../../../helpers/content_mocks.dart';
import '../../../../../helpers/failure_of.dart';
import '../../../post_doubles.dart';
import '../../../post_fixtures.dart';

class _Follow extends Mock implements ToggleFollowUseCase {}

void main() {
  late MockReportContent report;
  late MockSetMute mute;
  late _Follow follow;
  late MockPostRepository posts;
  late PostActionsCubit cubit;

  final post = testPost('p1', authorId: 'a1');

  setUpAll(registerContentFallbacks);

  setUp(() {
    posts = MockPostRepository();
    report = MockReportContent();
    mute = MockSetMute();
    follow = _Follow();
    when(() => posts.hidePost(any(), hidden: any(named: 'hidden')))
        .thenAnswer((_) async {});
    when(() => posts.setCommentsEnabled(any(), enabled: any(named: 'enabled')))
        .thenAnswer((_) async {});
    when(() => posts.deletePost(any())).thenAnswer((_) async {});
    when(() => report(any(), any(), any(), note: any(named: 'note')))
        .thenAnswer((_) async {});
    when(
      () => mute(
        any(),
        muted: any(named: 'muted'),
        scope: any(named: 'scope'),
      ),
    ).thenAnswer((_) async {});
    cubit = PostActionsCubit(posts, report, mute, follow, EventBus());
  });

  group('like', () {
    test('shows at once and takes the count the server answers', () async {
      final answer = Completer<int>();
      when(() => posts.setLike('p1', liked: true))
          .thenAnswer((_) => answer.future);
      final done = cubit.toggleLike(post);
      expect(cubit.postOf(post).likedByMe, isTrue);
      expect(cubit.postOf(post).likeCount, 11);
      answer.complete(15);
      await done;
      expect(cubit.postOf(post).likeCount, 15);
      expect(cubit.state.failure, isNull);
    });

    test('rolls back and tells once when it fails', () async {
      when(() => posts.setLike('p1', liked: true))
          .thenThrow(const NetworkFailure());
      await cubit.toggleLike(post);
      expect(cubit.postOf(post).likedByMe, isFalse);
      expect(cubit.postOf(post).likeCount, 10);
      expect(cubit.state.failure, const NetworkFailure());
    });

    test('unlikes a liked post, never below zero', () async {
      final liked = testPost('p1', liked: true, likes: 0);
      when(() => posts.setLike('p1', liked: false)).thenAnswer((_) async => 0);
      await cubit.toggleLike(liked);
      expect(cubit.postOf(liked).likedByMe, isFalse);
      expect(cubit.postOf(liked).likeCount, 0);
    });

    test('the double tap likes and never unlikes', () async {
      when(() => posts.setLike('p1', liked: true)).thenAnswer((_) async => 11);
      await cubit.likeByDoubleTap(post);
      await cubit.likeByDoubleTap(post);
      verify(() => posts.setLike('p1', liked: true)).called(1);
      verifyNever(() => posts.setLike('p1', liked: false));
    });

    test('a second tap waits for the first', () async {
      final answer = Completer<int>();
      when(() => posts.setLike(any(), liked: any(named: 'liked')))
          .thenAnswer((_) => answer.future);
      final first = cubit.toggleLike(post);
      await cubit.toggleLike(post);
      answer.complete(11);
      await first;
      verify(() => posts.setLike('p1', liked: true)).called(1);
    });
  });

  group('save', () {
    test('shows at once and follows the answer', () async {
      when(() => posts.setSave('p1', saved: true))
          .thenAnswer((_) async => true);
      await cubit.toggleSave(post);
      expect(cubit.postOf(post).savedByMe, isTrue);
    });

    test('rolls back when it fails', () async {
      when(() => posts.setSave('p1', saved: true))
          .thenThrow(const NetworkFailure());
      await cubit.toggleSave(post);
      expect(cubit.postOf(post).savedByMe, isFalse);
      expect(cubit.state.failure, const NetworkFailure());
    });
  });

  group('options', () {
    test(
      'Not interested turns the card into the hidden row, Undo brings it back',
      () async {
        await cubit.notInterested(post);
        expect(cubit.rowOf('p1'), PostRow.hidden);
        verify(() => posts.hidePost('p1', hidden: true)).called(1);

        await cubit.undoNotInterested(post);
        expect(cubit.rowOf('p1'), PostRow.card);
        verify(() => posts.hidePost('p1', hidden: false)).called(1);
      },
    );

    test('a failed hide throws and leaves the card', () async {
      when(() => posts.hidePost('p1', hidden: true))
          .thenThrow(const NetworkFailure());
      expect(
        await failureOf(cubit.notInterested(post)),
        const NetworkFailure(),
      );
      expect(cubit.rowOf('p1'), PostRow.card);
    });

    test('Unfollow and Undo act on the author', () async {
      when(() => follow('a1', follow: any(named: 'follow')))
          .thenAnswer((_) async => FollowStatus.none);
      await cubit.unfollow(post);
      verify(() => follow('a1', follow: false)).called(1);
      await cubit.undoUnfollow(post);
      verify(() => follow('a1', follow: true)).called(1);
    });

    test('a failed Unfollow throws', () async {
      when(() => follow('a1', follow: false))
          .thenAnswer((_) async => throw const NetworkFailure());
      expect(await failureOf(cubit.unfollow(post)), const NetworkFailure());
    });

    test('Mute and Undo act on the author for posts only', () async {
      await cubit.mute(post);
      verify(() => mute('a1', muted: true, scope: MuteScope.posts)).called(1);
      await cubit.undoMute(post);
      verify(() => mute('a1', muted: false, scope: MuteScope.posts)).called(1);
    });

    test('Report removes the post', () async {
      await cubit.report(post, ReportReason.spam, 'ads');
      verify(
        () => report(ContentKind.post, 'p1', ReportReason.spam, note: 'ads'),
      ).called(1);
      expect(cubit.rowOf('p1'), PostRow.removed);
    });

    test('a failed report keeps the post', () async {
      when(() => report(any(), any(), any(), note: any(named: 'note')))
          .thenThrow(const NetworkFailure());
      expect(
        await failureOf(cubit.report(post, ReportReason.spam, null)),
        const NetworkFailure(),
      );
      expect(cubit.rowOf('p1'), PostRow.card);
    });

    test('Delete hides the post and sends nothing yet', () {
      cubit.delete(post);
      expect(cubit.rowOf('p1'), PostRow.deleting);
      verifyNever(() => posts.deletePost(any()));
    });

    test('Undo brings the deleted post back', () {
      cubit.delete(post);
      cubit.undoDelete(post);
      expect(cubit.rowOf('p1'), PostRow.card);
    });

    test('the commit sends the delete and removes the post', () async {
      cubit.delete(post);
      await cubit.commitDelete(post);
      verify(() => posts.deletePost('p1')).called(1);
      expect(cubit.rowOf('p1'), PostRow.removed);
    });

    test('a failed commit brings the post back with the failure', () async {
      when(() => posts.deletePost(any())).thenThrow(const NetworkFailure());
      cubit.delete(post);
      await cubit.commitDelete(post);
      expect(cubit.rowOf('p1'), PostRow.card);
      expect(cubit.state.failure, const NetworkFailure());
    });

    test(
      'a delete is announced at each step so other screens follow',
      () async {
        final bus = EventBus();
        final stages = <ContentDeleteStage>[];
        bus.on<ContentDeleteEvent>().listen((event) {
          expect((event.kind, event.id), (ContentKind.post, 'p1'));
          stages.add(event.stage);
        });
        final announcing = PostActionsCubit(posts, report, mute, follow, bus);

        announcing.delete(post);
        announcing.undoDelete(post);
        announcing.delete(post);
        await announcing.commitDelete(post);
        when(() => posts.deletePost(any())).thenThrow(const NetworkFailure());
        await announcing.commitDelete(post);
        await Future<void>.delayed(Duration.zero);

        expect(stages, [
          ContentDeleteStage.pending,
          ContentDeleteStage.restored,
          ContentDeleteStage.pending,
          ContentDeleteStage.deleted,
          ContentDeleteStage.restored,
        ]);
      },
    );

    test('turns comments off and on again', () async {
      await cubit.toggleComments(post);
      expect(cubit.postOf(post).commentsEnabled, isFalse);
      verify(() => posts.setCommentsEnabled('p1', enabled: false)).called(1);
      await cubit.toggleComments(post);
      expect(cubit.postOf(post).commentsEnabled, isTrue);
    });

    test('shows the audience the picker saved', () {
      cubit.audienceChanged(post, ContentAudience.closeFriends);
      expect(cubit.postOf(post).visibility, ContentAudience.closeFriends);
    });
  });

  test('reset forgets everything done to the old posts', () async {
    cubit.delete(post);
    cubit.audienceChanged(post, ContentAudience.onlyMe);
    cubit.reset();
    expect(cubit.rowOf('p1'), PostRow.card);
    expect(cubit.postOf(post), post);
  });

  group('removeMyTag', () {
    final tagged = PostEntity(
      id: 'p1',
      authorId: 'a1',
      username: 'nour',
      likeCount: 1,
      commentCount: 0,
      commentsEnabled: true,
      visibility: ContentAudience.public,
      createdAt: DateTime(2026),
      likedByMe: false,
      savedByMe: false,
      media: const [],
      tags: const [
        PostTagEntity(userId: 'me', username: 'me'),
        PostTagEntity(userId: 'u2', username: 'omar'),
      ],
      tagCount: 3,
      iAmTagged: true,
    );

    test('shows the tag gone at once and keeps it gone', () async {
      final answer = Completer<bool>();
      when(() => posts.removeMyTag('p1')).thenAnswer((_) => answer.future);

      final done = cubit.removeMyTag(tagged, userId: 'me');

      final during = cubit.postOf(tagged);
      expect(during.tags.map((t) => t.userId), ['u2']);
      expect(during.tagCount, 2);
      expect(during.iAmTagged, isFalse);
      answer.complete(true);
      await done;
      expect(cubit.postOf(tagged).tagCount, 2);
    });

    test('a tag that was already gone counts as removed', () async {
      when(() => posts.removeMyTag('p1')).thenAnswer((_) async => false);

      await cubit.removeMyTag(tagged, userId: 'me');

      expect(cubit.postOf(tagged).iAmTagged, isFalse);
    });

    test('puts the tag back and throws when it fails', () async {
      when(() => posts.removeMyTag('p1')).thenThrow(const NetworkFailure());

      await expectLater(
        cubit.removeMyTag(tagged, userId: 'me'),
        throwsA(isA<NetworkFailure>()),
      );

      final after = cubit.postOf(tagged);
      expect(after.tags.length, 2);
      expect(after.tagCount, 3);
      expect(after.iAmTagged, isTrue);
    });

    test('a like keeps the tags, the feeling and the count', () async {
      when(() => posts.setLike('p1', liked: true)).thenAnswer((_) async => 2);

      await cubit.toggleLike(tagged);

      final after = cubit.postOf(tagged);
      expect(after.tags, tagged.tags);
      expect(after.tagCount, 3);
      expect(after.iAmTagged, isTrue);
    });
  });

  group('counts and replaced posts', () {
    test('a save set on the post page lands on the post', () {
      cubit.applyCounts(
        [post],
        {'p1': const PostCountModel(id: 'p1', savedByMe: true)},
      );
      expect(cubit.postOf(post).savedByMe, isTrue);
      expect(cubit.postOf(post).likeCount, post.likeCount);
    });

    test('new counts land on the post; equal ones change nothing', () {
      cubit.applyCounts(
        [post],
        {
          'p1': const PostCountModel(
            id: 'p1',
            likeCount: 25,
            commentCount: 7,
            likedByMe: true,
          ),
        },
      );
      final after = cubit.postOf(post);
      expect(after.likeCount, 25);
      expect(after.commentCount, 7);
      expect(after.likedByMe, isTrue);

      final states = <Object>[];
      cubit.stream.listen(states.add);
      cubit.applyCounts(
        [post],
        {
          'p1': const PostCountModel(
            id: 'p1',
            likeCount: 25,
            commentCount: 7,
            likedByMe: true,
          ),
        },
      );
      expect(states, isEmpty);
    });

    test('a post with a like request in flight keeps its own count', () async {
      final answer = Completer<int>();
      when(() => posts.setLike('p1', liked: true))
          .thenAnswer((_) => answer.future);
      final done = cubit.toggleLike(post);

      cubit.applyCounts(
        [post],
        {'p1': const PostCountModel(id: 'p1', likeCount: 3, commentCount: 2)},
      );
      expect(cubit.postOf(post).likeCount, 11);

      answer.complete(11);
      await done;
    });

    test('forget drops what was done to the replaced posts only', () async {
      when(() => posts.setSave('p1', saved: true))
          .thenAnswer((_) async => true);
      when(() => posts.setSave('p2', saved: true))
          .thenAnswer((_) async => true);
      final other = testPost('p2');
      await cubit.toggleSave(post);
      await cubit.toggleSave(other);

      cubit.forget({'p1', 'zz'});

      expect(cubit.postOf(post).savedByMe, isFalse);
      expect(cubit.postOf(other).savedByMe, isTrue);
    });
  });
}
