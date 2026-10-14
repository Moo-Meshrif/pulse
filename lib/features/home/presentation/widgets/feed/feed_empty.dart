import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/widgets/widgets.dart';
import 'feed_message_page.dart';

/// Nothing to show yet (follows nobody, or nobody posted): the header and rail stay, a page below says so.
class FeedEmpty extends StatelessWidget {
  const FeedEmpty({super.key});

  // TODO(home-plan H4): "Find people" opens the Search placeholder until a suggestions page exists.
  void _findPeople(BuildContext context) =>
      AppNavigator.push<void>(context, AppRoutes.search);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FeedMessagePage(
      body: AppEmpty(
        icon: AppAssets.inbox,
        title: l10n.homeEmptyTitle,
        message: l10n.homeEmptyBody,
        primaryLabel: l10n.homeFindPeople,
        onPrimary: () => _findPeople(context),
      ),
    );
  }
}
