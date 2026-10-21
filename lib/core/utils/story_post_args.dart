import 'equatable.dart';

/// A post as a story's sticker draws it: who posted it, the first words and the first picture (a video's
/// poster frame). The Share sheet hands it to the story editor, which saves only [postId]; the rest is for
/// drawing.
class StoryPostArgs extends Equatable {
  final String postId;
  final String username;
  final String? avatarUrl;
  final String? caption;

  /// A signed link to the first photo, or to the poster of a first video; null for a post without media.
  final String? mediaUrl;

  /// What keeps [mediaUrl]'s picture cached when the link changes (its storage path).
  final String? mediaCacheKey;

  /// Width over height of the first media.
  final double? mediaAspect;

  const StoryPostArgs({
    required this.postId,
    required this.username,
    this.avatarUrl,
    this.caption,
    this.mediaUrl,
    this.mediaCacheKey,
    this.mediaAspect,
  });

  @override
  List<Object?> get props => [
    postId,
    username,
    avatarUrl,
    caption,
    mediaUrl,
    mediaCacheKey,
    mediaAspect,
  ];
}
