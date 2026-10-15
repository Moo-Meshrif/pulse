import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// The white full-width pill of the dark story screens ("Done"): `textPrimary` text, 52 high.
class StoryWhitePill extends StatelessWidget {
  const StoryWhitePill({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Without an action the pill is dimmed (a loading pill keeps its full look).
    return Opacity(
      opacity: onPressed == null && !isLoading ? DarkOpacity.subtitle : 1,
      child: SizedBox(
        width: double.infinity,
        height: CameraPermissionDimens.buttonHeight,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: colors.onDark,
            disabledBackgroundColor: colors.onDark,
            foregroundColor: colors.textPrimary,
          ),
          child: isLoading
              ? PulseLineLoader(
                  color: colors.textPrimary,
                  width: LoadingDimens.loadMoreWidth,
                )
              : AppText(
                  label,
                  style: context.text.button,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
