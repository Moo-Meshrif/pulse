import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/domain/use_case/delete_post_use_case.dart';
import 'package:pulse/features/post/domain/use_case/hide_post_use_case.dart';
import 'package:pulse/features/post/domain/use_case/remove_my_tag_use_case.dart';
import 'package:pulse/features/post/domain/use_case/set_comments_enabled_use_case.dart';
import 'package:pulse/features/post/domain/use_case/set_post_like_use_case.dart';
import 'package:pulse/features/post/domain/use_case/set_post_save_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/post_actions_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/post_row.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';

import '../../../../helpers/content_mocks.dart';
import '../../../../helpers/failure_of.dart';
import '../../post_fixtures.dart';

class _Like extends Mock implements SetPostLikeUseCase {}

class _Save extends Mock implements SetPostSaveUseCase {}

class _Hide extends Mock implements HidePostUseCase {}

class _Comments extends Mock implements SetCommentsEnabledUseCase {}

class _Delete extends Mock implements DeletePostUseCase {}

class _Follow extends Mock implements ToggleFollowUseCase {}

class _RemoveTag extends Mock implements RemoveMyTagUseCase {}

void main() {
  late _Like like;
  late _Save save;
  late _Hide hide;
  late _Comments comments;
  late _Delete delete;
  late MockReportContent report;
  late MockSetMute mute;
  late _Follow follow;
  late _RemoveTag removeTag;
  late PostActionsCubit cubit;

  final post = testPost('p1', authorId: 'a1');

  setUpAll(registerContentFallbacks);

  setUp(() {
    like = _Like();
    save = _Save();
    hide = _Hide();
    comments = _Comments();
    delete = _Delete();
    report = MockReportContent();
    mute = MockSetMute();
    follow = _Follow();
    removeTag = _RemoveTag();
    when(() => hide(any(), hidden: any(named: 'hidden')))
        .thenAnswer((_) async {});
    when(() => comments(any(), enabled: any(named: 'enabled')))
        .thenAnswer((_) async {});
    when(() => delete(any())).thenAnswer((_) async {});
    when(() => report(any(), any(), any(), note: any(named: 'note')))
        .thenAnswer((_) async {});
    when(
      () => mute(
        any(),
        muted: any(named: 'muted'),
        scope: any(named: 'scope'),
      ),
    ).thenAnswer((_) async {});
    cubit = PostActionsCubit(
      like,
      save,
      hide,
      comments,
      delete,
      report,
      mute,
      follow,
      removeTag,
    );
  });

  group('like', () {
    test('shows at once and takes the count the server answers', () async {
      final answer = Completer<int>();
      when(() => like('p1', liked: true)).thenAnswer((_) => answer.future);
      final done = cubit.toggleLike(post);
      expect(cubit.postOf(post).likedByMe, isTrue);
      expect(cubit.postOf(post).likeCount, 11);
      answer.complete(15);
      await done;
      expect(cubit.postOf(post).likeCount, 15);
      expect(cubit.state.failure, isNull);
    });

    test('rolls back and tells once when it fails', () async {
      when(() => like('p1', liked: true)).thenThrow(const NetworkFailure());
      await cubit.toggleLike(post);
      expect(cubit.postOf(post).likedByMe, isFalse);
      expect(cubit.postOf(post).likeCount, 10);
      expect(cubit.state.failure, const NetworkFailure());
    });

    test('unlikes a liked post, never below zero', () async {
      final liked = testPost('p1', liked: true, likes: 0);
      when(() => like('p1', liked: false)).thenAnswer((_) async => 0);
      await cubit.toggleLike(liked);
      expect(cubit.postOf(liked).likedByMe, isFalse);
      expect(cubit.postOf(liked).likeCount, 0);
    });

    test('the double tap likes and never unlikes', () async {
      when(() => like('p1', liked: true)).thenAnswer((_) async => 11);
      await cubit.likeByDoubleTap(post);
      await cubit.likeByDoubleTap(post);
      verify(() => like('p1', liked: true)).called(1);
      verifyNever(() => like('p1', liked: false));
    });

    test('a second tap waits for the first', () async {
      final answer = Completer<int>();
      when(() => like(any(), liked: any(named: 'liked')))
          .thenAnswer((_) => answer.future);
      final first = cubit.toggleLike(post);
      await cubit.toggleLike(post);
      answer.complete(11);
      await first;
      verify(() => like('p1', liked: true)).called(1);
    });
  });

  group('save', () {
    test('shows at once and follows the answer', () async {
      when(() => save('p1', saved: true)).thenAnswer((_) async => true);
      await cubit.toggleSave(post);
      expect(cubit.postOf(post).savedByMe, isTrue);
    });

    test('rolls back when it fails', () async {
      when(() => save('p1', saved: true)).thenThrow(const NetworkFailure());
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
        verify(() => hide('p1', hidden: true)).called(1);

        await cubit.undoNotInterested(post);
        expect(cubit.rowOf('p1'), PostRow.card);
        verify(() => hide('p1', hidden: false)).called(1);
      },
    );

    test('a failed hide throws and leaves the card', () async {
      when(() => hide('p1', hidden: true)).thenThrow(const NetworkFailure());
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
      verifyNever(() => delete(any()));
    });

    test('Undo brings the deleted post back', () {
      cubit.delete(post);
      cubit.undoDelete(post);
      expect(cubit.rowOf('p1'), PostRow.card);
    });

    test('the commit sends the delete and removes the post', () async {
      cubit.delete(post);
      await cubit.commitDelete(post);
      verify(() => delete('p1')).called(1);
      expect(cubit.rowOf('p1'), PostRow.removed);
    });

    test('a failed commit brings the post back with the failure', () async {
      when(() => delete(any())).thenThrow(const NetworkFailure());
      cubit.delete(post);
      await cubit.commitDelete(post);
      expect(cubit.rowOf('p1'), PostRow.card);
      expect(cubit.state.failure, const NetworkFailure());
    });

    test('turns comments off and on again', () async {
      await cubit.toggleComments(post);
      expect(cubit.postOf(post).commentsEnabled, isFalse);
      verify(() => comments('p1', enabled: false)).called(1);
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
      when(() => removeTag('p1')).thenAnswer((_) => answer.future);

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
      when(() => removeTag('p1')).thenAnswer((_) async => false);

      await cubit.removeMyTag(tagged, userId: 'me');

      expect(cubit.postOf(tagged).iAmTagged, isFalse);
    });

    test('puts the tag back and throws when it fails', () async {
      when(() => removeTag('p1')).thenThrow(const NetworkFailure());

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
      when(() => like('p1', liked: true)).thenAnswer((_) async => 2);

      await cubit.toggleLike(tagged);

      final after = cubit.postOf(tagged);
      expect(after.tags, tagged.tags);
      expect(after.tagCount, 3);
      expect(after.iAmTagged, isTrue);
    });
  });
}
