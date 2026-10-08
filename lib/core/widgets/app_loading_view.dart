import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_dimens.dart';
import 'app_spinner.dart';

/// A screen body that waits for its first data: a `primary` spinner centered in the available space,
/// announced as "Loading". Put it inside a `Scaffold` body.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: AppSpinner(
      size: LoadingDimens.size,
      strokeWidth: LoadingDimens.stroke,
      color: context.appColors.primary,
      semanticsLabel: context.l10n.loading,
    ),
  );
}
