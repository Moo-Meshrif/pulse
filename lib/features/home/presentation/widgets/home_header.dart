import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/bell_dot/bell_dot_cubit.dart';
import '../dimens/home_dimens.dart';
import 'home_icon_button.dart';

/// The top of the feed: the logo and "pulse" at the start, Search and the bell at the end.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  void _openSearch(BuildContext context) =>
      AppNavigator.push<void>(context, AppRoutes.search);

  void _openActivity(BuildContext context) =>
      AppNavigator.push<void>(context, AppRoutes.activity);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: HomeDimens.headerPadding,
      child: Row(
        children: [
          const LogoTile.header(),
          SizedBox(width: HomeDimens.logoGap),
          Expanded(
            child: ExcludeSemantics(
              child: AppText(
                l10n.appTitle,
                // The wordmark stays Latin in Arabic too.
                style: AppTextStyles.latin.logo,
                color: context.appColors.textPrimary,
                maxLines: 1,
              ),
            ),
          ),
          HomeIconButton(
            icon: AppAssets.search,
            label: l10n.homeSearch,
            onTap: () => _openSearch(context),
          ),
          SizedBox(width: HomeDimens.actionGap),
          HomeIconButton(
            icon: AppAssets.bell,
            label: l10n.homeActivity,
            onTap: () => _openActivity(context),
            badge: const _BellDot(),
          ),
        ],
      ),
    );
  }
}

/// The bell's red dot, for tests to find.
@visibleForTesting
const bellDotKey = ValueKey('home-bell-dot');

class _BellDot extends StatelessWidget {
  const _BellDot();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<BellDotCubit, bool>(
      builder: (context, hasUnread) => hasUnread
          ? PositionedDirectional(
              top: HomeDimens.bellDotTop,
              end: HomeDimens.bellDotEnd,
              child: IgnorePointer(
                child: Container(
                  key: bellDotKey,
                  width: HomeDimens.bellDot,
                  height: HomeDimens.bellDot,
                  decoration: BoxDecoration(
                    color: colors.like,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.background,
                      width: HomeDimens.bellDotBorder,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
