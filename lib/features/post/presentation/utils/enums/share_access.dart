import '../../../../../shared/content/data/enums/content_audience.dart';

/// What the Share sheet offers for a post (docs/specs/post/screens/s12-share-sheet.md, "Who sees the share
/// icon"): Public posts get everything, your own Followers post can only go to your story, and the rest
/// have no Share at all (the send icon and the options row are hidden).
enum ShareAccess {
  none,
  storyOnly,
  full;

  factory ShareAccess.of({
    required ContentAudience visibility,
    required bool isMine,
  }) => switch (visibility) {
    ContentAudience.public => full,
    ContentAudience.followers when isMine => storyOnly,
    _ => none,
  };

  bool get isShown => this != none;
}
