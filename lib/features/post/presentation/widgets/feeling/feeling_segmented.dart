import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/feeling_dimens.dart';

/// "Feelings | Activities": a grey track with a white thumb on the chosen tab. Feelings is always the chosen
/// one for now; a tap on Activities only calls [onActivities].
class FeelingSegmented extends StatelessWidget {
  const FeelingSegmented({super.key, required this.onActivities});

  final VoidCallback onActivities;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final radius = BorderRadius.circular(FeelingDimens.segmentedHeight / 2);
    return Container(
      height: FeelingDimens.segmentedHeight,
      padding: EdgeInsets.all(FeelingDimens.segmentedPadding),
      decoration: BoxDecoration(color: colors.divider, borderRadius: radius),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: l10n.postFeelingTabFeelings,
              selected: true,
              onTap: () {},
            ),
          ),
          Expanded(
            child: _Tab(
              label: l10n.postFeelingTabActivities,
              selected: false,
              onTap: onActivities,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(
              FeelingDimens.segmentedHeight / 2,
            ),
          ),
          child: Center(
            child: AppText(
              label,
              style: context.text.label,
              color: selected ? colors.textPrimary : colors.textSecondary,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
