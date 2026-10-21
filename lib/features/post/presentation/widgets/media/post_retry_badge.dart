import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/widgets/app_svg_icon.dart';
import '../../dimens/post_card_dimens.dart';
import '../post_tap_button.dart';

/// Centered badge of media that could not load (or upload); a tap retries. [label] is what a screen reader
/// says; the media retry wording by default.
class PostRetryBadge extends StatelessWidget {
  const PostRetryBadge({
    super.key,
    required this.icon,
    required this.onRetry,
    this.label,
  });

  final String icon;
  final VoidCallback onRetry;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PostTapButton(
      isContainer: true,
      label: label ?? context.l10n.postMediaRetry,
      onTap: onRetry,
      child: Center(
        child: Container(
          width: PostCardDimens.retryBadge,
          height: PostCardDimens.retryBadge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.mediaChip,
          ),
          alignment: Alignment.center,
          child: AppSvgIcon(
            icon,
            size: PostCardDimens.retryIcon,
            color: colors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}
