import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_dimens.dart';

/// What the Who can see this sheet shows while its numbers load, and when they could not: one loader, or a
/// message with Retry, in a space the size of the sheet's rows.
class AudienceSheetLoading extends StatelessWidget {
  const AudienceSheetLoading({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: StoryDimens.viewersHeight / 2,
    child: Center(
      child: PulseLineLoader(
        color: context.appColors.onDark,
        width: LoadingDimens.pageWidth,
      ),
    ),
  );
}

class AudienceSheetLoadFailed extends StatelessWidget {
  const AudienceSheetLoadFailed({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: StoryDimens.viewersHeight / 2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              context.l10n.storyAudienceLoadFailed,
              style: context.text.bodySm,
              color: colors.onDark.withValues(alpha: DarkOpacity.subtitle),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: onRetry,
              child: AppText(
                context.l10n.retry,
                style: context.text.name,
                color: colors.onDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
