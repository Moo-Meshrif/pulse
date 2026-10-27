import '../../../../../shared/content/data/enums/content_audience.dart';

/// What the Share sheet offers for a post (docs/specs/post/screens/s12-share-sheet.md, "Who sees the share
/// icon"): Public posts get everything, your own Followers post can go to your feed (with the same audience)
/// and your story, and the rest have no Share at all (the send icon and the options row are hidden).
enum ShareAccess {
  none,
  ownFollowers,
  full;

  factory ShareAccess.of({
    required ContentAudience visibility,
    required bool isMine,
  }) => switch (visibility) {
    ContentAudience.public => full,
    ContentAudience.followers when isMine => ownFollowers,
    _ => none,
  };

  bool get isShown => this != none;
}
