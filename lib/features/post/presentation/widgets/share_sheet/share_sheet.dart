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
import '../../cubit/share_sheet/share_sheet_cubit.dart';
import '../../cubit/share_sheet/share_sheet_state.dart';
import '../../dimens/share_sheet_dimens.dart';
import '../../utils/enums/share_access.dart';
import '../../utils/enums/share_result.dart';
import 'share_composer.dart';
import 'share_external_row.dart';

/// The Share sheet of a post (docs/specs/post/screens/s12-share-sheet.md): share it to your own feed with
/// words, a feeling, a place and tagged people, or take it elsewhere. A post you can only put on your story
/// has just that. Sending in chat is not drawn until the Chat tables exist.
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
      create: (_) =>
          getIt<ShareSheetCubit>(param1: postId)..loadDefaultAudience(),
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
    final isFull = access == ShareAccess.full;
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
            if (isFull) ...[
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
            ShareExternalRow(access: access, story: story),
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
