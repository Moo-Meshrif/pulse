import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/state/load_more_status.dart';
import 'package:pulse/features/post/data/datasource/comments_datasource.dart';
import 'package:pulse/features/post/data/enums/comment_sort.dart';
import 'package:pulse/features/post/domain/entity/comment_cursor_entity.dart';
import 'package:pulse/features/post/domain/entity/comment_entity.dart';
import 'package:pulse/features/post/domain/entity/comment_page_entity.dart';
import 'package:pulse/features/post/domain/use_case/add_comment_use_case.dart';
import 'package:pulse/features/post/domain/use_case/edit_comment_use_case.dart';
import 'package:pulse/features/post/domain/use_case/get_comment_replies_use_case.dart';
import 'package:pulse/features/post/domain/use_case/get_post_comments_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/comments/comments_cubit.dart';
import 'package:pulse/features/post/presentation/utils/comment_drafts.dart';
import 'package:pulse/features/post/presentation/utils/enums/comments_status.dart';
import 'package:pulse/features/profile/domain/entity/last_account_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/use_case/report_content_use_case.dart';

class _MockGetComments extends Mock implements GetPostCommentsUseCase {}

class _MockGetReplies extends Mock implements GetCommentRepliesUseCase {}

class _MockComments extends Mock implements CommentsDatasource {}

class _MockAddComment extends Mock implements AddCommentUseCase {}

class _MockEdit extends Mock implements EditCommentUseCase {}

class _MockReport extends Mock implements ReportContentUseCase {}

class _MockAccount extends Mock implements GetLastAccountUseCase {}

CommentEntity comment(
  String id, {
  String? parentId,
  String authorId = 'u1',
  int likes = 0,
  bool liked = false,
  int replyCount = 0,
  List<CommentEntity> replies = const [],
}) => CommentEntity(
  id: id,
  postId: 'p1',
  parentId: parentId,
  authorId: authorId,
  username: 'sara',
  body: 'hello',
  createdAt: DateTime.utc(2026, 10, 25),
  likeCount: likes,
  likedByMe: liked,
  isPostAuthor: false,
  replyCount: replyCount,
  replies: replies,
);

