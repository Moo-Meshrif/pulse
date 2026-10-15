import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';

/// A rounded card of rows on the dark sheet, rows separated by a hairline.
class AudienceGroup extends StatelessWidget {
  const AudienceGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(OptionSheetDimens.groupRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.darkSurfaceRow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0)
                Divider(
                  color: colors.onDark.withValues(alpha: DarkOpacity.separator),
                ),
              child,
            ],
          ],
        ),
      ),
    );
  }
}
