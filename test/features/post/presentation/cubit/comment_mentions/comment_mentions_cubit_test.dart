import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/domain/entity/mention_person_entity.dart';
import 'package:pulse/features/post/presentation/cubit/comment_mentions/comment_mentions_cubit.dart';

import '../../../post_doubles.dart';

const sara = MentionPersonEntity(id: 'u1', username: 'sara.k');

void main() {
  late MockPostRepository posts;
  late CommentMentionsCubit cubit;

  setUp(() {
    posts = MockPostRepository();
    cubit = CommentMentionsCubit(posts, 'p1');
  });

  tearDown(() => cubit.close());

  test('asks once after a pause and shows the people', () {
    fakeAsync((async) {
      when(() => posts.mentionCandidates('p1', 'sa'))
          .thenAnswer((_) async => [sara]);
      cubit
        ..queryChanged('s')
        ..queryChanged('sa');
      async.elapse(const Duration(milliseconds: 299));
      verifyNever(() => posts.mentionCandidates(any(), any()));
      async.elapse(const Duration(milliseconds: 1));
      async.flushMicrotasks();
      verify(() => posts.mentionCandidates('p1', 'sa')).called(1);
      verifyNever(() => posts.mentionCandidates('p1', 's'));
      expect(cubit.state, [sara]);
    });
  });

  test('no query clears the list and asks nothing', () {
    fakeAsync((async) {
      when(() => posts.mentionCandidates('p1', 'sa'))
          .thenAnswer((_) async => [sara]);
      cubit.queryChanged('sa');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      cubit.queryChanged(null);
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(cubit.state, isEmpty);
      verify(() => posts.mentionCandidates(any(), any())).called(1);
    });
  });

  test('a failure shows no one', () {
    fakeAsync((async) {
      when(() => posts.mentionCandidates('p1', 'sa'))
          .thenAnswer((_) async => [sara]);
      when(() => posts.mentionCandidates('p1', 'sar'))
          .thenThrow(const NetworkFailure());
      cubit.queryChanged('sa');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      cubit.queryChanged('sar');
      async.elapse(const Duration(milliseconds: 300));
      async.flushMicrotasks();
      expect(cubit.state, isEmpty);
    });
  });
}
