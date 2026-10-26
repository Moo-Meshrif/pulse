import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/datasource/comments_datasource.dart';
import 'package:pulse/features/post/data/datasource/comments_local_datasource.dart';
import 'package:pulse/features/post/data/enums/comment_sort.dart';
import 'package:pulse/features/post/data/model/comment_model.dart';
import 'package:pulse/features/post/data/model/comment_page_model.dart';
import 'package:pulse/features/post/data/model/mention_person_model.dart';
import 'package:pulse/features/post/domain/entity/comment_cursor_entity.dart';
import 'package:pulse/features/post/domain/entity/comment_entity.dart';
import 'package:pulse/features/post/domain/use_case/add_comment_use_case.dart';
import 'package:pulse/features/post/domain/use_case/edit_comment_use_case.dart';
import 'package:pulse/features/post/domain/use_case/get_comment_replies_use_case.dart';
import 'package:pulse/features/post/domain/use_case/get_mention_candidates_use_case.dart';
import 'package:pulse/features/post/domain/use_case/get_post_comments_use_case.dart';
import '../../../../helpers/memory_snapshot_storage.dart';

class _MockComments extends Mock implements CommentsDatasource {}

void main() {
  late _MockComments comments;

  CommentModel model(String id) => CommentModel(
    id: id,
    postId: 'p1',
    authorId: 'u1',
    username: 'sara',
    body: 'hello',
    createdAt: DateTime.utc(2026, 10, 25),
  );

  setUpAll(() {
    registerFallbackValue(CommentSort.relevant);
    registerFallbackValue(DateTime.utc(2026));
  });

  setUp(() => comments = _MockComments());

  test(
    'GetPostCommentsUseCase asks for a page and passes the cursor',
    () async {
      final cursor = CommentCursorEntity(
        rank: 1,
        createdAt: DateTime.utc(2026, 10, 25),
        id: 'c0',
      );
      when(
        () => comments.getComments(
          any(),
          sort: any(named: 'sort'),
          limit: any(named: 'limit'),
          beforeRank: any(named: 'beforeRank'),
          beforeCreated: any(named: 'beforeCreated'),
          beforeId: any(named: 'beforeId'),
          focusCommentId: any(named: 'focusCommentId'),
        ),
      ).thenAnswer((_) async => CommentPageModel(comments: [model('c1')]));

      final page = await GetPostCommentsUseCase(
        comments,
        CommentsLocalDatasource(MemorySnapshotStorage()),
      )(
        'p1',
        sort: CommentSort.newest,
        before: cursor,
        focusCommentId: 'c9',
      );

      expect(page.comments.single.id, 'c1');
      verify(
        () => comments.getComments(
          'p1',
          sort: CommentSort.newest,
          limit: GetPostCommentsUseCase.pageSize,
          beforeRank: 1,
          beforeCreated: DateTime.utc(2026, 10, 25),
          beforeId: 'c0',
          focusCommentId: 'c9',
        ),
      ).called(1);
    },
  );

  test('GetCommentRepliesUseCase continues after the last reply', () async {
    final last = model('r1').createdAt;
    when(
      () => comments.getReplies(
        any(),
        limit: any(named: 'limit'),
        afterCreated: any(named: 'afterCreated'),
        afterId: any(named: 'afterId'),
      ),
    ).thenAnswer((_) async => [model('r2')]);

    final replies = await GetCommentRepliesUseCase(comments)(
      'c1',
      after: _entity('r1'),
    );

    expect(replies.single.id, 'r2');
    verify(
      () => comments.getReplies(
        'c1',
        limit: GetCommentRepliesUseCase.pageSize,
        afterCreated: last,
        afterId: 'r1',
      ),
    ).called(1);
  });

  test('AddCommentUseCase returns the comment as written', () async {
    when(
      () => comments.addComment(
        any(),
        any(),
        parentId: any(named: 'parentId'),
        clientId: any(named: 'clientId'),
      ),
    ).thenAnswer((_) async => model('c1'));

    final comment = await AddCommentUseCase(comments)(
      'p1',
      'hello',
      parentId: 'c0',
      clientId: 'k1',
    );

    expect(comment.id, 'c1');
    verify(
      () => comments.addComment('p1', 'hello', parentId: 'c0', clientId: 'k1'),
    ).called(1);
  });

  test('AddCommentUseCase fails on an answer it cannot read', () async {
    when(
      () => comments.addComment(
        any(),
        any(),
        parentId: any(named: 'parentId'),
        clientId: any(named: 'clientId'),
      ),
    ).thenAnswer((_) async => const CommentModel());

    await expectLater(
      AddCommentUseCase(comments)('p1', 'hello', clientId: 'k1'),
      throwsA(const ParseFailure()),
    );
  });

  test('EditCommentUseCase returns the comment as saved', () async {
    when(() => comments.editComment('c1', 'new'))
        .thenAnswer((_) async => model('c1'));

    final comment = await EditCommentUseCase(comments)('c1', 'new');

    expect(comment.id, 'c1');
  });

  test(
    'GetMentionCandidatesUseCase leaves out rows without a username',
    () async {
      when(() => comments.getMentionCandidates('p1', 'sa')).thenAnswer(
        (_) async => const [
          MentionPersonModel(id: 'u1', username: 'sara'),
          MentionPersonModel(id: 'u2'),
        ],
      );

      final people = await GetMentionCandidatesUseCase(comments)('p1', 'sa');

      expect(people.map((p) => p.username), ['sara']);
    },
  );
}

CommentEntity _entity(String id) => CommentEntity(
  id: id,
  postId: 'p1',
  authorId: 'u1',
  username: 'sara',
  body: 'hello',
  createdAt: DateTime.utc(2026, 10, 25),
  likeCount: 0,
  likedByMe: false,
  isPostAuthor: false,
  replyCount: 0,
);
