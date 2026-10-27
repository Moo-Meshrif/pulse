import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/post/presentation/screen/post_likes_screen.dart';
import 'package:pulse/features/post/presentation/screen/post_page_screen.dart';
import 'package:pulse/features/post/presentation/utils/feed_post.dart';
import 'package:pulse/features/post/presentation/utils/post_page_args.dart';

import '../../features/post/post_fixtures.dart';

void main() {
  Future<Widget> open(
    WidgetTester tester,
    String name, {
    Object? arguments,
  }) async {
    late Widget screen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final route = AppRouter.onGenerateRoute(
              RouteSettings(name: name, arguments: arguments),
            );
            screen = (route as MaterialPageRoute<dynamic>).builder(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return screen;
  }

  test('postPage builds the path, with the comment when given', () {
    expect(AppRoutes.postPage('p1'), '/p/p1');
    expect(AppRoutes.postPage('p1', comment: 'c9'), '/p/p1?comment=c9');
  });

  testWidgets('/p/:id opens the post page for that post', (tester) async {
    final screen = await open(tester, '/p/p1') as PostPageScreen;
    expect(screen.args.postId, 'p1');
    expect(screen.args.focusCommentId, isNull);
    expect(screen.args.post, isNull);
  });

  testWidgets('/p/:id?comment= puts that comment first', (tester) async {
    final screen = await open(
      tester,
      AppRoutes.postPage('p1', comment: 'c9'),
    ) as PostPageScreen;
    expect(screen.args.postId, 'p1');
    expect(screen.args.focusCommentId, 'c9');
  });

  testWidgets('the loaded post and the field focus come as arguments', (
    tester,
  ) async {
    final post = FeedPost(entity: testPost('p1'), media: const []);
    final screen = await open(
      tester,
      '/p/p1',
      arguments: PostPageArgs(postId: 'p1', post: post, focusComposer: true),
    ) as PostPageScreen;
    expect(screen.args.post, post);
    expect(screen.args.focusComposer, isTrue);
  });

  test('postLikes builds the path', () {
    expect(AppRoutes.postLikes('p1'), '/p/p1/likes');
  });

  testWidgets('/p/:id/likes opens the likes list, not a post page', (
    tester,
  ) async {
    final screen = await open(tester, AppRoutes.postLikes('p1'));
    expect(screen, isA<PostLikesScreen>());
    expect((screen as PostLikesScreen).postId, 'p1');
  });

  testWidgets('/post/:id/comments opens the post page with the field focused', (
    tester,
  ) async {
    final screen =
        await open(tester, AppRoutes.commentsOf('p1')) as PostPageScreen;
    expect(screen.args.postId, 'p1');
    expect(screen.args.focusComposer, isTrue);
  });
}
