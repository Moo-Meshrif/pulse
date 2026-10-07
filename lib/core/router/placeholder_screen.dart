import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

/// Stand-in for a screen that has not been specced yet (Sign in, Registration).
/// Replace the route's builder in `AppRouter` when the real screen exists.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.route});

  final String route;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: AppText(route)));
}
