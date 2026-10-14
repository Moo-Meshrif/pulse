import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../home_header.dart';
import '../story_rail/story_rail.dart';

/// [body] centered on the whole page, with the header and the rail on top of it. They have their own
/// background, so a body taller than the page (large text) scrolls under them.
class FeedMessagePage extends StatelessWidget {
  const FeedMessagePage({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(child: body),
      Align(
        alignment: Alignment.topCenter,
        child: ColoredBox(
          color: context.appColors.background,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [HomeHeader(), StoryRail()],
          ),
        ),
      ),
    ],
  );
}
