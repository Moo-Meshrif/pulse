import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../utils/tab_handle.dart';

/// One tab's own Navigator: its pages push inside it, so the nav bar stays visible. Its root page is
/// [root]; any other named route resolves through `AppRouter`, like everywhere else.
class TabNavigator extends StatelessWidget {
  const TabNavigator({super.key, required this.handle, required this.root});

  final TabHandle handle;
  final WidgetBuilder root;

  @override
  Widget build(BuildContext context) => Navigator(
    key: handle.navigatorKey,
    onGenerateRoute: (settings) => settings.name == Navigator.defaultRouteName
        ? MaterialPageRoute<void>(
            settings: settings,
            builder: (context) {
              handle.rootScroll = PrimaryScrollController.maybeOf(context);
              return root(context);
            },
          )
        : AppRouter.onGenerateRoute(settings),
  );
}
