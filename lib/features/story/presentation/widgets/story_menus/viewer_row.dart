import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/model/story_viewer_model.dart';
import '../../dimens/story_dimens.dart';
import '../story_avatar.dart';

class ViewerRow extends StatelessWidget {
  const ViewerRow({super.key, required this.viewer});

  final StoryViewerModel viewer;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.text;
    final name = viewer.fullName ?? viewer.username ?? '';
    return SizedBox(
      height: StoryDimens.viewerRowHeight,
      child: Row(
        children: [
          StoryAvatar(
            size: StoryDimens.viewerAvatar,
            seed: viewer.userId ?? name,
            name: name,
            imageUrl: viewer.avatarUrl,
          ),
          SizedBox(width: StoryDimens.viewerRowGap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  name,
                  style: text.name,
                  color: colors.onDark,
                  maxLines: 1,
                ),
                if (viewer.username != null)
                  AppText(
                    '@${viewer.username}',
                    style: text.caption,
                    color: colors.onDark.withValues(
                      alpha: DarkOpacity.subtitle,
                    ),
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          if (viewer.liked ?? false)
            AppSvgIcon(
              AppAssets.heart,
              size: StoryDimens.viewerLikedIcon,
              color: colors.like,
            ),
        ],
      ),
    );
  }
}
