import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/data/model/comment_model.dart';
import 'package:pulse/features/post/data/model/comment_page_model.dart';
import 'package:pulse/features/post/domain/mapper/comment_entity_mapper.dart';

void main() {
  CommentModel model({
    String? id = 'c1',
    String? body = 'hello',
    List<CommentModel>? replies,
  }) => CommentModel(
    id: id,
    postId: 'p1',
    authorId: 'u1',
    username: 'sara',
    body: body,
    createdAt: DateTime.utc(2026, 10, 25),
    replies: replies,
  );

  test('a complete row becomes an entity with safe defaults', () {
    final comment = CommentEntityMapper.fromModel(model())!;

    expect(comment.id, 'c1');
    expect(comment.likeCount, 0);
    expect(comment.likedByMe, isFalse);
    expect(comment.isPostAuthor, isFalse);
    expect(comment.replyCount, 0);
    expect(comment.isFocus, isFalse);
    expect(comment.isReply, isFalse);
    expect(comment.isEdited, isFalse);
  });

  test('a row missing something the list needs is left out', () {
    expect(CommentEntityMapper.fromModel(model(id: null)), isNull);
    expect(CommentEntityMapper.fromModel(model(body: null)), isNull);
    expect(
      CommentEntityMapper.list([model(id: null), model(id: 'c2')])
          .map((c) => c.id),
      ['c2'],
    );
  });

  test('replies are mapped, and a broken reply is dropped', () {
    final comment = CommentEntityMapper.fromModel(
      model(
        replies: [
          model(id: 'r1'),
          model(id: null),
        ],
      ),
    )!;

    expect(comment.replies.map((r) => r.id), ['r1']);
  });

  test('the page has a cursor only when all three parts are set', () {
    final complete = CommentEntityMapper.page(
      CommentPageModel(
        comments: [model()],
        nextRank: 2,
        nextCreated: DateTime.utc(2026, 10, 25),
        nextId: 'c1',
      ),
    );
    final partial = CommentEntityMapper.page(
      CommentPageModel(comments: [model()], nextRank: 2, nextId: 'c1'),
    );

    expect(complete.nextCursor?.id, 'c1');
    expect(complete.nextCursor?.rank, 2);
    expect(partial.nextCursor, isNull);
  });
}
