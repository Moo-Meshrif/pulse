import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/events/event_bus.dart';
import '../../../../core/events/event_cubit_mixin.dart';
import '../../../../core/services/media_picker_service.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/domain/use_case/get_privacy_use_case.dart';
import '../../../../shared/content/domain/use_case/publish_content_use_case.dart';
import '../../../profile/domain/entity/last_account_entity.dart';
import '../../../profile/domain/use_case/get_last_account_use_case.dart';
import '../../domain/entity/edit_post_entity.dart';
import '../../domain/entity/new_post_entity.dart';
import '../../domain/entity/new_post_media_entity.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/entity/post_mood_entity.dart';
import '../../domain/event/feed_refresh_requested.dart';
import '../../domain/event/post_saved.dart';
import '../../domain/use_case/create_post_use_case.dart';
import '../../domain/use_case/sign_post_media_urls_use_case.dart';
import '../../domain/use_case/update_post_use_case.dart';
import '../utils/enums/new_post_notice.dart';
import '../utils/media_intake.dart';
import '../utils/new_post_limits.dart';
import '../utils/post_visibility_result.dart';
import '../utils/tag_choice.dart';
import '../utils/tag_people_args.dart';
import '../utils/tag_photo.dart';
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

  /// A photo whose size is unknown is shared as this square.
  static const _fallbackSide = 1080;

  final CreatePostUseCase _createPost;
  final UpdatePostUseCase _updatePost;
  final PublishContentUseCase _publish;
  final EventBus _events;

  @override
  EventBus get events => _events;
  final SignPostMediaUrlsUseCase _signUrls;
  final MediaIntake _intake;

  /// Each picked file being read, by path; the sender waits for them.
  final _details = <String, Future<DescribedMedia>>{};
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
      () => _signUrls([
        for (final item in state.kept) ...[item.path, ?item.thumbPath],
      ]),
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
    photos: [
      for (final (i, item) in state.kept.indexed)
        TagPhoto(
          position: i,
          isVideo: item.isVideo,
          url: state.urls[item.isVideo ? item.thumbPath : item.path],
          aspect: item.width / item.height,
        ),
      for (final (i, item) in state.media.indexed)
        TagPhoto(
          position: state.kept.length + i,
          isVideo: item.isVideo,
          filePath: item.isVideo ? null : item.path,
          aspect: _aspectOf(item),
        ),
    ],
  );

  double _aspectOf(PickedMedia item) {
    final width = item.width;
    final height = item.height;
    return width == null || height == null || height == 0 ? 1 : width / height;
  }

  /// The tags once the media at [index] is gone: its spots are off (those people stay tagged in the post)
  /// and the photos after it move up one.
  List<TagChoice> _tagsWithoutMedia(int index) => [
    for (final tag in state.tags)
      if (tag.mediaPosition == index)
        tag.withoutSpot()
      else if (tag.mediaPosition != null && tag.mediaPosition! > index)
        tag.withSpot(tag.mediaPosition! - 1, tag.x ?? 0, tag.y ?? 0)
      else
        tag,
  ];

  /// Removes the item at [index] of the strip: the post's own media first, then the picked files.
  void removeMedia(int index) {
    final keptCount = state.kept.length;
    if (index < keptCount) {
      emit(
        state.copyWith(
          tags: _tagsWithoutMedia(index),
          kept: [
            for (final (i, item) in state.kept.indexed)
              if (i != index) item,
          ],
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        tags: _tagsWithoutMedia(index),
        media: [
          for (final (i, item) in state.media.indexed)
            if (i != index - keptCount) item,
        ],
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
    for (final item in picked) {
      final details = _intake.describe(item);
      _details[item.path] = details;
      unawaited(details.then(_described));
    }
  }

  void _described(DescribedMedia described) {
    final path = described.media.path;
    final index = state.media.indexWhere((item) => item.path == path);
    if (index < 0) return; // taken off while it was read
    final media = [...state.media];
    if (described.rejection != null) {
      emit(
        state.copyWith(
          tags: _tagsWithoutMedia(state.kept.length + index),
          media: media..removeAt(index),
          notice: described.rejection,
        ),
      );
      return;
    }
    final poster = described.poster;
    emit(
      state.copyWith(
        media: media..[index] = described.media,
        posters: {...state.posters, path: ?poster},
      ),
    );
  }

  void clearNotice() => emit(state.copyWith(notice: null));

  /// Hands the post to the background sender and closes the screen; Home shows how it goes and offers Retry.
  /// Only one post is sent at a time. Files still being read are waited for by the sender, not the screen.
  void save() {
    if (!state.canSave) return;
    final picked = state.media;
    final original = state.original;
    final postId = state.postId;
    final caption = state.caption.trim();
    final location = state.location;
    final commentsEnabled = state.commentsEnabled;
    final visibility = state.visibility;
    final kept = state.kept;
    final tags = [for (final tag in state.tags) tag.toTag()];
    final mood = state.mood;
    final previewPath = picked.firstOrNull?.path;
    final isStarted = original == null
        ? _publish(
            kind: ContentKind.post,
            previewPath: previewPath,
            send: (report) async => _created(
              await _createPost(
                NewPostEntity(
                  id: postId,
                  caption: caption.isEmpty ? null : caption,
                  location: location,
                  commentsEnabled: commentsEnabled,
                  visibility: visibility,
                  mood: mood,
                  tags: tags,
                  media: await _read(picked),
                  authorUsername: me?.username,
                  authorFullName: me?.fullName,
                  authorAvatarUrl: me?.avatarUrl,
                ),
                onProgress: report,
              ),
            ),
          )
        : _publish(
            kind: ContentKind.post,
            isEdit: true,
            previewPath: previewPath,
            send: (report) async => _updated(
              await _updatePost(
                EditPostEntity(
                  id: postId,
                  caption: caption.isEmpty ? null : caption,
                  location: location,
                  kept: kept,
                  added: await _read(picked),
                  commentsEnabled: commentsEnabled,
                  visibility: visibility,
                  mood: mood,
                  tags: tags,
                ),
                before: original,
                onProgress: report,
              ),
            ),
          );
    emit(
      isStarted
          ? state.copyWith(isSaved: true)
          : state.copyWith(notice: NewPostNotice.publishBusy),
    );
  }

  /// The feed shows a shared post at once; with no author to show it loads again.
  void _created(PostEntity? post) =>
      fire(post == null ? const FeedRefreshRequested() : PostSaved(post));

  void _updated(PostEntity post) => fire(PostSaved(post));

  /// The files for the sender: each one once it is fully read, without the ones that cannot go in a post.
  Future<List<NewPostMediaEntity>> _read(List<PickedMedia> picked) async {
    final described = await Future.wait([
      for (final item in picked)
        _details[item.path] ?? Future.value(DescribedMedia(item)),
    ]);
    return [
      for (final item in described)
        if (item.rejection == null)
          NewPostMediaEntity(
            filePath: item.media.path,
            isVideo: item.media.isVideo,
            width: item.media.width ?? _fallbackSide,
            height: item.media.height ?? _fallbackSide,
            durationMs: item.media.isVideo
                ? (item.media.durationMs ?? 0)
                : null,
            blurhash: item.media.blurhash,
          ),
    ];
  }
}
