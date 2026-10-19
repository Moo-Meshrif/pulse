import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/services/media_picker_service.dart';
import '../../../../../core/services/video_thumbnail_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/utils/uuid_v4.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/use_case/get_privacy_use_case.dart';
import '../../../../../shared/content/domain/use_case/publish_content_use_case.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../../domain/entity/edit_post_entity.dart';
import '../../../domain/entity/new_post_entity.dart';
import '../../../domain/entity/post_entity.dart';
import '../../../domain/entity/post_mood_entity.dart';
import '../../../domain/entity/post_tag_entity.dart';
import '../../../domain/event/feed_refresh_requested.dart';
import '../../../domain/event/post_saved.dart';
import '../../../domain/use_case/create_post_use_case.dart';
import '../../../domain/use_case/sign_post_media_urls_use_case.dart';
import '../../../domain/use_case/update_post_use_case.dart';
import '../../utils/enums/new_post_notice.dart';
import '../../utils/media_intake.dart';
import '../../utils/new_post_limits.dart';
import '../../utils/post_media_paths.dart';
import '../../utils/post_media_tags.dart';
import '../../utils/post_visibility_result.dart';
import '../../utils/tag_choice.dart';
import '../../utils/tag_people_args.dart';
import 'add_edit_post_state.dart';

