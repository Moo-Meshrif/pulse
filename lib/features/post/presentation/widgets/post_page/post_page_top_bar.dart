import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_page_dimens.dart';
import '../post_person_avatar.dart';

/// The page's bar: back, the title (a mini author once the author row has scrolled away) and "···" that
/// opens the post's options. Without a post only the back button shows.
class PostPageTopBar extends StatelessWidget {
  const PostPageTopBar({
    super.key,
    required this.onBack,
    required this.onOptions,
    required this.showAuthor,
    this.authorName,
    this.authorAvatarUrl,
    this.authorId,
  });

  final VoidCallback onBack;

  /// Null hides the options button.
  final VoidCallback? onOptions;

  /// True once the author row left the screen: the title becomes the author.
  final bool showAuthor;
  final String? authorId;
  final String? authorName;
  final String? authorAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: PostPageDimens.topBarHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: PostPageDimens.topBarSide,
                ),
                child: Row(
                  children: [
                    AppBackButton(onPressed: onBack),
                    Expanded(child: _title(context)),
                    if (onOptions != null)
                      _OptionsButton(onTap: onOptions!)
                    else
                      SizedBox(width: AppSizes.tapTarget),
                  ],
                ),
              ),
            ),
            if (showAuthor)
              Divider(
                height: PostPageDimens.barDivider,
                thickness: PostPageDimens.barDivider,
                color: colors.divider,
              ),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final colors = context.appColors;
    final name = authorName;
    if (showAuthor && name != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PostPersonAvatar(
            id: authorId ?? name,
            name: name,
            url: authorAvatarUrl,
            size: PostPageDimens.miniAvatar,
          ),
          SizedBox(width: PostPageDimens.miniAvatarGap),
          Flexible(
            child: AppText(
              name,
              style: context.text.name,
              color: colors.textPrimary,
              maxLines: 1,
            ),
          ),
        ],
      );
    }
    return AppText(
      context.l10n.postPageTitle,
      style: context.text.sheetTitle,
      color: colors.textPrimary,
      textAlign: TextAlign.center,
      maxLines: 1,
    );
  }
}

class _OptionsButton extends StatelessWidget {
  const _OptionsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.postOptions,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onTap,
      radius: AppSizes.tapTarget / 2,
      child: SizedBox(
        width: AppSizes.tapTarget,
        height: AppSizes.tapTarget,
        child: Center(
          child: AppSvgIcon(
            AppAssets.moreHorizontal,
            size: AppSizes.topBarIcon,
            color: context.appColors.textPrimary,
          ),
        ),
      ),
    ),
  );
}
