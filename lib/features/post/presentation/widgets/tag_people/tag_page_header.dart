import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/tag_people_dimens.dart';

/// Back arrow, the page title and the green "Done" pill, shared by Tag people and Tag in photo.
class TagPageHeader extends StatelessWidget {
  const TagPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onDone,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final done = context.l10n.postTagPeopleDone;
    return SizedBox(
      height: TagPeopleDimens.headerHeight,
      child: Row(
        children: [
          SizedBox(width: AppSpacing.headerBackSide),
          AppBackButton(onPressed: onBack),
          SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Semantics(
              header: true,
              child: AppText(
                title,
                style: context.text.titleSm,
                color: colors.textPrimary,
                maxLines: 1,
              ),
            ),
          ),
          Semantics(
            button: true,
            excludeSemantics: true,
            label: done,
            onTap: onDone,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDone,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.tapTarget,
                ),
                child: Center(
                  child: Container(
                    height: TagPeopleDimens.doneHeight,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: TagPeopleDimens.doneSide,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(
                        AppRadius.pill(TagPeopleDimens.doneHeight),
                      ),
                    ),
                    child: AppText(
                      done,
                      style: context.text.action,
                      color: colors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s16),
        ],
      ),
    );
  }
}
