import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/story_viewers_cubit.dart';
import '../../cubit/story_viewers_state.dart';
import '../../utils/enums/story_option.dart';

class ViewersHeader extends StatelessWidget {
  const ViewersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        AppSvgIcon(
          AppAssets.eye,
          size: StoryDimens.viewersHeaderIcon,
          color: colors.storyOnDark,
        ),
        SizedBox(width: StoryDimens.viewersHeaderGap),
        Expanded(
          child: BlocSelector<StoryViewersCubit, StoryViewersState, int>(
            selector: (state) => state.total,
            builder: (context, total) => Semantics(
              header: true,
              child: AppText(
                context.l10n.storyViewers(total),
                style: context.text.stat,
                color: colors.storyOnDark,
                maxLines: 1,
              ),
            ),
          ),
        ),
        _CircleButton(
          label: context.l10n.storyDelete,
          asset: AppAssets.trash,
          fill: colors.dangerOnDark.withValues(alpha: StoryOpacity.dangerTint),
          color: colors.dangerOnDark,
          onTap: () => AppNavigator.back(context, StoryOption.delete),
        ),
        SizedBox(width: StoryDimens.viewersHeaderGap),
        _CircleButton(
          label: context.l10n.storySaveToDevice,
          asset: AppAssets.download,
          fill: colors.storySheetRow,
          color: colors.storyOnDark,
          onTap: () => AppNavigator.back(context, StoryOption.save),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.label,
    required this.asset,
    required this.fill,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String asset;
  final Color fill;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onTap,
      radius: StoryDimens.viewersAction / 2,
      child: Container(
        width: StoryDimens.viewersAction,
        height: StoryDimens.viewersAction,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: AppSvgIcon(
          asset,
          size: StoryDimens.viewersActionIcon,
          color: color,
        ),
      ),
    ),
  );
}
