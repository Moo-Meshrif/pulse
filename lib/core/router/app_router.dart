import 'package:flutter/material.dart';

import '../enums/legal_document.dart';
import '../enums/signed_out_reason.dart';
import '../../features/auth/presentation/screen/forgot_password_screen.dart';
import '../../features/auth/presentation/cubit/sign_up_cubit.dart';
import '../../features/auth/presentation/screen/reset_password_screen.dart';
import '../../features/auth/presentation/screen/sign_in_screen.dart';
import '../../features/auth/presentation/screen/sign_up_screen.dart';
import '../../features/control_page/presentation/screen/control_page_screen.dart';
import '../../features/legal/presentation/screen/legal_screen.dart';
import '../../features/splash/presentation/screen/splash_screen.dart';
import '../../features/story/domain/entity/captured_story_media.dart';
import '../../features/story/data/enums/audience_list.dart';
import '../../features/story/presentation/screen/audience_list_screen.dart';
import '../../features/story/presentation/screen/story_camera_screen.dart';
import '../../features/story/presentation/screen/story_edit_screen.dart';
import '../../features/story/presentation/screen/story_viewer_screen.dart';
import '../../features/story/presentation/utils/story_page_route.dart';
import '../../features/story/domain/entity/story_viewer_args.dart';
import '../../features/onboarding/data/datasource/onboarding_datasource.dart';
import '../../features/onboarding/presentation/screen/onboarding_screen.dart';
import '../di/injection.dart';
import 'app_routes.dart';
import 'not_found_screen.dart';
import 'placeholder_screen.dart';

abstract final class AppRouter {
  /// Every route in the app is resolved here — from `pushNamed` calls and from deep links.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final path = Uri.parse(settings.name ?? AppRoutes.root).path;

    // `/story/:authorId`: the id is part of the path, so it cannot be a case of the switch below.
    if (path.startsWith(AppRoutes.storyPrefix) &&
        path.length > AppRoutes.storyPrefix.length) {
      // Not an ordinary page: it grows out of the tapped avatar (`arguments` says where and who).
      final authorId = path.substring(AppRoutes.storyPrefix.length);
      final args = settings.arguments is StoryViewerArgs
          ? settings.arguments as StoryViewerArgs
          : null;
      return StoryPageRoute<dynamic>(
        settings: settings,
        origin: args?.origin,
        builder: (_) =>
            StoryViewerScreen(authorId: authorId, person: args?.person),
      );
    }

    // TODO(story-plan T3): a placeholder until the profile screens exist.
    if (path.startsWith(AppRoutes.profilePrefix) &&
        path.length > AppRoutes.profilePrefix.length) {
      return _page(settings, PlaceholderScreen(route: path));
    }

    return switch (path) {
      AppRoutes.root => _root(settings),
      AppRoutes.onboarding => _page(settings, const OnboardingScreen()),
      AppRoutes.signIn => _page(
        settings,
        SignInScreen(
          reason: SignedOutReason.fromParam(
            Uri.parse(settings.name ?? AppRoutes.signIn)
                .queryParameters['reason'],
          ),
        ),
      ),
      AppRoutes.register => _register(settings),
      AppRoutes.forgotPassword => _page(settings, const ForgotPasswordScreen()),
      AppRoutes.resetPassword => _page(settings, const ResetPasswordScreen()),
      AppRoutes.terms ||
      AppRoutes.privacy ||
      AppRoutes.communityGuidelines ||
      AppRoutes.cookiePolicy ||
      AppRoutes.openSourceLicenses => _page(
        settings,
        LegalScreen(
          document: LegalDocument.values.firstWhere((d) => d.route == path),
        ),
      ),
      // The main shell (tabs + nav bar); sign-in, sign-up and the splash end here.
      AppRoutes.home => _page(settings, const ControlPageScreen()),
      // TODO(control-page-plan T7): New post placeholder until the post feature's New post screen
      // (docs/specs/post/screens/s1-new-post.md) is built.
      AppRoutes.createPost => _page(
        settings,
        const PlaceholderScreen(route: AppRoutes.createPost),
      ),
      // TODO(control-page-plan T8): New short placeholder until the shorts feature exists.
      AppRoutes.createShort => _page(
        settings,
        const PlaceholderScreen(route: AppRoutes.createShort),
      ),
      AppRoutes.audienceCloseFriends => _page(
        settings,
        const AudienceListScreen(list: AudienceList.closeFriends),
      ),
      AppRoutes.audienceHidden => _page(
        settings,
        const AudienceListScreen(list: AudienceList.hiddenFrom),
      ),
      AppRoutes.createStory => _page(settings, const StoryCameraScreen()),
      // The camera passes the captured media as the route argument; without it there is nothing to edit.
      AppRoutes.createStoryEdit => switch (settings.arguments) {
        final CapturedStoryMedia media => _page(
          settings,
          StoryEditScreen(media: media),
        ),
        _ => _page(settings, const NotFoundScreen()),
      },
      _ => _page(settings, const NotFoundScreen()),
    };
  }

  /// `/register?step=N&email=…` opens the sign-up flow at step N (default 1).
  static Route<dynamic> _register(RouteSettings settings) {
    final query = Uri.parse(settings.name ?? AppRoutes.register)
        .queryParameters;
    return _page(
      settings,
      SignUpScreen(
        step: int.tryParse(query['step'] ?? '') ?? SignUpCubit.firstStep,
        email: query['email'],
      ),
    );
  }

  /// First launch shows onboarding; afterwards the splash screen picks Sign in, Home or the sign-up step
  /// to resume from the stored session (it needs a request, so it cannot be decided here).
  static Route<dynamic> _root(RouteSettings settings) {
    final seen = getIt<OnboardingDatasource>().isSeen;
    return seen
        ? _page(settings, const SplashScreen())
        : onGenerateRoute(const RouteSettings(name: AppRoutes.onboarding));
  }

  /// A deep link must open exactly that screen, not every parent route before it.
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
    onGenerateRoute(RouteSettings(name: initialRoute)),
  ];

  static Route<T> _page<T>(RouteSettings settings, Widget screen) =>
      MaterialPageRoute<T>(settings: settings, builder: (_) => screen);
}
