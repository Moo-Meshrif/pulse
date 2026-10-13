import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../app_svg_icon.dart';
import '../app_text.dart';
import '../loading_overlay/pulse_line_loader.dart';
import '../primary_button.dart';
import 'app_empty.dart';

/// The large bare icon of an `AppEmpty`, floating up and down with [float] (0..1).
class AppEmptyIcon extends StatelessWidget {
  const AppEmptyIcon({
    super.key,
    required this.asset,
    required this.color,
    required this.float,
  });

  final String asset;
  final Color color;
  final Animation<double> float;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: float,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, (float.value * 2 - 1) * AppEmptyDimens.float),
        child: child,
      ),
      child: AppSvgIcon(asset, size: AppEmptyDimens.icon, color: color),
    ),
  );
}

/// The main action: a primary pill with a soft glow, or the amber pill of the connection tone.
class AppEmptyPrimaryAction extends StatelessWidget {
  const AppEmptyPrimaryAction({
    super.key,
    required this.label,
    required this.onPressed,
    required this.tone,
    required this.loading,
  });

  final String label;
  final VoidCallback onPressed;
  final AppEmptyTone tone;
  final bool loading;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: AppEmptyDimens.actionMaxWidth),
    child: tone == AppEmptyTone.connection
        ? _ConnectionButton(
            label: label,
            onPressed: onPressed,
            loading: loading,
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppRadius.pill(AppEmptyDimens.primaryHeight),
              ),
              boxShadow: AppShadows.primaryAction,
            ),
            child: PrimaryButton(
              label: label,
              onPressed: onPressed,
              loading: loading,
              expand: true,
              buttonHeight: AppEmptyDimens.primaryHeight,
            ),
          ),
  );
}

/// The text link under the primary action, e.g. "Go to Home".
class AppEmptyLink extends StatelessWidget {
  const AppEmptyLink({super.key, required this.label, required this.onPressed});

  final String label;

  /// Null disables it (while a retry runs).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.primary;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, AppEmptyDimens.linkHeight),
        foregroundColor: color,
        overlayColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: AppText(label, style: context.text.action, color: color),
    );
  }
}

/// The amber primary action of the connection tone: `warningSoft` fill, `warningText` label.
class _ConnectionButton extends StatelessWidget {
  const _ConnectionButton({
    required this.label,
    required this.onPressed,
    required this.loading,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(double.infinity, AppEmptyDimens.primaryHeight),
        ),
        maximumSize: WidgetStatePropertyAll(
          Size(double.infinity, AppEmptyDimens.primaryHeight),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        elevation: const WidgetStatePropertyAll(0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: WidgetStatePropertyAll(colors.warningSoft),
        foregroundColor: WidgetStatePropertyAll(colors.warningText),
      ),
      child: loading
          ? Semantics(
              label: label,
              child: PulseLineLoader(
                color: colors.warningText,
                width: AuthButtonDimens.loaderWidth,
              ),
            )
          : AppText(
              label,
              style: context.text.button,
              color: colors.warningText,
              textAlign: TextAlign.center,
            ),
    );
  }
}
