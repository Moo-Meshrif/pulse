import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../home_header.dart';

/// Floats in on any scroll up and snaps back out of the way.
class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) => SliverAppBar(
    floating: true,
    snap: true,
    primary: false,
    automaticallyImplyLeading: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: context.appColors.background,
    surfaceTintColor: Colors.transparent,
    titleSpacing: 0,
    toolbarHeight: HomeDimens.headerHeight,
    title: const HomeHeader(),
  );
}
