import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/post/data/datasource/comments_datasource.dart';
import 'package:pulse/features/post/domain/entity/comment_entity.dart';
import 'package:pulse/features/post/presentation/cubit/comment_mentions/comment_mentions_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/comments/comments_cubit.dart';
import 'package:pulse/features/post/presentation/utils/comment_drafts.dart';
import 'package:pulse/features/post/presentation/widgets/comments/comment_composer.dart';
import 'package:pulse/features/post/presentation/widgets/comments/comment_replying_strip.dart';
import 'package:pulse/features/profile/domain/entity/last_account_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/report_content_use_case.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../post_doubles.dart';

class _Comments extends Mock implements CommentsDatasource {}

class _Report extends Mock implements ReportContentUseCase {}

class _Account extends Mock implements GetLastAccountUseCase {}

void main() {
  late CommentsCubit cubit;
  late MockPostRepository posts;
  late CommentMentionsCubit mentions;

  setUp(() {
    posts = MockPostRepository();
    mentions = CommentMentionsCubit(posts, 'p1');
    final account = _Account();
    when(account.call)
        .thenReturn(const LastAccountEntity(id: 'me', username: 'sara.k'));
    cubit = CommentsCubit(
      posts,
      _Comments(),
      CommentDrafts(),
      _Report(),
      account,
      'p1',
      null,
    );
  });

  tearDown(() async {
    await cubit.close();
    await mentions.close();
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider.value(value: mentions),
          ],
          child: const Align(
            alignment: Alignment.bottomCenter,
            child: CommentComposer(),
          ),
        ),
      ),
      locale: locale,
    );
  }

  testWidgets('Send is off until there is text, and sending clears the field', (
    tester,
  ) async {
    when(
      () => posts.addComment(
        'p1',
        'hello',
        parentId: null,
        clientId: any(named: 'clientId'),
      ),
    ).thenAnswer((_) async => _saved());
    await pump(tester);
    final sendButton = find.bySemanticsLabel(l10nEn.commentsSend);
    await tester.tap(sendButton);
    await tester.pump();
    verifyNever(
      () => posts.addComment(
        any(),
        any(),
        parentId: any(named: 'parentId'),
        clientId: any(named: 'clientId'),
      ),
    );
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await tester.tap(sendButton);
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    verify(
      () => posts.addComment(
        'p1',
        'hello',
        parentId: null,
        clientId: any(named: 'clientId'),
      ),
    ).called(1);
  });

  testWidgets('a quick emoji goes into the text', (tester) async {
    await pump(tester);
    await tester.tap(find.text('🔥'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '🔥',
    );
  });

  testWidgets('the counter shows after 900 characters', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), 'a' * 899);
    await tester.pump();
    expect(find.text(l10nEn.commentsCounter(899)), findsNothing);
    await tester.enterText(find.byType(TextField), 'a' * 930);
    await tester.pump();
    expect(find.text(l10nEn.commentsCounter(930)), findsOneWidget);
  });

  testWidgets('replying to a top-level comment adds no @name', (tester) async {
    await pump(tester);
    cubit.startReply(_comment('c1', 'mariam.h'));
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.byType(CommentReplyingStrip), findsOneWidget);
  });

  testWidgets('Reply to someone else in a thread starts with @name', (
    tester,
  ) async {
    await pump(tester);
    cubit.startReply(_comment('c2', 'mariam.h', parentId: 'c1'));
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '@mariam.h ',
    );
    expect(find.textContaining('mariam.h'), findsWidgets);
    await tester.tap(
      find.descendant(
        of: find.byType(CommentReplyingStrip),
        matching: find.byType(InkResponse),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(cubit.state.replyTo, isNull);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('Arabic at 1.5x text fits', (tester) async {
    await pump(tester, locale: const Locale('ar'), textScale: 1.5);
    cubit.startReply(_comment('c1', 'mariam.h'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

CommentEntity _comment(String id, String username, {String? parentId}) =>
    CommentEntity(
      id: id,
      parentId: parentId,
      postId: 'p1',
      authorId: 'u2',
      username: username,
      body: 'hi',
      createdAt: DateTime.utc(2026, 10, 25),
      likeCount: 0,
      likedByMe: false,
      isPostAuthor: false,
      replyCount: 0,
    );

CommentEntity _saved() => _comment('new', 'sara.k');
