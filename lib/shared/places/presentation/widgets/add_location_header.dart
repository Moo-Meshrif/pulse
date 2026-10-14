import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// Back arrow, "Add location", and "Remove" at the end while the post has a location.
class AddLocationHeader extends StatelessWidget {
  const AddLocationHeader({super.key, required this.onBack, this.onRemove});

  final VoidCallback onBack;

  /// Null hides "Remove": the post has no location to remove.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final remove = context.l10n.locationRemove;
    return SizedBox(
      height: LocationDimens.headerHeight,
      child: Row(
        children: [
          SizedBox(width: AppSpacing.headerBackSide),
          AppBackButton(onPressed: onBack),
          SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Semantics(
              header: true,
              child: AppText(
                context.l10n.locationTitle,
                style: context.text.titleSm,
                color: colors.textPrimary,
                maxLines: 1,
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
                    minWidth: AuthDimens.tapTarget,
                    minHeight: AuthDimens.tapTarget,
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
