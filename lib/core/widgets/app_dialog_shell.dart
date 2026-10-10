import 'dart:ui';

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';
import 'app_safe_area.dart';

/// The shared dialog route and card (docs/specs/auth/02-components.md C14). Content is up to the caller.
class AppDialogShell extends StatelessWidget {
  const AppDialogShell({
    super.key,
    required this.semanticLabel,
    required this.child,
  });

  /// The dialog title, announced as the dialog's name.
  final String semanticLabel;
  final Widget child;

  /// Shows a dialog built by [builder] (normally an [AppDialogShell]). Barrier tap and Android back
  /// close it with no result unless [dismissible] is false.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool dismissible = true,
  }) => showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.appColors.scrim,
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
              builder: (context, _) => BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: DialogDimens.backdropBlurSigma * curved.value,
                  sigmaY: DialogDimens.backdropBlurSigma * curved.value,
                ),
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
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: DialogDimens.margin),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: DialogDimens.maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.dialog),
              boxShadow: AppShadows.dialog,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: DialogDimens.padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
