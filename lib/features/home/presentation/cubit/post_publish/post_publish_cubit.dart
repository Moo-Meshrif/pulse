import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/entity/content_publish_status.dart';
import '../../../../../shared/content/domain/use_case/discard_publish_use_case.dart';
import '../../../../../shared/content/domain/use_case/get_publish_status_use_case.dart';
import '../../../../../shared/content/domain/use_case/resume_content_use_case.dart';
import '../../../../../shared/content/domain/use_case/retry_publish_use_case.dart';
import '../../../../post/domain/use_case/has_open_post_draft_use_case.dart';
import '../../../../post/domain/use_case/resume_shared_posts_use_case.dart';
import '../../../../profile/domain/use_case/get_current_user_id_use_case.dart';

/// How the post being shared or saved is going, for the banner above the feed; also a discard waiting
/// for the connection. Home is where sending resumes: when it opens (after a start or a sign-in) and
/// when the app comes back.
@injectable
class PostPublishCubit extends BaseCubit<ContentPublishStatus>
    with EventCubitMixin<ContentPublishStatus> {
  PostPublishCubit(
    this._events,
    GetPublishStatusUseCase status,
    this._retry,
    this._discard,
    this._resumeContent,
    this._resumePosts,
    this._currentUserId,
    this._hasOpenDraft,
  ) : super(status(ContentKind.post));

  final EventBus _events;
  final RetryPublishUseCase _retry;
  final DiscardPublishUseCase _discard;
  final ResumeContentUseCase _resumeContent;
  final ResumeSharedPostsUseCase _resumePosts;
  final GetCurrentUserIdUseCase _currentUserId;
  final HasOpenPostDraftUseCase _hasOpenDraft;
  bool _started = false;

  @override
  EventBus get events => _events;

  /// The app was closed while a New post draft was open: New post opens with it again.
  bool get hasOpenDraft => _hasOpenDraft();

  /// Follows the status; a post already being sent shows from the first frame. Another user's sending is
  /// dropped, and what this user left unfinished (shared posts, discards) goes on.
  void start() {
    if (_started) return;
    _started = true;
    syncState<ContentPublishStatus>(
      (_, status) => status.kind == ContentKind.post ? status : null,
    );
    // The account is switched before the posts are sent again, or they would be dropped with it.
    final content = _resumeContent(_currentUserId());
    unawaited(_resumePosts());
    unawaited(content);
  }

  /// The app came back: a send that failed for the connection goes again, and saved discards finish.
  void resume() => unawaited(_resumeContent(_currentUserId()));

  /// Sends the failed post [id] again.
  void retry(String id) => _retry(ContentKind.post, id: id);

  /// Drops the failed post [id].
  void discard(String id) => _discard(ContentKind.post, id: id);
}
