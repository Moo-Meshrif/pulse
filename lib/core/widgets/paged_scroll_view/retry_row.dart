import 'package:flutter/material.dart';

import '../../extensions/context_extensions.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/dimens/app_dimens.dart';
import '../app_text.dart';

/// "Couldn't load more · Retry": the footer of a list whose next page failed.
class RetryRow extends StatelessWidget {
  const RetryRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    excludeSemantics: true,
    label: label,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: LoadingDimens.loadMoreBand,
        child: Center(
          child: AppText(
            label,
            style: context.text.meta,
            color: context.appColors.primary,
          ),
        ),
      ),
    ),
  );
}
