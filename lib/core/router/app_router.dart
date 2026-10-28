import 'package:flutter/material.dart';

import '../../features/auth/presentation/cubit/sign_up/sign_up_cubit.dart';
import '../../features/auth/presentation/screen/forgot_password_screen.dart';
import '../../features/auth/presentation/screen/reset_password_screen.dart';
import '../../features/auth/presentation/screen/sign_in_screen.dart';
import '../../features/auth/presentation/screen/sign_up_screen.dart';
import '../../features/control/presentation/screen/control_screen.dart';
import '../../features/legal/presentation/screen/legal_screen.dart';
import '../../features/onboarding/data/datasource/onboarding_datasource.dart';
import '../../features/onboarding/presentation/screen/onboarding_screen.dart';
import '../../features/places/presentation/screen/add_location_screen.dart';
import '../../features/post/domain/entity/post_mood_entity.dart';
import '../../features/post/presentation/screen/add_edit_post_screen.dart';
import '../../features/post/presentation/screen/feeling_screen.dart';
import '../../features/post/presentation/screen/post_likes_screen.dart';
import '../../features/post/presentation/screen/post_page_screen.dart';
import '../../features/post/presentation/screen/tag_in_photo_screen.dart';
import '../../features/post/presentation/screen/tag_people_screen.dart';
import '../../features/post/presentation/utils/post_page_args.dart';
import '../../features/post/presentation/utils/tag_people_args.dart';
import '../../features/profile/data/enums/people_kind.dart';
import '../../features/profile/presentation/screen/language_screen.dart';
import '../../features/profile/presentation/screen/notifications_screen.dart';
import '../../features/profile/presentation/screen/people_screen.dart';
import '../../features/profile/presentation/screen/personal_info_screen.dart';
import '../../features/profile/presentation/screen/settings_screen.dart';
import '../../features/splash/presentation/screen/splash_screen.dart';
import '../../features/story/data/enums/audience_list.dart';
import '../../features/story/domain/entity/captured_story_media.dart';
import '../../features/story/domain/entity/story_viewer_args.dart';
import '../../features/story/presentation/screen/audience_list_screen.dart';
import '../../features/story/presentation/screen/story_camera_screen.dart';
import '../../features/story/presentation/screen/story_edit_screen.dart';
import '../../features/story/presentation/screen/story_post_edit_screen.dart';
import '../../features/story/presentation/screen/story_viewer_screen.dart';
import '../../features/story/presentation/utils/story_page_route.dart';
import '../di/injection.dart';
import '../enums/legal_document.dart';
import '../enums/signed_out_reason.dart';
import '../utils/story_post_args.dart';
import 'app_routes.dart';
import 'end_slide_page_route.dart';
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

    // `/p/:postId/likes`: who liked the post. Before the post page, whose id is the rest of the path.
    if (path.startsWith(AppRoutes.postPagePrefix) &&
        path.endsWith(AppRoutes.likesSuffix)) {
      final postId = path.substring(
        AppRoutes.postPagePrefix.length,
        path.length - AppRoutes.likesSuffix.length,
      );
      if (postId.isNotEmpty) {
        return _page(settings, PostLikesScreen(postId: postId));
      }
    }

    // `/p/:postId`: the post page; the post already loaded may come as `PostPageArgs`.
    if (path.startsWith(AppRoutes.postPagePrefix) &&
        path.length > AppRoutes.postPagePrefix.length) {
      final postId = path.substring(AppRoutes.postPagePrefix.length);
      final given = settings.arguments is PostPageArgs
          ? settings.arguments as PostPageArgs
          : null;
      final comment = Uri.parse(settings.name!).queryParameters['comment'];
      return _page(
        settings,
        PostPageScreen(
          args: PostPageArgs(
            postId: postId,
            post: given?.post,
            focusCommentId: comment ?? given?.focusCommentId,
            focusComposer: given?.focusComposer ?? false,
          ),
        ),
      );
    }

    // TODO(story-plan T3): a placeholder until the profile screens exist.
    if (path.startsWith(AppRoutes.profilePrefix) &&
        path.length > AppRoutes.profilePrefix.length) {
      return _page(settings, PlaceholderScreen(route: path));
    }

    // `/post/:postId/comments`: the post page with the comment field focused.
    if (path.startsWith(AppRoutes.postPrefix) &&
        path.endsWith(AppRoutes.commentsSuffix)) {
      final postId = path.substring(
        AppRoutes.postPrefix.length,
        path.length - AppRoutes.commentsSuffix.length,
      );
      if (postId.isNotEmpty) {
        return _page(
          settings,
          PostPageScreen(
            args: PostPageArgs(postId: postId, focusComposer: true),
          ),
        );
      }
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
      AppRoutes.home => _page(settings, const ControlScreen()),
      AppRoutes.createPost => _page(settings, const AddEditPostScreen()),
      AppRoutes.editPost => _page(
        settings,
        AddEditPostScreen(args: settings.arguments as AddEditPostArgs?),
      ),
      // The place already on the post comes in as the route argument.
      AppRoutes.pickPlace => _endSlidePage(
        settings,
        AddLocationScreen(current: settings.arguments as String?),
      ),
      // Tag people and Tag in photo take the chosen people and the post's media as the route argument.
      AppRoutes.tagPeople => _endSlidePage(
        settings,
        TagPeopleScreen(args: settings.arguments as TagPeopleArgs),
      ),
      AppRoutes.tagInPhoto => _endSlidePage(
        settings,
        TagInPhotoScreen(args: settings.arguments as TagPeopleArgs),
      ),
      // The mood the post has comes in as the route argument.
      AppRoutes.feeling => _endSlidePage(
        settings,
        FeelingScreen(current: settings.arguments as PostMoodEntity?),
      ),
      AppRoutes.settings => _page(settings, const SettingsScreen()),
      AppRoutes.settingsPersonalInfo => _page(
        settings,
        const PersonalInfoScreen(),
      ),
      AppRoutes.settingsNotifications => _page(
        settings,
        const NotificationsScreen(),
      ),
      AppRoutes.settingsLanguage => _page(settings, const LanguageScreen()),
      // These Settings pages stay placeholders until their phases of docs/plans/profile-plan.md.
      AppRoutes.settingsSecurity ||
      AppRoutes.settingsPrivacy ||
      AppRoutes.settingsBlocked ||
      AppRoutes.settingsHelp ||
      AppRoutes.settingsHelpTopic ||
      AppRoutes.settingsReport ||
      AppRoutes.settingsTerms => _page(
        settings,
        PlaceholderScreen(route: path),
      ),
      AppRoutes.people => _peoplePage(settings),
      // TODO(control-page-plan T8): New short placeholder until the shorts feature exists.
      AppRoutes.search ||
      AppRoutes.activity => _page(settings, PlaceholderScreen(route: path)),
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
      // The Share sheet passes the post as the route argument.
      AppRoutes.createStoryPost => switch (settings.arguments) {
        final StoryPostArgs post => _page(
          settings,
          StoryPostEditScreen(post: post),
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

  /// `/people?kind=followers|following|mutual&userId=…`; without both, nothing to show.
  static Route<dynamic> _peoplePage(RouteSettings settings) {
    final query = Uri.parse(settings.name ?? AppRoutes.people).queryParameters;
    final kind = PeopleKind.fromJson(query['kind']);
    final userId = query['userId'];
    if (kind == null || userId == null || userId.isEmpty) {
      return _page(settings, const NotFoundScreen());
    }
    return _page(settings, PeopleScreen(kind: kind, userId: userId));
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

  static Route<T> _endSlidePage<T>(RouteSettings settings, Widget screen) =>
      EndSlidePageRoute<T>(settings: settings, builder: (_) => screen);
}
