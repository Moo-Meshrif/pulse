import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/match_highlight.dart';

/// One place: an icon tile, the name (the part matching [query] in bold) with its detail under it, and a
/// check at the end when it is the post's current location.
class LocationPlaceRow extends StatelessWidget {
  const LocationPlaceRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.detail,
    this.query = '',
    this.isSelected = false,
    this.isHighlighted = false,
  });

  final String icon;
  final String title;
  final String? detail;
  final String query;
  final bool isSelected;

  /// The "Use current location" row: a `primarySoft` tile with a `primary` icon.
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.text;
    final match = MatchHighlight.of(title, query);
    final label = [
      title,
      ?detail,
      if (isSelected) context.l10n.locationSelected,
    ].join(', ');
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: LocationDimens.rowMinHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              children: [
                Container(
                  width: LocationDimens.rowTile,
                  height: LocationDimens.rowTile,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? colors.primarySoft
                        : colors.background,
                    borderRadius: BorderRadius.circular(
                      LocationDimens.rowTileRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: AppSvgIcon(
                    icon,
                    size: LocationDimens.rowIcon,
                    color: isHighlighted
                        ? colors.primary
                        : colors.textSecondary,
                  ),
                ),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: text.body.copyWith(color: colors.textPrimary),
                          children: [
                            TextSpan(text: match.before),
                            if (match.hasMatch)
                              TextSpan(
                                text: match.match,
                                style: text.name.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            TextSpan(text: match.after),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (detail != null && detail!.isNotEmpty)
                        AppText(
                          detail!,
                          style: text.bodyXs,
                          color: colors.textSecondary,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  AppSvgIcon(
                    AppAssets.check,
                    size: LocationDimens.selectedCheck,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
