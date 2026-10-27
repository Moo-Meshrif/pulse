import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/story_post_args.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../shared/content/data/enums/content_audience.dart';
import '../../cubit/share_sheet/share_sheet_cubit.dart';
import '../../cubit/share_sheet/share_sheet_state.dart';
import '../../dimens/share_sheet_dimens.dart';
import '../../utils/enums/share_access.dart';
import '../../utils/enums/share_result.dart';
import 'share_composer.dart';
import 'share_external_row.dart';

/// The Share sheet of a post (docs/specs/post/screens/s12-share-sheet.md): share it to your own feed with
/// words, a feeling, a place and tagged people, or take it elsewhere. Your own Followers post keeps its audience when shared. Sending in chat is not drawn until the Chat tables exist.
abstract final class ShareSheet {
  /// Shows the sheet for [postId] (the shared post itself, or the original of a share). Share now closes it
  /// at once; Home's banner shows how the share goes.
  static Future<void> show(
    BuildContext context, {
    required String postId,
    required ShareAccess access,
    StoryPostArgs? story,
  }) => AppBottomSheet.show<void>(
    context,
    child: BlocProvider(
      create: (_) {
        final cubit = getIt<ShareSheetCubit>(param1: postId);
        if (access == ShareAccess.ownFollowers) {
          cubit.lockAudience(ContentAudience.followers);
        } else {
          unawaited(cubit.loadDefaultAudience());
        }
        return cubit;
      },
      child: BlocListener<ShareSheetCubit, ShareSheetState>(
        listenWhen: (before, now) =>
            before.result == null && now.result != null,
        listener: (context, state) => _react(context, state),
        child: _Body(access: access, story: story),
      ),
    ),
  );

  static void _react(BuildContext context, ShareSheetState state) {
    switch (state.result) {
      case ShareResult.shared:
        AppNavigator.back(context);
      case ShareResult.busy:
        Notices.info(context.l10n.newPostPublishBusy);
        context.read<ShareSheetCubit>().clearResult();
      case null:
        break;
    }
  }
}

/// Rides above the keyboard, and scrolls when the screen is short.
class _Body extends StatelessWidget {
  const _Body({required this.access, this.story});

  final ShareAccess access;

  /// The post as a story sticker; null when it cannot be drawn, and Add to story waits.
  final StoryPostArgs? story;

  @override
  Widget build(BuildContext context) {
    final hasComposer =
        access == ShareAccess.full || access == ShareAccess.ownFollowers;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            SizedBox(height: ShareSheetDimens.sectionGap),
            if (hasComposer) ...[
              if (access == ShareAccess.ownFollowers) ...[
                AppText(
                  context.l10n.shareAudienceLocked,
                  style: context.text.bodySm,
                  color: context.appColors.textSecondary,
                ),
                SizedBox(height: ShareSheetDimens.sectionGap),
              ],
              const ShareComposer(),
              Padding(
                padding: ShareSheetDimens.dividerMargin,
                child: Divider(
                  height: ShareSheetDimens.divider,
                  thickness: ShareSheetDimens.divider,
                  color: context.appColors.border,
                ),
              ),
            ],
            // TODO(post-plan T20): the Send in chat section goes here once Chat exists.
            ShareExternalRow(story: story),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        AppSvgIcon(
          AppAssets.shareForward,
          size: ShareSheetDimens.headerIcon,
          color: colors.textPrimary,
        ),
        SizedBox(width: ShareSheetDimens.headerGap),
        Expanded(
          child: AppText(
            context.l10n.shareTitle,
            style: context.text.sheetTitle,
            color: colors.textPrimary,
            maxLines: 1,
          ),
        ),
        Semantics(
          button: true,
          label: context.l10n.close,
          excludeSemantics: true,
          onTap: () => AppNavigator.back(context),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => AppNavigator.back(context),
            child: Container(
              width: ShareSheetDimens.closeButton,
              height: ShareSheetDimens.closeButton,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.background,
              ),
              child: AppSvgIcon(
                AppAssets.close,
                size: ShareSheetDimens.closeIcon,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
