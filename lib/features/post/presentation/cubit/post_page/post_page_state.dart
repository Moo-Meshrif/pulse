import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../../domain/entity/liked_by_preview_entity.dart';
import '../../utils/enums/post_page_status.dart';
import '../../utils/feed_post.dart';

part 'post_page_state.freezed.dart';

@freezed
abstract class PostPageState with _$PostPageState {
  const factory PostPageState({
    @Default(PostPageStatus.loading) PostPageStatus status,

    /// The post with its media links signed; the one passed in until the fresh one arrives.
    FeedPost? post,

    /// Where your follow of the author stands; null while unknown or on your own post.
    FollowStatus? follow,

    /// The "Liked by" row; null when nobody else liked the post or it is not read yet.
    LikedByPreviewEntity? likedBy,

    /// The signed-in user, so the post reads "You" and has no Follow chip.
    String? userId,

    /// One-shot: a refresh or a follow did not go through.
    Failure? failure,
  }) = _PostPageState;
}
