import '../../../profile/domain/entity/last_account_entity.dart';
import '../../domain/entity/edit_post_entity.dart';
import '../../domain/entity/new_post_entity.dart';
import '../../domain/entity/new_post_media_entity.dart';
import '../../domain/entity/post_tag_entity.dart';
import '../cubit/add_edit_post/add_edit_post_state.dart';

/// The picture the sending card shows: a file on this device ([path]) or a signed link ([url], cached
/// under [cacheKey]); all null gives the app logo.
typedef SendingPreview = ({String? path, String? url, String? cacheKey});

/// What Share and Save send, built from the screen.
abstract final class PostSubmission {
  /// [state] as a new post; [me] is the author the feed shows at once.
  static NewPostEntity newPost(
    AddEditPostState state, {
    required List<NewPostMediaEntity> media,
    LastAccountEntity? me,
  }) => NewPostEntity(
    id: state.postId,
    caption: _caption(state),
    location: state.location,
    commentsEnabled: state.commentsEnabled,
    visibility: state.visibility,
    mood: state.mood,
    tags: _tags(state),
    media: media,
    authorUsername: me?.username,
    authorFullName: me?.fullName,
    authorAvatarUrl: me?.avatarUrl,
  );

  /// [state] as the changes to its post; [added] are the files picked now.
  static EditPostEntity edit(
    AddEditPostState state, {
    required List<NewPostMediaEntity> added,
  }) => EditPostEntity(
    id: state.postId,
    caption: _caption(state),
    location: state.location,
    kept: state.kept,
    added: added,
    commentsEnabled: state.commentsEnabled,
    visibility: state.visibility,
    mood: state.mood,
    tags: _tags(state),
  );

  /// The first of the post's media: an edited post's own media by signed link, a picked file from the
  /// device. A video shows its frame.
  static SendingPreview preview(AddEditPostState state) {
    final kept = state.kept.firstOrNull;
    if (kept != null) {
      final key = kept.isVideo ? kept.thumbPath : kept.path;
      return (path: null, url: state.urls[key], cacheKey: key);
    }
    final first = state.media.firstOrNull;
    final path = first == null
        ? null
        : (first.isVideo ? state.posters[first.path] : first.path);
    return (path: path, url: null, cacheKey: null);
  }

  static String? _caption(AddEditPostState state) {
    final caption = state.caption.trim();
    return caption.isEmpty ? null : caption;
  }

  static List<PostTagEntity> _tags(AddEditPostState state) =>
      state.tags.map((tag) => tag.toTag()).toList();
}
