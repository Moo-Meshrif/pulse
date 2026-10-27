import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../cubit/post_page/post_page_cubit.dart';
import '../../cubit/post_page/post_page_state.dart';
import '../../dimens/post_page_dimens.dart';
import '../post_follow_button.dart';

/// Follow the author from the post page: filled "Follow", then "Following" in outline (tap to unfollow, no
/// confirm). Not drawn on your own post.
class PostFollowChip extends StatelessWidget {
  const PostFollowChip({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        PostPageCubit,
        PostPageState,
        ({bool isMine, FollowStatus? follow})
      >(
        selector: (state) => (
          isMine: state.post?.entity.authorId == state.userId,
          follow: state.follow,
        ),
        builder: (context, data) {
          if (data.isMine) return const SizedBox.shrink();
          final isFollowing =
              data.follow == FollowStatus.accepted ||
              data.follow == FollowStatus.pending;
          final label = isFollowing
              ? context.l10n.postFollowing
              : context.l10n.postFollow;
          return Padding(
            padding: EdgeInsetsDirectional.only(end: PostPageDimens.followGap),
            child: PostFollowButton(
              label: label,
              isFollowing: isFollowing,
              onTap: context.read<PostPageCubit>().toggleFollow,
            ),
          );
        },
      );
}
