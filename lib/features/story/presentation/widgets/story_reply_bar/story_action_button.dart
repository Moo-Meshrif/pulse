import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';

class StoryActionButton extends StatelessWidget {
  const StoryActionButton({
    super.key,
    required this.asset,
    required this.label,
    required this.size,
    required this.onTap,
    this.color,
    this.isDirectional = false,
  });

  final String asset;
  final String label;
  final double size;
  final VoidCallback onTap;
  final Color? color;
  final bool isDirectional;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onTap,
      radius: StoryDimens.replyAction / 2,
      child: SizedBox.square(
        dimension: StoryDimens.replyAction,
        child: Center(
          child: AppSvgIcon(
            asset,
            size: size,
            color: color ?? context.appColors.storyOnDark,
            directional: isDirectional,
          ),
        ),
      ),
    ),
  );
}
