import 'package:flutter/material.dart';

import '../../features/auth/presentation/widgets/auth_close_button.dart';
import '../extensions/context_extensions.dart';
import '../router/app_navigator.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_back_button.dart';

/// The top bar of every screen: the back arrow of the sign-up steps (shown when there is a screen to go
/// back to) and an optional [title], on the same `background` as the screen body, with no elevation.
/// Pass it as `AppPage.appBar`. [onBack] replaces the default pop.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.onBack,
    this.isCloseButton = false,
  });

  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onBack;
  final bool isCloseButton;

  @override
  Size get preferredSize =>
      Size.fromHeight(AppSpacing.headerSide + AuthDimens.tapTarget);

  @override
  Widget build(BuildContext context) {
    final showBack = onBack != null || AppNavigator.canBack(context);
    return ColoredBox(
      color: context.appColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: AppSpacing.headerSide,
            start: showBack ? AppSpacing.headerBackSide : AppSpacing.headerSide,
            end: AppSpacing.headerSide,
          ),
          child: Row(
            children: [
              if (showBack)
                isCloseButton
                    ? AuthCloseButton(
                        onPressed: onBack ?? () => AppNavigator.back(context),
                      )
                    : AppBackButton(
                        onPressed: onBack ?? () => AppNavigator.back(context),
                      ),
              if (titleWidget != null)
                Expanded(child: titleWidget!)
              else if (title != null)
                Expanded(child: Text(title!, style: context.text.title)),
            ],
          ),
        ),
      ),
    );
  }
}
