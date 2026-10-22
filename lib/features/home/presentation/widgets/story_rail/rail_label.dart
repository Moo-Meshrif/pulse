import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/home_dimens.dart';

/// The name under a rail circle.
class RailLabel extends StatelessWidget {
  const RailLabel(this.text, {super.key, this.color});

  /// A name with several words wraps onto up to two lines, one word per line; a single word stays on one.
  static int maxLinesFor(String text) =>
      text.trim().contains(RegExp(r'\s')) ? 2 : 1;

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: StoryRailDimens.railLabelGap),
    child: SizedBox(
      width: StoryRailDimens.railAvatar,
      child: AppText(
        text,
        style: context.text.caption,
        color: color ?? context.appColors.textSecondary,
        maxLines: maxLinesFor(text),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
