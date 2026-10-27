import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_page_dimens.dart';

/// A post that is gone, or that you can no longer see.
class PostPageUnavailable extends StatelessWidget {
  const PostPageUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: PostPageDimens.listPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgIcon(
              AppAssets.lockClosed,
              size: PostPageDimens.unavailableIcon,
              color: colors.textSecondary,
            ),
            SizedBox(height: PostPageDimens.unavailableGap),
            AppText(
              context.l10n.postUnavailableTitle,
              style: context.text.section,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: PostPageDimens.unavailableBodyGap),
            AppText(
              context.l10n.postPageUnavailableBody,
              style: context.text.bodySm,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: PostPageDimens.unavailableButtonGap),
            SizedBox(
              width: PostPageDimens.unavailableButtonWidth,
              child: PrimaryButton(
                label: context.l10n.postBackToHome,
                expand: true,
                onPressed: () =>
                    AppNavigator.resetTo<void>(context, AppRoutes.home),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
