import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../utils/enums/create_option.dart';

/// One row of the Create sheet: an icon tile, the title with its description, and a chevron that mirrors
/// in RTL. The whole row is the button.
class CreateOptionRow extends StatelessWidget {
  const CreateOptionRow({super.key, required this.option, required this.onTap});

  final CreateOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(BottomSheetDimens.optionRadius);
    final title = option.title(context);
    final subtitle = option.subtitle(context);
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: colors.background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: BottomSheetDimens.optionMinHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(BottomSheetDimens.optionPadding),
              child: Row(
                children: [
                  _IconTile(asset: option.icon),
                  SizedBox(width: BottomSheetDimens.optionContentGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          title,
                          style: context.text.button,
                          color: colors.textPrimary,
                        ),
                        SizedBox(height: BottomSheetDimens.optionSubtitleGap),
                        AppText(
                          subtitle,
                          style: context.text.bodyXs,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: BottomSheetDimens.optionContentGap),
                  AppSvgIcon(
                    AppAssets.chevronRight,
                    size: BottomSheetDimens.optionChevron,
                    color: colors.textSecondary,
                    directional: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: BottomSheetDimens.optionTile,
      height: BottomSheetDimens.optionTile,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(BottomSheetDimens.optionTileRadius),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(
        asset,
        size: BottomSheetDimens.optionTileIcon,
        color: colors.primary,
      ),
    );
  }
}
