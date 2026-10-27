import '../enums/signed_out_reason.dart';

abstract final class AppRoutes {
  /// Start route: resolved by the router to onboarding (first launch) or the splash screen, which picks Sign in, Home or a sign-up step.
  static const root = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';

  /// Sign in after a session ended: names the saved account and says why (S14).
  static String signInWith(SignedOutReason reason) =>
      Uri(path: signIn, queryParameters: {'reason': reason.name}).toString();

  /// Registration step 1 (Account).
  static const register = '/register';

  /// The sign-up flow opened at [step] (3 to 6), to resume it after the app was closed.
  static String registerAt(int step) =>
      Uri(path: register, queryParameters: {'step': '$step'}).toString();

  /// The sign-up flow at the Verify email step (2) for [email], e.g. when a sign-in finds the account
  /// unverified.
  static String verifyEmailAt(String email) => Uri(
    path: register,
    queryParameters: {'step': '2', 'email': email},
  ).toString();
  static const forgotPassword = '/forgot-password';

  /// Set a new password; opened by the emailed recovery link.
  static const resetPassword = '/reset-password';
  static const terms = '/terms';
  static const privacy = '/privacy';
  static const communityGuidelines = '/community-guidelines';
  static const cookiePolicy = '/cookie-policy';
  static const openSourceLicenses = '/open-source-licenses';
  static const home = '/home';

  /// Full-screen create flows pushed over the shell (the Create sheet's Post and Short rows).
  static const createPost = '/create/post';

  /// Edit one of your posts. Takes the `PostEntity` as its argument.
  static const editPost = '/edit/post';

  /// Choose a place for a post, a story or anything else that has a location. Takes the place already
  /// chosen as its argument and goes back with a `LocationChoice`.
  static const pickPlace = '/pick-place';

  /// Choose the people tagged in a post (S6). Takes `TagPeopleArgs`; goes back with the chosen `List<TagChoice>`.
  static const tagPeople = '/create/post/tag-people';

  /// Place the chosen people on the photos (S7). Takes `TagPeopleArgs`; goes back with the `List<TagChoice>`.
  static const tagInPhoto = '/create/post/tag-in-photo';

  /// Choose how you feel (S8). Takes the post's current `PostMoodEntity?`; goes back with a `MoodChoice`.
  static const feeling = '/create/post/feeling';
  static const createShort = '/create/short';

  /// Story viewer for one person's stories (`/story/:authorId`).
  static String storyOf(String authorId) => '$storyPrefix$authorId';
  static const storyPrefix = '/story/';

  /// A person's profile (`/profile/:userId`); a placeholder until the profile screens exist.
  static String profileOf(String userId) => '$profilePrefix$userId';
  static const profilePrefix = '/profile/';

  /// Search people and posts; a placeholder until it is specced.
  // TODO(home-plan H1): /search is not specced yet.
  static const search = '/search';

  /// Activity (follow requests, likes, comments); a placeholder until it is specced.
  // TODO(home-plan H2): /activity is not specced yet.
  static const activity = '/activity';

  /// One post on its own page (`/p/:postId`, with `?comment=:id` to put a comment first).
  static String postPage(String postId, {String? comment}) => comment == null
      ? '$postPagePrefix$postId'
      : '$postPagePrefix$postId?comment=$comment';
  static const postPagePrefix = '/p/';

  /// The people who liked a post (`/p/:postId/likes`).
  static String postLikes(String postId) =>
      '$postPagePrefix$postId$likesSuffix';
  static const likesSuffix = '/likes';

  /// A post's comments (`/post/:postId/comments`): the post page with the comment field focused.
  static String commentsOf(String postId) =>
      '$postPrefix$postId$commentsSuffix';
  static const postPrefix = '/post/';
  static const commentsSuffix = '/comments';

  /// The Close friends and Hide story from list screens (the Who can see this sheet opens them).
  static const audienceCloseFriends = '/audience/close-friends';
  static const audienceHidden = '/audience/hidden';

  /// Story camera, then its edit and share screen; pushed over the shell.
  static const createStory = '/create/story';
  static const createStoryEdit = '/create/story/edit';

  /// The story editor for a post sticker; the argument is a `StoryPostArgs`.
  static const createStoryPost = '/create/story/post';

  /// Settings and its pages, pushed in the Profile tab; placeholders until their phase of the profile plan.
  static const settings = '/settings';
  static const settingsPersonalInfo = '/settings/personal-info';
  static const settingsSecurity = '/settings/security';
  static const settingsPrivacy = '/settings/privacy';
  static const settingsBlocked = '/settings/blocked';
  static const settingsNotifications = '/settings/notifications';
  static const settingsLanguage = '/settings/language';
  static const settingsHelp = '/settings/help';
  static const settingsHelpTopic = '/settings/help/topic';
  static const settingsReport = '/settings/report';
  static const settingsTerms = '/settings/terms';

  /// A list of people (followers, following, mutual); takes `kind` and `userId` query values.
  static const people = '/people';

  /// The list of [kind] ('followers', 'following' or 'mutual') of the person [userId].
  static String peopleOf(String kind, String userId) =>
      '$people?kind=$kind&userId=${Uri.encodeQueryComponent(userId)}';
}