void main() {
  late _MockGetComments getComments;
  late _MockGetReplies getReplies;
  late _MockComments comments;
  late _MockAddComment addComment;
  late CommentDrafts drafts;
  late _MockEdit edit;
  late _MockReport report;

  final cursor = CommentCursorEntity(
    rank: 1,
    createdAt: DateTime.utc(2026, 10, 25),
    id: 'c1',
  );

  final account = _MockAccount();

  CommentsCubit build() => CommentsCubit(
    getComments,
    getReplies,
    comments,
    addComment,
    drafts,
    edit,
    report,
    account,
    'p1',
    null,
  );

  void stubPage(
    List<CommentEntity> page, {
    CommentCursorEntity? next,
    CommentCursorEntity? before,
    CommentSort sort = CommentSort.relevant,
  }) =>
      when(
        () => getComments(
          'p1',
          sort: sort,
          before: before,
          userId: any(named: 'userId'),
          focusCommentId: any(named: 'focusCommentId'),
        ),
      ).thenAnswer(
        (_) async => CommentPageEntity(comments: page, nextCursor: next),
      );

  setUpAll(() {
    registerFallbackValue(CommentSort.relevant);
    registerFallbackValue(cursor);
    registerFallbackValue(ContentKind.comment);
    registerFallbackValue(ReportReason.spam);
  });

  setUp(() {
    getComments = _MockGetComments();
    getReplies = _MockGetReplies();
    comments = _MockComments();
    addComment = _MockAddComment();
    drafts = CommentDrafts();
    edit = _MockEdit();
    report = _MockReport();
    when(() => account())
        .thenReturn(const LastAccountEntity(id: 'me', username: 'sara.k'));
  });

  group('load', () {
    blocTest<CommentsCubit, dynamic>(
      'shows the first page',
      setUp: () => stubPage([comment('c1')], next: cursor),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.status, CommentsStatus.ready);
        expect(cubit.state.comments.map((c) => c.id), ['c1']);
        expect(cubit.state.nextCursor, cursor);
      },
    );

    blocTest<CommentsCubit, dynamic>(
      'a post with no comments is ready and empty',
      setUp: () => stubPage([]),
      build: build,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.status, CommentsStatus.ready);
        expect(cubit.state.comments, isEmpty);
      },
    );

    test('a failure shows failed, and load again recovers', () async {
      when(
        () => getComments(
          'p1',
          sort: any(named: 'sort'),
          before: any(named: 'before'),
          userId: any(named: 'userId'),
          focusCommentId: any(named: 'focusCommentId'),
        ),
      ).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load();
      expect(cubit.state.status, CommentsStatus.failed);

      stubPage([comment('c1')]);
      await cubit.load();
      expect(cubit.state.status, CommentsStatus.ready);
      await cubit.close();
    });
  });

  test('changing the sort reloads from the top in that order', () async {
    stubPage([comment('c1')]);
    stubPage([comment('c2')], sort: CommentSort.newest);
    final cubit = build();
    await cubit.load();
    await cubit.changeSort(CommentSort.newest);
    expect(cubit.state.sort, CommentSort.newest);
    expect(cubit.state.comments.map((c) => c.id), ['c2']);
    await cubit.close();
  });

  group('loadMore', () {
    test('appends the next page from the cursor', () async {
      stubPage([comment('c1')], next: cursor);
      stubPage([comment('c2')], before: cursor);
      final cubit = build();
      await cubit.load();
      await cubit.loadMore();
      expect(cubit.state.comments.map((c) => c.id), ['c1', 'c2']);
      expect(cubit.state.nextCursor, isNull);
      expect(cubit.state.more, LoadMoreStatus.idle);
      await cubit.close();
    });

    test('a failed page waits for retry, which loads it', () async {
      stubPage([comment('c1')], next: cursor);
      final cubit = build();
      await cubit.load();
      when(
        () => getComments(
          'p1',
          sort: any(named: 'sort'),
          before: cursor,
          userId: any(named: 'userId'),
          focusCommentId: any(named: 'focusCommentId'),
        ),
      ).thenThrow(const NetworkFailure());
      await cubit.loadMore();
      expect(cubit.state.more, LoadMoreStatus.failed);

      await cubit.loadMore();
      verify(
        () => getComments(
          'p1',
          sort: any(named: 'sort'),
          before: cursor,
          userId: any(named: 'userId'),
          focusCommentId: any(named: 'focusCommentId'),
        ),
      ).called(1);

      stubPage([comment('c2')], before: cursor);
      await cubit.loadMore(retry: true);
      expect(cubit.state.comments.map((c) => c.id), ['c1', 'c2']);
      await cubit.close();
    });

    test('does nothing on the last page', () async {
      stubPage([comment('c1')]);
      final cubit = build();
      await cubit.load();
      await cubit.loadMore();
      verify(
        () => getComments(
          'p1',
          sort: any(named: 'sort'),
          before: any(named: 'before'),
          userId: any(named: 'userId'),
          focusCommentId: any(named: 'focusCommentId'),
        ),
      ).called(1);
      await cubit.close();
    });
  });

  group('loadMoreReplies', () {
    final reply1 = comment('r1', parentId: 'c1');

    test('adds the rest of the thread after the last reply', () async {
      stubPage([
        comment('c1', replyCount: 3, replies: [reply1]),
      ]);
      when(() => getReplies('c1', after: reply1)).thenAnswer(
        (_) async => [
          comment('r2', parentId: 'c1'),
          comment('r3', parentId: 'c1'),
        ],
      );
      final cubit = build();
      await cubit.load();
      await cubit.loadMoreReplies(cubit.state.comments.first);
      expect(cubit.state.comments.first.replies.map((r) => r.id), [
        'r1',
        'r2',
        'r3',
      ]);
      expect(cubit.state.replies, isEmpty);
      await cubit.close();
    });

    test('a failure marks the thread, and the same call retries', () async {
      stubPage([
        comment('c1', replyCount: 2, replies: [reply1]),
      ]);
      when(() => getReplies('c1', after: reply1))
          .thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load();
      await cubit.loadMoreReplies(cubit.state.comments.first);
      expect(cubit.state.replies['c1'], LoadMoreStatus.failed);

      when(() => getReplies('c1', after: reply1))
          .thenAnswer((_) async => [comment('r2', parentId: 'c1')]);
      await cubit.loadMoreReplies(cubit.state.comments.first);
      expect(cubit.state.comments.first.replies, hasLength(2));
      expect(cubit.state.replies, isEmpty);
      await cubit.close();
    });

    test('an empty page completes the thread', () async {
      stubPage([
        comment('c1', replyCount: 5, replies: [reply1]),
      ]);
      when(() => getReplies('c1', after: reply1)).thenAnswer((_) async => []);
      final cubit = build();
      await cubit.load();
      await cubit.loadMoreReplies(cubit.state.comments.first);
      expect(cubit.state.comments.first.replyCount, 1);
      await cubit.close();
    });
  });

  group('toggleLike', () {
    test('likes at once, then takes the count from the server', () async {
      stubPage([comment('c1', likes: 2)]);
      when(() => comments.setLike('c1', liked: true))
          .thenAnswer((_) async => 5);
      final cubit = build();
      await cubit.load();
      final future = cubit.toggleLike(cubit.state.comments.first);
      expect(cubit.state.comments.first.likedByMe, isTrue);
      expect(cubit.state.comments.first.likeCount, 3);
      await future;
      expect(cubit.state.comments.first.likeCount, 5);
      await cubit.close();
    });

    test('puts a failed like back and reports it', () async {
      stubPage([comment('c1', likes: 2)]);
      when(() => comments.setLike('c1', liked: true))
          .thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load();
      await cubit.toggleLike(cubit.state.comments.first);
      expect(cubit.state.comments.first.likedByMe, isFalse);
      expect(cubit.state.comments.first.likeCount, 2);
      expect(cubit.state.failure, const NetworkFailure());
      await cubit.close();
    });

    test('unlikes a liked reply inside its thread', () async {
      final reply = comment('r1', parentId: 'c1', likes: 1, liked: true);
      stubPage([
        comment('c1', replyCount: 1, replies: [reply]),
      ]);
      when(() => comments.setLike('r1', liked: false))
          .thenAnswer((_) async => 0);
      final cubit = build();
      await cubit.load();
      await cubit.toggleLike(reply);
      final updated = cubit.state.comments.first.replies.first;
      expect(updated.likedByMe, isFalse);
      expect(updated.likeCount, 0);
      await cubit.close();
    });
  });
  group('writing', () {
    void stubAdd(CommentEntity saved, {String? parentId}) => when(
      () => addComment(
        'p1',
        any(),
        parentId: parentId,
        clientId: any(named: 'clientId'),
      ),
    ).thenAnswer((_) async => saved);

    test(
      'shows the comment at once, then replaces it with the saved one',
      () async {
        stubPage([comment('c1')]);
        stubAdd(comment('new'));
        final cubit = build();
        await cubit.load();
        final sending = cubit.send('  hi there ');
        expect(cubit.state.pending.single.body, 'hi there');
        expect(cubit.state.pending.single.failed, isFalse);
        await sending;
        expect(cubit.state.pending, isEmpty);
        expect(cubit.state.comments.map((c) => c.id), ['new', 'c1']);
        expect(cubit.state.countDelta, 1);
        await cubit.close();
      },
    );

    test('empty text, spaces only, or over the limit are not sent', () async {
      stubPage([]);
      final cubit = build();
      await cubit.load();
      await cubit.send('   ');
      await cubit.send('a' * 1001);
      expect(cubit.state.pending, isEmpty);
      verifyNever(
        () => addComment(
          any(),
          any(),
          parentId: any(named: 'parentId'),
          clientId: any(named: 'clientId'),
        ),
      );
      await cubit.close();
    });

    test(
      'a reply to a reply goes to the first comment of the thread',
      () async {
        final reply = comment('r1', parentId: 'c1');
        stubPage([
          comment('c1', replyCount: 1, replies: [reply]),
        ]);
        stubAdd(comment('r2', parentId: 'c1'), parentId: 'c1');
        final cubit = build();
        await cubit.load();
        cubit.startReply(reply);
        await cubit.send('@sara hello');
        expect(cubit.state.replyTo, isNull);
        final thread = cubit.state.comments.single;
        expect(thread.replies.map((c) => c.id), ['r1', 'r2']);
        expect(thread.replyCount, 2);
        await cubit.close();
      },
    );

    test('only the @name of a reply is not sent', () async {
      stubPage([comment('c1')]);
      final cubit = build();
      await cubit.load();
      cubit.startReply(comment('c1'));
      await cubit.send('@sara ');
      expect(cubit.state.pending, isEmpty);
      await cubit.close();
    });

    test(
      'a failure keeps the comment as failed; Retry sends the same client id',
      () async {
        stubPage([]);
        final ids = <String>[];
        var calls = 0;
        when(
          () => addComment(
            'p1',
            'hi',
            parentId: null,
            clientId: any(named: 'clientId'),
          ),
        ).thenAnswer((invocation) async {
          ids.add(invocation.namedArguments[#clientId] as String);
          if (++calls == 1) throw const NetworkFailure();
          return comment('new');
        });
        final cubit = build();
        await cubit.load();
        await cubit.send('hi');
        expect(cubit.state.pending.single.failed, isTrue);
        expect(cubit.state.failure, isNull);
        await cubit.retry(ids.first);
        expect(cubit.state.pending, isEmpty);
        expect(ids.toSet().length, 1);
        expect(cubit.state.comments.single.id, 'new');
        await cubit.close();
      },
    );

    test('Delete drops a failed comment', () async {
      stubPage([]);
      when(
        () => addComment(
          any(),
          any(),
          parentId: any(named: 'parentId'),
          clientId: any(named: 'clientId'),
        ),
      ).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load();
      await cubit.send('hi');
      cubit.discardFailed(cubit.state.pending.single.clientId);
      expect(cubit.state.pending, isEmpty);
      await cubit.close();
    });

    test(
      'comments turned off: the comment fails and a notice is shown',
      () async {
        stubPage([]);
        when(
          () => addComment(
            any(),
            any(),
            parentId: any(named: 'parentId'),
            clientId: any(named: 'clientId'),
          ),
        ).thenThrow(const RejectedFailure());
        final cubit = build();
        await cubit.load();
        await cubit.send('hi');
        expect(cubit.state.pending.single.failed, isTrue);
        expect(cubit.state.failure, const RejectedFailure());
        await cubit.close();
      },
    );

    test('the draft is kept for the post and cleared by sending', () async {
      stubPage([]);
      stubAdd(comment('new'));
      final first = build()..saveDraft('half a thought');
      await first.close();
      final second = build();
      expect(second.draft, 'half a thought');
      await second.load();
      await second.send('half a thought');
      expect(second.draft, isEmpty);
      await second.close();
    });
  });

  group('comment actions', () {
    Future<CommentsCubit> loaded(List<CommentEntity> page) async {
      stubPage(page);
      final cubit = build();
      await cubit.load();
      return cubit;
    }

    test('edit saves the new words and marks the comment edited', () async {
      final edited = DateTime.utc(2026, 10, 26);
      final saved = comment('c1').copyWith(body: 'new', editedAt: edited);
      when(() => edit('c1', 'new')).thenAnswer((_) async => saved);
      final cubit = await loaded([comment('c1')]);
      cubit.startEdit(cubit.state.comments.single);
      expect(await cubit.saveEdit(' new '), isTrue);
      expect(cubit.state.editing, isNull);
      expect(cubit.state.comments.single.body, 'new');
      expect(cubit.state.comments.single.editedAt, edited);
      await cubit.close();
    });

    test('edit with the same words only closes the strip', () async {
      final cubit = await loaded([comment('c1')]);
      cubit.startEdit(cubit.state.comments.single);
      expect(await cubit.saveEdit('hello'), isTrue);
      expect(cubit.state.editing, isNull);
      verifyNever(() => edit(any(), any()));
      await cubit.close();
    });

    test('a failed edit keeps the strip and reports', () async {
      when(() => edit('c1', 'new')).thenThrow(const RejectedFailure());
      final cubit = await loaded([comment('c1')]);
      cubit.startEdit(cubit.state.comments.single);
      expect(await cubit.saveEdit('new'), isFalse);
      expect(cubit.state.editing?.id, 'c1');
      expect(cubit.state.failure, const RejectedFailure());
      expect(cubit.state.comments.single.body, 'hello');
      await cubit.close();
    });

    test('delete takes the comment and its replies off the count', () async {
      when(() => comments.deleteComment('c1')).thenAnswer((_) async {});
      final cubit = await loaded([comment('c1', replyCount: 2)]);
      expect(await cubit.delete(cubit.state.comments.single), isTrue);
      expect(cubit.state.comments, isEmpty);
      expect(cubit.state.countDelta, -3);
      await cubit.close();
    });

    test('a failed delete puts the row and the count back', () async {
      when(() => comments.deleteComment('c1'))
          .thenThrow(const NetworkFailure());
      final cubit = await loaded([comment('c1'), comment('c2')]);
      expect(await cubit.delete(cubit.state.comments.first), isFalse);
      expect(cubit.state.comments.map((c) => c.id), ['c1', 'c2']);
      expect(cubit.state.countDelta, 0);
      expect(cubit.state.failure, const NetworkFailure());
      await cubit.close();
    });

    test('deleting a reply lowers its thread count', () async {
      when(() => comments.deleteComment('r1')).thenAnswer((_) async {});
      final reply = comment('r1', parentId: 'c1');
      final cubit = await loaded([
        comment('c1', replyCount: 1, replies: [reply]),
      ]);
      await cubit.delete(reply);
      expect(cubit.state.comments.single.replies, isEmpty);
      expect(cubit.state.comments.single.replyCount, 0);
      expect(cubit.state.countDelta, -1);
      await cubit.close();
    });

    test('hide removes the row and undo brings it back in place', () async {
      when(() => comments.hideComment(any(), hidden: any(named: 'hidden')))
          .thenAnswer((_) async {});
      final cubit = await loaded([comment('c1'), comment('c2'), comment('c3')]);
      expect(await cubit.hide(cubit.state.comments[1]), isTrue);
      expect(cubit.state.comments.map((c) => c.id), ['c1', 'c3']);
      verify(() => comments.hideComment('c2', hidden: true)).called(1);
      await cubit.undoHide('c2');
      expect(cubit.state.comments.map((c) => c.id), ['c1', 'c2', 'c3']);
      verify(() => comments.hideComment('c2', hidden: false)).called(1);
      await cubit.close();
    });

    test('a failed hide puts the row back', () async {
      when(() => comments.hideComment(any(), hidden: any(named: 'hidden')))
          .thenThrow(const NetworkFailure());
      final cubit = await loaded([comment('c1'), comment('c2')]);
      expect(await cubit.hide(cubit.state.comments.first), isFalse);
      expect(cubit.state.comments.map((c) => c.id), ['c1', 'c2']);
      await cubit.undoHide('c1');
      verifyNever(() => comments.hideComment('c1', hidden: false));
      await cubit.close();
    });

    test('report goes through the shared use case as a comment', () async {
      when(() => report(any(), any(), any(), note: any(named: 'note')))
          .thenAnswer((_) async {});
      final cubit = await loaded([comment('c1')]);
      await cubit.report(cubit.state.comments.single, ReportReason.spam, null);
      verify(() => report(ContentKind.comment, 'c1', ReportReason.spam))
          .called(1);
      await cubit.close();
    });

    test('likeOnly likes but never unlikes', () async {
      when(() => comments.setLike('c1', liked: any(named: 'liked')))
          .thenAnswer((_) async => 1);
      final cubit = await loaded([comment('c1')]);
      await cubit.likeOnly(cubit.state.comments.single);
      expect(cubit.state.comments.single.likedByMe, isTrue);
      await cubit.likeOnly(cubit.state.comments.single);
      verify(() => comments.setLike('c1', liked: true)).called(1);
      verifyNever(() => comments.setLike('c1', liked: false));
      await cubit.close();
    });

    test('replyWithEmoji opens the reply and sends the emoji once', () async {
      final cubit = await loaded([comment('c1')]);
      final emojis = <String?>[];
      final sub = cubit.stream.listen((s) => emojis.add(s.emoji));
      cubit.replyWithEmoji(cubit.state.comments.single, '🔥');
      await Future<void>.delayed(Duration.zero);
      expect(emojis, ['🔥', null]);
      expect(cubit.state.replyTo?.id, 'c1');
      await sub.cancel();
      await cubit.close();
    });
  });
}
