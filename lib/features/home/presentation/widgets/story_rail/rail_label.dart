import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';

/// The one-line name under a rail circle.
class RailLabel extends StatelessWidget {
  const RailLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: StoryDimens.railLabelGap),
    child: SizedBox(
      width: StoryDimens.railAvatar,
      child: AppText(
        text,
        style: context.text.caption,
        color: color ?? context.appColors.textSecondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
