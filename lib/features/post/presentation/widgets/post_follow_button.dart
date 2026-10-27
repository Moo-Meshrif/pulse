import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../dimens/post_page_dimens.dart';

/// The Follow pill of the post page and the likes list: filled `primary` to follow, an outline once
/// [isFollowing] (tap to unfollow, no confirm). [semanticsLabel] says what a tap does; it defaults to [label].
class PostFollowButton extends StatelessWidget {
  const PostFollowButton({
    super.key,
    required this.label,
    required this.isFollowing,
    required this.onTap,
    this.semanticsLabel,
  });

  final String label;
  final bool isFollowing;
  final VoidCallback onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: PostPageDimens.followTapTarget,
          ),
          child: Center(
            child: Container(
              height: PostPageDimens.followHeight,
              padding: EdgeInsets.symmetric(
                horizontal: PostPageDimens.followSide,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFollowing ? Colors.transparent : colors.primary,
                borderRadius: BorderRadius.circular(
                  PostPageDimens.followHeight / 2,
                ),
                border: isFollowing ? Border.all(color: colors.border) : null,
              ),
              child: AppText(
                label,
                style: context.text.chip,
                color: isFollowing ? colors.textPrimary : colors.textOnPrimary,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
