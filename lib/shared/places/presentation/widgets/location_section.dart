import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// An uppercase label over a white card of rows, separated by a hairline. Without a [label] it is only
/// the card.
class LocationSection extends StatelessWidget {
  const LocationSection({super.key, this.label, required this.rows});

  final String? label;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.s12,
              top: LocationDimens.sectionLabelGap,
              bottom: AppSpacing.s8,
            ),
            child: Semantics(
              header: true,
              child: AppText(
                label!.toUpperCase(),
                style: context.text.section,
                color: colors.textSecondary,
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(LocationDimens.cardRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(LocationDimens.cardRadius),
            child: Column(
              children: [
                for (final (i, row) in rows.indexed) ...[
                  if (i > 0)
                    Divider(
                      height: 1, // unscaled: hairline
                      thickness: 1, // unscaled: hairline
                      color: colors.divider,
                    ),
                  row,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
