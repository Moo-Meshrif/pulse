import 'package:flutter/material.dart';

import '../enums/sheet_tone.dart';
import '../extensions/context_extensions.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_safe_area.dart';
import 'backdrop_blur.dart';
import 'device_tier_scope.dart';

/// The shared dialog route and card (docs/specs/auth/02-components.md C14). Content is up to the caller.
class AppDialogShell extends StatelessWidget {
  const AppDialogShell({
    super.key,
    required this.semanticLabel,
    required this.child,
    this.tone = SheetTone.light,
    this.padding,
    this.margin,
    this.radius,
  });

  /// The dialog title, announced as the dialog's name.
  final String semanticLabel;
  final Widget child;

  /// [SheetTone.dark] is the surface the story screens use over media.
  final SheetTone tone;

  /// Replace the shared card padding, side margin and corner radius (the story delete dialog).
  final EdgeInsets? padding;
  final double? margin;
  final double? radius;

  /// Shows a dialog built by [builder] (normally an [AppDialogShell]). Barrier tap and Android back
  /// close it with no result unless [dismissible] is false.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool dismissible = true,
    SheetTone tone = SheetTone.light,
  }) => showGeneralDialog<T>(
    context: context,
    // Over the main shell's nav bar, not inside a tab.
    useRootNavigator: true,
    barrierDismissible: dismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: switch (tone) {
      SheetTone.light => context.appColors.scrim,
      SheetTone.dark => context.appColors.black.withValues(
        alpha: DarkOpacity.dialogScrim,
      ),
    },
    transitionDuration: DialogDimens.transition,
    pageBuilder: (context, _, _) => PopScope(
      canPop: dismissible,
      child: AppSafeArea(child: Center(child: builder(context))),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: curved,
              builder: (context, _) => BackdropBlur(
                // Low-tier: a fixed blur, so it is not recomputed with a new sigma on every frame of the entrance.
                sigma:
                    DialogDimens.backdropBlurSigma *
                    (context.isLowTier ? 1 : curved.value),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(
                begin: DialogDimens.enterScale,
                end: 1.0, // unscaled: animation scale, not a layout size
              ).animate(curved),
              child: child,
            ),
          ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: semanticLabel,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: margin ?? DialogDimens.margin,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: DialogDimens.maxWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tone == SheetTone.dark
                    ? colors.darkSurface
                    : colors.surface,
                borderRadius: BorderRadius.circular(radius ?? AppRadius.dialog),
                boxShadow: AppShadows.dialog,
              ),
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  padding: padding ?? DialogDimens.padding,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
