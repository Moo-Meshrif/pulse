import 'package:flutter/material.dart';

import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/theme/dimens/app_dimens.dart';
import '../../../dimens/home_dimens.dart';

/// White card the banner sits in; [outline] draws the amber border of a card that needs attention.
class PublishCardFrame extends StatelessWidget {
  const PublishCardFrame({super.key, required this.child, this.outline});

  final Widget child;
  final Color? outline;

  @override
  Widget build(BuildContext context) => Padding(
    padding: HomeDimens.listPadding.copyWith(bottom: HomeDimens.cardGap),
    child: Container(
      padding: HomeDimens.publishPadding,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: outline == null
            ? null
            : Border.all(color: outline!, width: HomeDimens.publishOutline),
      ),
      child: child,
    ),
  );
}

/// A rounded progress bar; [value] null moves until the first bytes go out.
class PublishBar extends StatelessWidget {
  const PublishBar({super.key, required this.value, this.isPaused = false});

  final double? value;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(HomeDimens.publishProgress),
      child: SizedBox(
        height: HomeDimens.publishProgress,
        child: LinearProgressIndicator(
          value: value,
          color: isPaused ? colors.iconInactive : colors.primary,
          backgroundColor: colors.divider,
        ),
      ),
    );
  }
}
