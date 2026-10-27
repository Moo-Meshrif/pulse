import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/skeleton_effect.dart';

/// One person row as shapes under the shimmer, in the list's card: what the list shows before the first
/// page arrives, and under the last row while the next page loads.
class PeopleSkeleton extends StatelessWidget {
  const PeopleSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: context.l10n.loading,
    child: ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.cardMargin),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Skeletonizer.zone(
            effect: skeletonEffect(context),
            child: const _Row(),
          ),
        ),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: SettingsDimens.rowSide,
      vertical: AppSpacing.s8,
    ),
    child: SizedBox(
      height: SettingsDimens.rowMinHeight,
      child: Row(
        children: [
          Bone.circle(size: SettingsDimens.personAvatar),
          SizedBox(width: SettingsDimens.personGap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(width: 120, style: context.text.name),
                Bone.text(width: 60, style: context.text.bodySm),
              ],
            ),
          ),
          Bone.button(width: 84, height: SettingsDimens.pillHeight),
        ],
      ),
    ),
  );
}
