import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../app_text.dart';

/// A full-width pill of a permission panel (Allow access, Open settings, Choose from gallery): [fill] behind
/// a [textColor] label, 52 high, at most 300 wide.
class PermissionPill extends StatelessWidget {
  const PermissionPill({
    super.key,
    required this.label,
    required this.onTap,
    required this.fill,
    required this.textColor,
  });

  final String label;
  final VoidCallback? onTap;
  final Color fill;
  final Color textColor;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: StoryPermissionDimens.buttonMaxWidth),
    child: SizedBox(
      width: double.infinity,
      height: StoryPermissionDimens.buttonHeight,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: fill,
          foregroundColor: textColor,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: AppText(
          label,
          style: context.text.button,
          color: textColor,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
