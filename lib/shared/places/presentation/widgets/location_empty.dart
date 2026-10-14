import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// Panel 3: a pin and "No places found", centered in the space under the search.
class LocationEmpty extends StatelessWidget {
  const LocationEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: AppSvgIcon(
                AppAssets.locationThin,
                size: LocationDimens.emptyIcon,
                color: colors.primary,
              ),
            ),
            SizedBox(height: AppSpacing.s16),
            AppText(
              context.l10n.locationNoResults,
              style: context.text.stat,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
