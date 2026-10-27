import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart' show Change;
import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/services/media_picker_service.dart';
import '../../../../../core/services/video_thumbnail_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/utils/uuid_v4.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/data/enums/media_upload_status.dart';
import '../../../../../shared/content/domain/use_case/get_privacy_use_case.dart';
import '../../../../../shared/content/domain/use_case/publish_content_use_case.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../../data/repository/post_draft_repository.dart';
import '../../../data/repository/post_repository.dart';
import '../../../domain/entity/post_entity.dart';
import '../../../domain/entity/post_mood_entity.dart';
import '../../../domain/event/feed_refresh_requested.dart';
import '../../../domain/event/post_saved.dart';
import '../../../domain/use_case/sign_post_media_urls_use_case.dart';
import '../../utils/enums/new_post_notice.dart';
import '../../utils/media_intake.dart';
import '../../utils/new_post_limits.dart';
import '../../utils/post_draft_mapping.dart';
import '../../utils/post_media_paths.dart';
import '../../utils/post_media_tags.dart';
import '../../utils/post_submission.dart';
import '../../utils/post_visibility_result.dart';
import '../../utils/tag_choice.dart';
import '../../utils/tag_people_args.dart';
import 'add_edit_post_state.dart';

/// The Add post and Edit post screen (docs/specs/post/screens/s1-new-post.md, s5-edit-post.md). It edits
/// [post] when given one: the post's own media stays in [AddEditPostState.kept] and only changes are sent.
/// Adding works on the draft ([PostDraftRepository]): saved on every change, each picked file uploaded
/// once it is read, forgotten when the post is shared or discarded.
@injectable
class AddEditPostCubit extends BaseCubit<AddEditPostState>
    with EventCubitMixin<AddEditPostState> {
  AddEditPostCubit(
    this._posts,
    this._publish,
    this._events,
    this._signUrls,
    MediaPickerService picker,
    this._privacy,
    VideoThumbnailService thumbnails,
    GetLastAccountUseCase account,
    this._draft,
    @factoryParam PostEntity? post,
    @factoryParam Map<String, String>? signedUrls,
  ) : _intake = MediaIntake(picker, thumbnails),
      me = account(),
      super(
        post == null
            ? PostDraftMapping.toState(_draft.read()) ??
                  AddEditPostState(postId: uuidV4())
            : AddEditPostState.editing(post, signedUrls),
      ) {
    _uploadChanges = _draft.uploadChanges.listen(_uploadChanged);
    _resumeRestored();
  }

  final PostRepository _posts;
  final PublishContentUseCase _publish;
  final EventBus _events;

  @override
  EventBus get events => _events;
  final SignPostMediaUrlsUseCase _signUrls;
  final MediaIntake _intake;

  final GetPrivacyUseCase _privacy;
  final PostDraftRepository _draft;

  StreamSubscription<(String, MediaUploadStatus)>? _uploadChanges;

  /// Who is posting, for the author row; null when this device has no saved account.
  final LastAccountEntity? me;

  /// Adding starts from the audience the account uses for new posts; editing keeps the post's own and only
  /// learns the default for the chip. If it cannot be read the chip stays Public, and the server applies
  /// the account's own default.
  Future<void> loadDefaultVisibility() => run(
    _privacy.call,
    onSuccess: (privacy) => state.copyWith(
      visibility: state.isEditing || state.fromDraft
          ? state.visibility
          : privacy.defaultVisibility,
      defaultVisibility: privacy.defaultVisibility,
    ),
    onFailure: (_) => null,
  );

  /// Editing: signs the post's own media for the strip; without links it draws plain tiles.
  Future<void> loadUrls() {
    if (state.urls.isNotEmpty) return Future.value();
    return run(
      () => _signUrls(state.kept.pathsToSign),
      prevent: !state.isEditing,
      onSuccess: (urls) => state.copyWith(urls: urls),
      onFailure: (_) => null,
    );
  }

  void captionChanged(String caption) => emit(state.copyWith(caption: caption));

  /// The picker closed with [result]. When it saved the audience as the default, that is the new default.
  void audienceChosen(PostVisibilityResult result) => emit(
    state.copyWith(
      visibility: result.audience,
      defaultVisibility: result.savedAsDefault
          ? result.audience
          : state.defaultVisibility,
    ),
  );

  void commentsChanged(bool enabled) =>
      emit(state.copyWith(commentsEnabled: enabled));

  void locationChanged(String? location) =>
      emit(state.copyWith(location: location));

  /// The Feeling page closed with [mood]; null clears it.
  void moodChanged(PostMoodEntity? mood) => emit(state.copyWith(mood: mood));

  void tagsChanged(List<TagChoice> tags) => emit(state.copyWith(tags: tags));

  /// What the tag pages open with: who is tagged and the post's media in the order it will have.
  TagPeopleArgs get tagArgs => TagPeopleArgs(
    chosen: state.tags,
    photos: PostMediaTags.photos(
      kept: state.kept,
      media: state.media,
      urls: state.urls,
    ),
  );

  /// Removes the item at [index] of the strip: the post's own media first, then the picked files.
  void removeMedia(int index) {
    final keptCount = state.kept.length;
    final isKept = index < keptCount;
    final removedPath = isKept ? null : state.media[index - keptCount].path;
    if (removedPath != null && !state.isEditing) {
      _draft.remove(removedPath, poster: state.posters[removedPath]);
    }
    emit(
      state.copyWith(
        tags: PostMediaTags.withoutMedia(state.tags, index),
        kept: isKept ? PostMediaTags.without(state.kept, index) : state.kept,
        media: isKept
            ? state.media
            : PostMediaTags.without(state.media, index - keptCount),
        mediaIds: {...state.mediaIds}..remove(removedPath),
        failedUploads: {...state.failedUploads}..remove(removedPath),
      ),
    );
  }

  void retryUpload(String path) {
    if (!state.failedUploads.contains(path)) return;
    _draft.retry(path);
  }

  /// Picked files show on the strip at once and are read in the background; a video that is too long or
  /// big is taken off again with a notice.
  Future<void> pickMedia() async {
    final room = NewPostLimits.maxMedia - state.mediaCount;
    if (room <= 0) {
      emit(state.copyWith(notice: NewPostNotice.mediaLimit));
      return;
    }
    final picked = await _intake.pick(room: room);
    if (picked.isEmpty) return;
    if (state.isEditing) {
      emit(state.copyWith(media: [...state.media, ...picked]));
      _intake.startReading(picked, _described);
      return;
    }
    final kept = await _draft.keepPicked(state.postId, picked);
    emit(
      state.copyWith(
        media: [...state.media, ...kept],
        mediaIds: {
          ...state.mediaIds,
          for (final item in kept) item.path: uuidV4(),
        },
      ),
    );
    _intake.startReading(kept, _described);
  }

  void _described(DescribedMedia described) {
    final path = described.media.path;
    final index = state.media.indexWhere((item) => item.path == path);
    if (index < 0) return; // taken off while it was read
    final rejection = described.rejection;
    if (rejection != null) {
      if (!state.isEditing) _draft.remove(path, poster: state.posters[path]);
      emit(
        state.copyWith(
          tags: PostMediaTags.withoutMedia(
            state.tags,
            state.kept.length + index,
          ),
          media: PostMediaTags.without(state.media, index),
          notice: rejection,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        media: state.media
            .map((item) => item.path == path ? described.media : item)
            .toList(),
        posters: {...state.posters, path: ?described.poster},
      ),
    );
    if (state.isEditing) return;
    final poster = described.poster;
    if (poster == null) {
      _upload(described.media);
    } else {
      unawaited(_keepPosterThenUpload(described.media, poster));
    }
  }

  /// Moves a video's frame into the draft's folder (the tile keeps the temporary frame if that fails),
  /// then uploads the video.
  Future<void> _keepPosterThenUpload(PickedMedia media, String poster) async {
    final kept = await _draft.keepPoster(state.postId, poster);
    final isOnStrip = state.media.any((item) => item.path == media.path);
    if (!isOnStrip) {
      if (kept != null) _draft.deleteFile(kept);
      return; // taken off meanwhile
    }
    if (kept != null) {
      emit(state.copyWith(posters: {...state.posters, media.path: kept}));
    }
    _upload(media, poster: kept ?? poster);
  }

  void _upload(PickedMedia media, {String? poster}) {
    final id = state.mediaIds[media.path];
    if (id != null) _draft.upload(state.postId, id, media, poster: poster);
  }

  void _uploadChanged((String, MediaUploadStatus) change) {
    final (path, status) = change;
    final isFailed = status == MediaUploadStatus.failed;
    if (isFailed == state.failedUploads.contains(path)) return;
    emit(
      state.copyWith(
        failedUploads: isFailed
            ? {...state.failedUploads, path}
            : ({...state.failedUploads}..remove(path)),
      ),
    );
  }

  void clearNotice() => emit(state.copyWith(notice: null));

  /// Hands the post to the background sender and closes the screen; Home shows progress and Retry. Files
  /// still being read are waited for by the sender. A second tap while the screen closes does nothing.
  void save() {
    if (!state.canSave || state.isSaved) return;
    final original = state.original;
    final isStarted = original == null ? _publishNew() : _publishEdit(original);
    emit(
      isStarted
          ? state.copyWith(isSaved: true)
          : state.copyWith(notice: NewPostNotice.publishBusy),
    );
  }

  /// False when another post is still being sent. Once handed over it is a shared post, not a draft, so
  /// it goes out even if the app closes.
  bool _publishNew() {
    final post = state;
    return _draft.share(
      PostDraftMapping.toModel(post),
      previewPath: PostSubmission.preview(post).path,
      build: () async => PostSubmission.newPost(
        post,
        media: await _intake.readAll(
          post.media,
          ids: post.mediaIds,
          posters: post.posters,
        ),
        me: me,
      ),
    );
  }

  /// False when another post is still being sent.
  bool _publishEdit(PostEntity original) {
    final post = state;
    final preview = PostSubmission.preview(post);
    return _publish(
      kind: ContentKind.post,
      isEdit: true,
      previewPath: preview.path,
      previewUrl: preview.url,
      previewCacheKey: preview.cacheKey,
      send: (report) async {
        final added = await _intake.readAll(post.media);
        final updated = await _posts.updatePost(
          PostSubmission.edit(post, added: added),
          before: original,
          onProgress: report,
        );
        _updated(updated);
      },
    );
  }

  /// Save draft: the screen is closing, so the draft is not opened again at start.
  Future<void> saveDraft() => state.isEditing
      ? Future.value()
      : _draft.saveNow(PostDraftMapping.toSaved(state), isOpen: false);

  /// The app went to the background: saved now and still open, so a kill reopens New post with it.
  Future<void> saveDraftOpen() => state.isEditing
      ? Future.value()
      : _draft.saveNow(PostDraftMapping.toSaved(state));

  /// Discard post. Completes once the discard is saved; the server is told in the background.
  Future<void> discardDraft() => run(
    () => _draft.discard(state.postId),
    onSuccess: (_) => null,
    onFailure: (_) => null,
  );

  @override
  void onChange(Change<AddEditPostState> change) {
    super.onChange(change);
    final next = change.nextState;
    if (next.isEditing) return;
    if (!PostDraftMapping.differs(change.currentState, next)) return;
    _draft.saveSoon(PostDraftMapping.toSaved(next));
  }

  @override
  Future<void> close() {
    unawaited(_uploadChanges?.cancel());
    _draft.close();
    return super.close();
  }

  /// A restored draft uploads only what is not on the server yet; unread files are read first.
  void _resumeRestored() {
    if (state.isEditing || state.media.isEmpty) return;
    final unread = state.media.where((item) => item.width == null).toList();
    if (unread.isNotEmpty) _intake.startReading(unread, _described);
    for (final item in state.media.where((item) => item.width != null)) {
      _upload(item, poster: state.posters[item.path]);
    }
  }

  /// Null when the post was saved but could not be read back: the feed and post page load it again.
  void _updated(PostEntity? post) =>
      fire(post == null ? const FeedRefreshRequested() : PostSaved(post));
}
