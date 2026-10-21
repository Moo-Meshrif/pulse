import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/share_sheet_dimens.dart';

/// A round tool of the share composer (Tag people, Feeling, Location): `primary` icon on white, and filled
/// `primary` while it has a value.
class ShareToolButton extends StatelessWidget {
  const ShareToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.hasValue,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool hasValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      selected: hasValue,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: ShareSheetDimens.toolButton,
          height: ShareSheetDimens.toolButton,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasValue ? colors.primary : colors.surface,
          ),
          child: AppSvgIcon(
            icon,
            size: ShareSheetDimens.toolIcon,
            color: hasValue ? colors.surface : colors.primary,
          ),
        ),
      ),
    );
  }
}