/// The Add post and Edit post screen (docs/specs/post/screens/s1-new-post.md, s5-edit-post.md): caption,
/// photos and videos, place, audience, comments switch and Share or Save. It edits [post] when given one.
/// Editing keeps the post's own media in [AddEditPostState.kept] and sends only what changed.
@injectable
class AddEditPostCubit extends BaseCubit<AddEditPostState>
    with EventCubitMixin<AddEditPostState> {
  AddEditPostCubit(
    this._createPost,
    this._updatePost,
    this._publish,
    this._events,
    this._signUrls,
    MediaPickerService picker,
    this._privacy,
    VideoThumbnailService thumbnails,
    GetLastAccountUseCase account,
    @factoryParam PostEntity? post,
    @factoryParam Map<String, String>? signedUrls,
  ) : _intake = MediaIntake(picker, thumbnails),
      me = account(),
      super(
        post == null
            ? AddEditPostState(postId: uuidV4())
            : AddEditPostState.editing(post, signedUrls),
      );

  final CreatePostUseCase _createPost;
  final UpdatePostUseCase _updatePost;
  final PublishContentUseCase _publish;
  final EventBus _events;

  @override
  EventBus get events => _events;
  final SignPostMediaUrlsUseCase _signUrls;
  final MediaIntake _intake;

  final GetPrivacyUseCase _privacy;

  /// Who is posting, for the author row; null when this device has no saved account.
  final LastAccountEntity? me;

  /// Adding starts from the audience the account uses for new posts; editing keeps the post's own and only
  /// learns the default for the chip. If it cannot be read the chip stays Public, and the server applies
  /// the account's own default.
  Future<void> loadDefaultVisibility() => run(
    _privacy.call,
    onSuccess: (privacy) => state.copyWith(
      visibility: state.isEditing
          ? state.visibility
          : privacy.defaultVisibility,
      defaultVisibility: privacy.defaultVisibility,
    ),
    onFailure: (_) => null,
  );

  /// Editing: signs the post's own photos and posters for the strip. Without links the strip draws plain
  /// tiles.
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

  /// The Tag people page closed with [tags] (their spots included).
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
    emit(
      state.copyWith(
        tags: PostMediaTags.withoutMedia(state.tags, index),
        kept: isKept ? PostMediaTags.without(state.kept, index) : state.kept,
        media: isKept
            ? state.media
            : PostMediaTags.without(state.media, index - keptCount),
      ),
    );
  }

  /// The picked files are on the strip at once; each is read in the background and replaced by its full
  /// version (a video that is too long or big is taken off again with a notice).
  Future<void> pickMedia() async {
    final room = NewPostLimits.maxMedia - state.mediaCount;
    if (room <= 0) {
      emit(state.copyWith(notice: NewPostNotice.mediaLimit));
      return;
    }
    final picked = await _intake.pick(room: room);
    if (picked.isEmpty) return;
    emit(state.copyWith(media: [...state.media, ...picked]));
    _intake.startReading(picked, _described);
  }

  void _described(DescribedMedia described) {
    final path = described.media.path;
    final index = state.media.indexWhere((item) => item.path == path);
    if (index < 0) return; // taken off while it was read
    final rejection = described.rejection;
    if (rejection != null) {
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
  }

  /// The picture the sending card shows: the first of the post's media, as a file on this device or, for
  /// an edited post's own media, a signed link. A video shows its frame; none gives the app logo.
  (String?, String?, String?) _preview() {
    final kept = state.kept.firstOrNull;
    if (kept != null) {
      final key = kept.isVideo ? kept.thumbPath : kept.path;
      return (null, state.urls[key], key);
    }
    final first = state.media.firstOrNull;
    if (first == null) return (null, null, null);
    return (first.isVideo ? state.posters[first.path] : first.path, null, null);
  }

  void clearNotice() => emit(state.copyWith(notice: null));

  /// Hands the post to the background sender and closes the screen; Home shows how it goes and offers Retry.
  /// Only one post is sent at a time. Files still being read are waited for by the sender, not the screen.
  void save() {
    if (!state.canSave) return;
    final original = state.original;
    final isStarted = original == null ? _publishNew() : _publishEdit(original);
    emit(
      isStarted
          ? state.copyWith(isSaved: true)
          : state.copyWith(notice: NewPostNotice.publishBusy),
    );
  }

  /// False when another post is still being sent.
  bool _publishNew() {
    final post = state;
    final (previewPath, previewUrl, previewCacheKey) = _preview();
    return _publish(
      kind: ContentKind.post,
      previewPath: previewPath,
      previewUrl: previewUrl,
      previewCacheKey: previewCacheKey,
      send: (report) async => _created(
        await _createPost(
          NewPostEntity(
            id: post.postId,
            caption: _captionOf(post),
            location: post.location,
            commentsEnabled: post.commentsEnabled,
            visibility: post.visibility,
            mood: post.mood,
            tags: _tagsOf(post),
            media: await _intake.readAll(post.media),
            authorUsername: me?.username,
            authorFullName: me?.fullName,
            authorAvatarUrl: me?.avatarUrl,
          ),
          onProgress: report,
        ),
      ),
    );
  }

  /// False when another post is still being sent.
  bool _publishEdit(PostEntity original) {
    final post = state;
    final (previewPath, previewUrl, previewCacheKey) = _preview();
    return _publish(
      kind: ContentKind.post,
      isEdit: true,
      previewPath: previewPath,
      previewUrl: previewUrl,
      previewCacheKey: previewCacheKey,
      send: (report) async => _updated(
        await _updatePost(
          EditPostEntity(
            id: post.postId,
            caption: _captionOf(post),
            location: post.location,
            kept: post.kept,
            added: await _intake.readAll(post.media),
            commentsEnabled: post.commentsEnabled,
            visibility: post.visibility,
            mood: post.mood,
            tags: _tagsOf(post),
          ),
          before: original,
          onProgress: report,
        ),
      ),
    );
  }

  String? _captionOf(AddEditPostState post) {
    final caption = post.caption.trim();
    return caption.isEmpty ? null : caption;
  }

  List<PostTagEntity> _tagsOf(AddEditPostState post) =>
      post.tags.map((tag) => tag.toTag()).toList();

  /// The feed shows a shared post at once; with no author to show it loads again.
  void _created(PostEntity? post) =>
      fire(post == null ? const FeedRefreshRequested() : PostSaved(post));

  void _updated(PostEntity post) => fire(PostSaved(post));
}
