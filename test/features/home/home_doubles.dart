import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/activity/domain/use_case/get_unread_activity_count_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/home/presentation/cubit/bell_dot/bell_dot_cubit.dart';
import 'package:pulse/features/home/presentation/cubit/feed/feed_cubit.dart';
import 'package:pulse/features/home/presentation/cubit/post_publish/post_line_cubit.dart';
import 'package:pulse/features/home/presentation/cubit/post_publish/post_publish_cubit.dart';
import 'package:pulse/features/home/presentation/cubit/story_rail/story_rail_cubit.dart';
import 'package:pulse/features/post/domain/entity/feed_page_entity.dart';
import 'package:pulse/features/post/domain/use_case/delete_post_use_case.dart';
import 'package:pulse/features/post/domain/use_case/get_home_feed_use_case.dart';
import 'package:pulse/features/post/domain/use_case/hide_post_use_case.dart';
import 'package:pulse/features/post/domain/use_case/remove_my_tag_use_case.dart';
import 'package:pulse/features/post/domain/use_case/set_comments_enabled_use_case.dart';
import 'package:pulse/features/post/domain/use_case/set_post_like_use_case.dart';
import 'package:pulse/features/post/domain/use_case/set_post_save_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/post_actions/post_actions_cubit.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/use_case/discard_publish_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_publish_line_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_publish_status_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/retry_publish_use_case.dart';

import '../../helpers/content_mocks.dart';
import '../../helpers/pump_app.dart';
import '../post/post_fixtures.dart';

class _GetFeed extends Mock implements GetHomeFeedUseCase {}

class _Sign extends Mock implements SignPostMediaUrlsUseCase {}

class _CurrentUser extends Mock implements GetCurrentUserIdUseCase {}

class _Unread extends Mock implements GetUnreadActivityCountUseCase {}

class _GetRail extends Mock implements GetStoryRailUseCase {}

class _Like extends Mock implements SetPostLikeUseCase {}

class _Save extends Mock implements SetPostSaveUseCase {}

class _Hide extends Mock implements HidePostUseCase {}

class _Comments extends Mock implements SetCommentsEnabledUseCase {}

class _Delete extends Mock implements DeletePostUseCase {}

class _Follow extends Mock implements ToggleFollowUseCase {}

class _RemoveTag extends Mock implements RemoveMyTagUseCase {}

/// Home's cubits in get_it over use cases that answer a one-post feed (the empty page floats forever and
/// would never settle), an empty rail and nothing unread, for
/// tests that mount the Home screen without caring about it (the shell).
void registerHomeDoubles() {
  final getFeed = _GetFeed();
  final currentUser = _CurrentUser();
  final unread = _Unread();
  final getRail = _GetRail();
  when(() => getFeed(cursor: any(named: 'cursor')))
      .thenAnswer((_) async => FeedPageEntity(posts: [testPost('p1')]));
  when(currentUser.call).thenReturn('me');
  when(unread.call).thenAnswer((_) async => 0);
  when(getRail.call).thenAnswer((_) async => []);
  // Nothing is being sent.
  final publish = ContentPublishRepositoryImpl(
    EventBus(),
    FakeContentDiscards(),
    FakeConnectivity(),
  );
  getIt
    ..registerFactory(
      () => FeedCubit(getFeed, _Sign(), EventBus(), currentUser),
    )
    ..registerFactory(
      () => PostActionsCubit(
        _Like(),
        _Save(),
        _Hide(),
        _Comments(),
        _Delete(),
        MockReportContent(),
        MockSetMute(),
        _Follow(),
        _RemoveTag(),
      ),
    )
    ..registerFactory(
      () => PostPublishCubit(
        EventBus(),
        GetPublishStatusUseCase(publish),
        RetryPublishUseCase(publish),
        DiscardPublishUseCase(publish),
        okResumeContent(),
        okResumeSharedPosts(),
        currentUser,
        hasOpenPostDraft(),
      ),
    )
    ..registerFactory(
      () => PostLineCubit(EventBus(), GetPublishLineUseCase(publish)),
    )
    ..registerFactory(() => BellDotCubit(unread, EventBus()))
    ..registerFactory(
      () => StoryRailCubit(
        getRail,
        EventBus(),
        GetPublishStatusUseCase(publish),
        RetryPublishUseCase(publish),
      ),
    );
}
