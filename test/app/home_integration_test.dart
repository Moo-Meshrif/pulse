import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/features/control/presentation/screen/control_screen.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/nav_item.dart';
import 'package:pulse/features/home/presentation/screen/home_screen.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/presentation/widgets/post_card.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';

import '../helpers/pump_app.dart';

/// Home inside the real shell, with the real wiring over doubles for the backend.
void main() {
  late MockAuthDatasource auth;
  late MockProfileDatasource profiles;
  late MockPostsDatasource posts;

  setUp(() {
    auth = MockAuthDatasource();
    profiles = MockProfileDatasource();
    posts = MockPostsDatasource();
    stubOnePostFeed(posts);
    when(() => auth.hasSession).thenReturn(true);
    when(() => auth.currentEmail).thenReturn(null);
    when(() => auth.recoveryActive).thenReturn(false);
    when(() => auth.recoverySignals).thenAnswer((_) => const Stream.empty());
    when(() => auth.sessionEnded).thenAnswer((_) => const Stream.empty());
    when(() => profiles.currentUserId).thenReturn('me');
    when(() => profiles.getProfile()).thenAnswer(
      (_) async =>
          const ProfileModel(id: 'me', signupStep: SignupStep.complete),
    );
  });

  Future<void> boot(WidgetTester tester) async {
    setUpView(tester);
    await tester.bootApp(
      prefs: {'onboarding_seen': true},
      auth: auth,
      profiles: profiles,
      configure: () async {
        await getIt.unregister<PostsDatasource>();
        getIt.registerSingleton<PostsDatasource>(posts);
      },
    );
  }

  /// Checks (and uses up) the feed loads since the last check.
  void expectFeedLoads(int times) => verify(
    () => posts.getHomeFeed(
      limit: any(named: 'limit'),
      beforeCreated: any(named: 'beforeCreated'),
      beforeId: any(named: 'beforeId'),
    ),
  ).called(times);

  testWidgets(
    'a signed-in start lands on the shell with the feed and the rail',
    (tester) async {
      await boot(tester);
      expect(find.byType(ControlScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(PostCard), findsOneWidget);
      expect(find.text(l10nEn.storyYourStory), findsOneWidget);
    },
  );

  testWidgets('tapping Home while it is open loads the feed again', (
    tester,
  ) async {
    await boot(tester);
    expectFeedLoads(1);

    await tester.tap(
      find.byWidgetPredicate((w) => w is NavItem && w.label == l10nEn.navHome),
    );
    await tester.pumpAndSettle();
    expectFeedLoads(1);
  });
}
