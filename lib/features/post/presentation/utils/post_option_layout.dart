import 'enums/post_option.dart';
import 'post_options_data.dart';

/// Which options the sheet shows and in which group, for someone else's post or your own.
class PostOptionLayout {
  final List<PostOption> quick;
  final List<PostOption> groupA;
  final List<PostOption> groupB;

  const PostOptionLayout._(this.quick, this.groupA, this.groupB);

  factory PostOptionLayout.of(PostOptionsData data) {
    final quick = [
      PostOption.save,
      if (data.isPublic) PostOption.copyLink,
      if (data.shareAccess.isShown) PostOption.share,
    ];
    if (data.isMine) {
      return PostOptionLayout._(
        quick,
        [
          PostOption.edit,
          PostOption.changeAudience,
          if (!data.isOnlyMe) PostOption.toggleComments,
        ],
        const [PostOption.delete],
      );
    }
    return PostOptionLayout._(
      quick,
      [
        if (data.iAmTagged) PostOption.removeMyTag,
        PostOption.notInterested,
        PostOption.unfollow,
        PostOption.mute,
      ],
      const [PostOption.report],
    );
  }
}
