import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/story_post_args.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/share_sheet/share_sheet_cubit.dart';
import '../../dimens/share_sheet_dimens.dart';

/// The bottom row of the Share sheet: Add to story, Copy link, WhatsApp, More. The row scrolls sideways when the
/// tiles do not fit (large text). A link to a Followers post is checked against the opener's access when it opens.
class ShareExternalRow extends StatelessWidget {
  const ShareExternalRow({super.key, this.story});

  /// What Add to story puts on the story; null hides nothing, the tile just says "Coming soon".
  final StoryPostArgs? story;

  void _addToStory(BuildContext context) {
    final post = story;
    if (post == null) return Notices.info(context.l10n.comingSoon);
    if (context.read<ShareSheetCubit>().isStoryPosting) {
      return Notices.info(context.l10n.storyUploadBusy);
    }
    AppNavigator.push<void>(
      context,
      AppRoutes.createStoryPost,
      rootNavigator: true,
      arguments: post,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void comingSoon() => Notices.info(l10n.comingSoon);
    final colors = context.appColors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: ShareSheetDimens.tileGap,
        children: [
          _Tile(
            icon: AppAssets.plus,
            label: l10n.shareAddToStory,
            fill: colors.primarySoft,
            ink: colors.primary,
            onTap: () => _addToStory(context),
          ),
          // TODO(post-plan T7): Copy link, WhatsApp and More wait for post links and share_plus.
          _Tile(
            icon: AppAssets.link,
            label: l10n.shareCopyLink,
            fill: colors.background,
            ink: colors.textPrimary,
            onTap: comingSoon,
          ),
          // The brand icon comes from the user (spec: the official WhatsApp icon); the chat icon stands in.
          _Tile(
            icon: AppAssets.chat,
            label: l10n.shareWhatsApp,
            fill: colors.background,
            ink: colors.textPrimary,
            onTap: comingSoon,
          ),
          _Tile(
            icon: AppAssets.share,
            label: l10n.shareMore,
            fill: colors.background,
            ink: colors.textPrimary,
            onTap: comingSoon,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.fill,
    required this.ink,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Color fill;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    onTap: onTap,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: ShareSheetDimens.tileWidth,
        child: Column(
          children: [
            Container(
              width: ShareSheetDimens.tile,
              height: ShareSheetDimens.tile,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
              child: AppSvgIcon(
                icon,
                size: ShareSheetDimens.tileIcon,
                color: ink,
              ),
            ),
            SizedBox(height: ShareSheetDimens.tileLabelGap),
            AppText(
              label,
              style: context.text.chip,
              color: context.appColors.textPrimary,
              maxLines: ShareSheetDimens.tileLabelLines,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
