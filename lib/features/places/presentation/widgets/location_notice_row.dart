import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// A line of plain words under the search: "Search needs a connection", "Couldn't search".
class LocationNoticeRow extends StatelessWidget {
  const LocationNoticeRow({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.s12,
      vertical: AppSpacing.s12,
    ),
    child: Semantics(
      liveRegion: true,
      child: AppText(
        message,
        style: context.text.bodySm,
        color: context.appColors.textSecondary,
      ),
    ),
  );
}
