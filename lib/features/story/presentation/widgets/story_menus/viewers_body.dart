import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import 'viewers_header.dart';
import 'viewers_list.dart';

class ViewersBody extends StatelessWidget {
  const ViewersBody({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final height = MediaQuery.sizeOf(context).height;
    final initial = (StoryDimens.viewersHeight / height).clamp(
      0.0,
      StoryDimens.viewersMaxFraction,
    );
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initial,
      minChildSize: initial,
      maxChildSize: StoryDimens.viewersMaxFraction,
      builder: (context, controller) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.storySheet,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheetTop),
          ),
          boxShadow: AppShadows.bottomSheet,
        ),
        child: AppSafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(height: BottomSheetDimens.topPadding),
              Container(
                width: BottomSheetDimens.grabberWidth,
                height: BottomSheetDimens.grabberHeight,
                decoration: BoxDecoration(
                  color: colors.storyOnDark.withValues(
                    alpha: StoryOpacity.grabber,
                  ),
                  borderRadius: BorderRadius.circular(
                    BottomSheetDimens.grabberRadius,
                  ),
                ),
              ),
              SizedBox(height: BottomSheetDimens.grabberToTitleGap),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: BottomSheetDimens.sidePadding,
                ),
                child: const ViewersHeader(),
              ),
              Expanded(child: ViewersList(controller: controller)),
            ],
          ),
        ),
      ),
    );
  }
}
