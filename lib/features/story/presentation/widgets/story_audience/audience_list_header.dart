import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/audience_list_cubit.dart';
import '../../cubit/audience_list_state.dart';
import '../../dimens/story_dimens.dart';

/// The title row of a list screen: back, the name of the list, and how many are selected.
class AudienceListHeader extends StatelessWidget {
  const AudienceListHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: StoryCameraDimens.topBarHeight,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: context.l10n.back,
            excludeSemantics: true,
            child: InkResponse(
              onTap: () => AppNavigator.back(context),
              radius: StoryDimens.headerButton / 2,
              child: SizedBox.square(
                dimension: CameraPermissionDimens.roundControl,
                child: Center(
                  child: AppSvgIcon(
                    AppAssets.arrowBack,
                    size: CameraPermissionDimens.closeIcon,
                    color: colors.onDark,
                    directional: true,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: AppText(
                title,
                style: context.text.stat,
                color: colors.onDark,
                maxLines: 1,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.s16),
            child: BlocSelector<AudienceListCubit, AudienceListState, int>(
              selector: (state) => state.selectedCount,
              builder: (context, count) => AppText(
                context.l10n.storyAudienceSelected(count),
                style: context.text.caption,
                color: colors.onDark.withValues(alpha: DarkOpacity.subtitle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
