import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';

/// "New post" at the start and the close button at the end.
class NewPostTitleRow extends StatelessWidget {
  const NewPostTitleRow({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: PostComposerDimens.titleRowHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: PostComposerDimens.titleSide),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                context.l10n.newPostTitle,
                style: context.text.title,
                color: colors.textPrimary,
                maxLines: 1,
              ),
            ),
            Semantics(
              button: true,
              excludeSemantics: true,
              label: context.l10n.close,
              onTap: onClose,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: SizedBox.square(
                  dimension: PostComposerDimens.closeTarget,
                  child: Center(
                    child: AppSvgIcon(
                      AppAssets.close,
                      size: PostComposerDimens.closeIcon,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
