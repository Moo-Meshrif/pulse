import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/l10n.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../app_text.dart';
import 'app_empty_parts.dart';

/// The color family of an `AppEmpty`: `normal` is the brand teal, `connection` the amber of connection
/// problems, `onDark` white text for screens on a black background (story).
enum AppEmptyTone { normal, connection, onDark }

/// What an `AppEmpty` shows: caller-supplied copy, or one of the ready-made problems.
enum AppEmptyPreset {
  custom,
  failed,
  notFound,
  offline;

  /// The preset's icon; [custom] takes the caller's.
  String? get icon => switch (this) {
    custom => null,
    failed => AppAssets.alertCircle,
    notFound => AppAssets.fileX,
    offline => AppAssets.wifiOffThin,
  };

  /// The preset's copy; null for [custom]. [hasLink] tells whether the secondary link is wanted.
  AppEmptyCopy? copy(BuildContext context, {required bool hasLink}) {
    final l10n = context.l10n;
    return switch (this) {
      custom => null,
      failed => AppEmptyCopy(
        title: l10n.failedPageTitle,
        message: l10n.failedPageBody,
        primaryLabel: l10n.tryAgain,
        secondaryLabel: hasLink ? l10n.goToHome : null,
      ),
      notFound => AppEmptyCopy(
        title: l10n.notFoundPageTitle,
        message: l10n.notFoundPageBody,
        primaryLabel: l10n.goToHome,
      ),
      offline => AppEmptyCopy(
        title: l10n.offlinePageTitle,
        message: l10n.offlinePageBody,
        primaryLabel: l10n.tryAgain,
      ),
    };
  }
}

class AppEmptyCopy {
  const AppEmptyCopy({
    required this.title,
    required this.message,
    this.primaryLabel,
    this.secondaryLabel,
  });

  final String title;
  final String message;
  final String? primaryLabel;
  final String? secondaryLabel;
}

/// The body of a page with nothing to show: empty, failed, not found or offline (the "Empty and failed"
/// board). A large bare icon, a title, a message, one primary action and an optional link. Put it inside
/// a screen's body (under its app bar); it fades in and rises, and the icon floats, unless the system asks
/// to reduce motion.
///
/// `AppEmpty(...)` is the empty state: pass an icon from the `AppAssets.state…` set and the copy.
/// [AppEmpty.failed], [AppEmpty.notFound] and [AppEmpty.offline] carry their own icon, copy and tone.
/// While a retry runs, [loading] swaps the primary label for the heartbeat line; cross-fading to the
/// content on success is up to the screen (`AnimatedSwitcher`).
class AppEmpty extends StatefulWidget {
  const AppEmpty({
    super.key,
    required String this.icon,
    required String this.title,
    required String this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tone = AppEmptyTone.normal,
    this.loading = false,
  }) : _preset = AppEmptyPreset.custom;

  /// Default failure. Primary retries; the link leaves to Home (omit [onGoHome] to hide it, pass
  /// [linkLabel] when it does something else, e.g. "Close").
  const AppEmpty.failed({
    super.key,
    required VoidCallback onRetry,
    VoidCallback? onGoHome,
    String? linkLabel,
    this.tone = AppEmptyTone.normal,
    this.loading = false,
  }) : icon = null,
       title = null,
       message = null,
       primaryLabel = null,
       secondaryLabel = linkLabel,
       onPrimary = onRetry,
       onSecondary = onGoHome,
       _preset = AppEmptyPreset.failed;

  /// A bad deep link, or a deleted post or profile. The primary action goes Home; omit [onGoHome] when
  /// the screen's back arrow is the way out.
  const AppEmpty.notFound({
    super.key,
    VoidCallback? onGoHome,
    this.loading = false,
  }) : icon = null,
       title = null,
       message = null,
       primaryLabel = null,
       secondaryLabel = null,
       onPrimary = onGoHome,
       onSecondary = null,
       tone = AppEmptyTone.normal,
       _preset = AppEmptyPreset.notFound;

  /// The connection is lost; amber. Retries (the screen should also reload on reconnect).
  const AppEmpty.offline({
    super.key,
    required VoidCallback onRetry,
    this.loading = false,
  }) : icon = null,
       title = null,
       message = null,
       primaryLabel = null,
       secondaryLabel = null,
       onPrimary = onRetry,
       onSecondary = null,
       tone = AppEmptyTone.connection,
       _preset = AppEmptyPreset.offline;

  final String? icon;
  final String? title;
  final String? message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final AppEmptyTone tone;
  final bool loading;
  final AppEmptyPreset _preset;

  @override
  State<AppEmpty> createState() => _AppEmptyState();
}

class _AppEmptyState extends State<AppEmpty> with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: AppEmptyDimens.enter,
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: AppEmptyDimens.floatLoop,
  );
  late final Animation<double> _enterCurve = CurvedAnimation(
    parent: _enter,
    curve: Curves.easeOutCubic,
  );
  late final Animation<double> _floatCurve = CurvedAnimation(
    parent: _float,
    curve: Curves.easeInOut,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _enter.value = 1;
      _float.stop();
      _float.value = 0.5;
    } else {
      if (!_enter.isCompleted && !_enter.isAnimating) _enter.forward();
      if (!_float.isAnimating) _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final onDark = widget.tone == AppEmptyTone.onDark;
    final preset = widget._preset;
    final copy = preset.copy(context, hasLink: widget.onSecondary != null);
    final title = copy?.title ?? widget.title!;
    final message = copy?.message ?? widget.message!;
    final primaryLabel = copy?.primaryLabel ?? widget.primaryLabel;
    final secondaryLabel = widget.secondaryLabel ?? copy?.secondaryLabel;
    final onPrimary = widget.onPrimary;
    final onSecondary = widget.onSecondary;
    final hasPrimary = primaryLabel != null && onPrimary != null;
    final hasSecondary = secondaryLabel != null && onSecondary != null;

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: AppEmptyDimens.side),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppEmptyIcon(
            asset: preset.icon ?? widget.icon!,
            color: switch (widget.tone) {
              AppEmptyTone.connection => colors.warningInk,
              AppEmptyTone.onDark => colors.storyOnDark,
              AppEmptyTone.normal => colors.primary,
            },
            float: _floatCurve,
          ),
          SizedBox(height: AppEmptyDimens.iconToTitleGap),
          Semantics(
            header: true,
            child: AppText(
              title,
              style: context.text.title,
              color: onDark ? colors.storyOnDark : colors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppEmptyDimens.titleToBodyGap),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppEmptyDimens.bodyMaxWidth),
            child: AppText(
              message,
              style: context.text.subtitle,
              color: onDark
                  ? colors.storyOnDark.withValues(alpha: 0.7)
                  : colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          if (hasPrimary || hasSecondary)
            SizedBox(height: AppEmptyDimens.bodyToActionsGap),
          if (hasPrimary)
            AppEmptyPrimaryAction(
              label: primaryLabel,
              onPressed: onPrimary,
              tone: widget.tone,
              loading: widget.loading,
            ),
          if (hasSecondary)
            AppEmptyLink(
              label: secondaryLabel,
              onPressed: widget.loading ? null : onSecondary,
              tone: widget.tone,
            ),
        ],
      ),
    );

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: FadeTransition(
              opacity: _enterCurve,
              child: AnimatedBuilder(
                animation: _enterCurve,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    0,
                    (1 - _enterCurve.value) * AppEmptyDimens.rise,
                  ),
                  child: child,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
