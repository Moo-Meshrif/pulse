import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// A profile photo full screen: black background, pinch to zoom, a close button.
// TODO(profile-plan T11): photo viewer design not given
class PhotoViewer extends StatelessWidget {
  const PhotoViewer({super.key, required this.url});

  final String url;

  static Future<void> show(BuildContext context, String url) =>
      showGeneralDialog<void>(
        context: context,
        barrierColor: context.appColors.black,
        barrierLabel: context.l10n.close,
        barrierDismissible: true,
        useRootNavigator: true,
        pageBuilder: (_, _, _) => PhotoViewer(url: url),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appColors.black,
    body: AppSafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 4,
              child: Center(child: AppImage.network(url, fit: BoxFit.contain)),
            ),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            child: Semantics(
              button: true,
              label: context.l10n.close,
              excludeSemantics: true,
              child: InkResponse(
                onTap: () => AppNavigator.back(context),
                child: SizedBox.square(
                  dimension: AppSizes.tapTarget,
                  child: Center(
                    child: AppSvgIcon(
                      AppAssets.close,
                      size: AppSizes.topBarIcon,
                      color: context.appColors.onDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
