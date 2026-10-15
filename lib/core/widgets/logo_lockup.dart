import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_scale.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_text.dart';

/// Logo mark + the "pulse" wordmark. In RTL the pair moves as a unit; the drawing never flips and the
/// wordmark stays Latin. Decorative, read as one label.
class LogoLockup extends StatelessWidget {
  const LogoLockup({super.key});

  @override
  Widget build(BuildContext context) {
    final wordmark = AppTextStyles.latin.logo.copyWith(
      fontSize: AppScale.scale(20),
      color: context.appColors.textPrimary,
    );
    return Semantics(
      label: context.l10n.appTitle,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(LogoDimens.markRadius),
              child: SvgPicture.asset(
                AppAssets.logo,
                width: LogoDimens.markSize,
                height: LogoDimens.markSize,
              ),
            ),
            SizedBox(width: LogoDimens.markToWordmarkGap),
            Flexible(child: AppText(context.l10n.appTitle, style: wordmark)),
          ],
        ),
      ),
    );
  }
}
