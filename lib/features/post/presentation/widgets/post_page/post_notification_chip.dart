import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_page_dimens.dart';

/// The small dark chip under the bar for a moment after a notification opened the page.
class PostNotificationChip extends StatelessWidget {
  const PostNotificationChip({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      liveRegion: true,
      child: Container(
        height: PostPageDimens.chipHeight,
        padding: EdgeInsets.symmetric(horizontal: PostPageDimens.chipSide),
        decoration: BoxDecoration(
          color: colors.mediaChip,
          borderRadius: BorderRadius.circular(PostPageDimens.chipRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgIcon(
              AppAssets.comment,
              size: PostPageDimens.chipIcon,
              color: colors.textOnPrimary,
            ),
            SizedBox(width: PostPageDimens.chipGap),
            AppText(
              context.l10n.postFromNotification,
              style: context.text.chip,
              color: colors.textOnPrimary,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
