import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/feeling_dimens.dart';

/// Back arrow, "How are you feeling?", and a red "Remove" at the end while a mood is set.
class FeelingHeader extends StatelessWidget {
  const FeelingHeader({super.key, required this.onBack, this.onRemove});

  final VoidCallback onBack;

  /// Null hides "Remove": there is no mood to remove.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final remove = context.l10n.postFeelingRemove;
    return SizedBox(
      height: FeelingDimens.headerHeight,
      child: Row(
        children: [
          SizedBox(width: AppSpacing.headerBackSide),
          AppBackButton(onPressed: onBack),
          SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Semantics(
              header: true,
              child: AppText(
                context.l10n.postFeelingTitle,
                style: context.text.titleSm,
                color: colors.textPrimary,
                maxLines: 2,
              ),
            ),
          ),
          if (onRemove != null)
            Semantics(
              button: true,
              excludeSemantics: true,
              label: remove,
              onTap: onRemove,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemove,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: AppSizes.tapTarget,
                    minHeight: AppSizes.tapTarget,
                  ),
                  child: Center(
                    child: AppText(
                      remove,
                      style: context.text.name,
                      color: colors.danger,
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
