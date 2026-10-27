import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/skeleton_effect.dart';
import '../dimens/profile_dimens.dart';

/// The grid as shimmering tiles: three rows of three.
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key});

  static const _rows = 3;

  @override
  Widget build(BuildContext context) => Skeletonizer.zone(
    effect: skeletonEffect(context),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
      child: Column(
        children: [
          for (var row = 0; row < _rows; row++)
            Padding(
              padding: EdgeInsets.only(bottom: ProfileDimens.gridGap),
              child: Row(
                children: [
                  for (var col = 0; col < ProfileDimens.gridColumns; col++) ...[
                    if (col > 0) SizedBox(width: ProfileDimens.gridGap),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Bone(
                          borderRadius: BorderRadius.circular(
                            ProfileDimens.gridRadius,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

/// What the page looks like before the first answer: the cover and the photo as shapes. It does not scroll.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Semantics(
      liveRegion: true,
      label: context.l10n.loading,
      child: ExcludeSemantics(
        child: CustomScrollView(
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Skeletonizer.zone(
                effect: skeletonEffect(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(
                      width: double.infinity,
                      height: ProfileDimens.coverHeight + top,
                      borderRadius: BorderRadius.zero,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: AppSpacing.s16),
                      child: Transform.translate(
                        offset: Offset(0, -ProfileDimens.avatarOverlap),
                        child: Container(
                          padding: const EdgeInsets.all(
                            ProfileDimens.avatarWhiteRing,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Bone.circle(size: ProfileDimens.avatar),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
