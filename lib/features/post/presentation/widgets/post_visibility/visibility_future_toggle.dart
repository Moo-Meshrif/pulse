import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_options_dimens.dart';

/// "Use for future posts": saves the choice as the audience new posts start with.
class VisibilityFutureToggle extends StatelessWidget {
  const VisibilityFutureToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return Semantics(
      container: true,
      toggled: value,
      label: l10n.postVisibilityFuture,
      child: Row(
        children: [
          Expanded(
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.postVisibilityFuture,
                    style: context.text.name,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    l10n.postVisibilityFutureHint,
                    style: context.text.caption,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s12),
          SizedBox(
            width: VisibilityDimens.toggleWidth,
            height: VisibilityDimens.toggleHeight,
            child: FittedBox(
              child: Switch(value: value, onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }
}
