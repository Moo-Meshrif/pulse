import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../app_text.dart';

/// The footer after the last page.
class CaughtUpRow extends StatelessWidget {
  const CaughtUpRow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: LoadingDimens.endBand,
    child: Center(
      child: AppText(
        label,
        style: context.text.bodyXs,
        color: context.appColors.textSecondary,
      ),
    ),
  );
}
