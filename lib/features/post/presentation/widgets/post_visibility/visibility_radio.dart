import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_options_dimens.dart';

/// The round choice mark at the end of a row: filled `primary` with a white check when [selected].
class VisibilityRadio extends StatelessWidget {
  const VisibilityRadio({
    super.key,
    required this.selected,
    this.enabled = true,
  });

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: VisibilityDimens.radio,
      height: VisibilityDimens.radio,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.primary : Colors.transparent,
        border: selected
            ? null
            : Border.all(
                color: enabled ? colors.dashed : colors.divider,
                width: VisibilityDimens.radioBorderWidth,
              ),
      ),
      child: selected
          ? AppSvgIcon(
              AppAssets.check,
              size: VisibilityDimens.radioCheck,
              color: colors.textOnPrimary,
            )
          : null,
    );
  }
}
