import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

/// An unknown route or a broken deep link; the top bar's back arrow is the way out.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppPage(child: AppEmpty.notFound());
}
