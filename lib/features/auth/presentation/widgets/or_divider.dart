import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// "──── or continue with ────": 1 px `divider` lines around a `bodySm` label, gap 12
/// (docs/specs/auth/02-components.md C6).
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final line = Expanded(
      child: SizedBox(
        height: AuthDimens.dividerLineWidth,
        child: ColoredBox(color: colors.divider),
      ),
    );
    // The label wraps instead of overflowing (large text, long translations) once it needs more than
    // `dividerLabelMaxShare` of the window width; the lines keep the rest. Not a `LayoutBuilder`: screens
    // put this inside `SliverFillRemaining`, which asks for intrinsic sizes.
    final labelMaxWidth =
        MediaQuery.sizeOf(context).width * AuthDimens.dividerLabelMaxShare;
    return Row(
      children: [
        line,
        SizedBox(width: AuthDimens.dividerGap),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: labelMaxWidth),
          child: AppText(
            text,
            style: context.text.bodySm,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: AuthDimens.dividerGap),
        line,
      ],
    );
  }
}
