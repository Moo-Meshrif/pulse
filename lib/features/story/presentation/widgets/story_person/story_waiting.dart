import 'package:flutter/material.dart';

import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entity/story_rail_item_entity.dart';
import '../story_buffering_loader.dart';
import '../story_loading_top.dart';

class StoryWaiting extends StatelessWidget {
  const StoryWaiting({
    super.key,
    required this.person,
    required this.hasFailed,
    required this.onRetry,
    required this.onClose,
  });

  final StoryRailItemEntity person;
  final bool hasFailed;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasFailed)
          AppEmpty.failed(tone: AppEmptyTone.onDark, onRetry: onRetry)
        else
          const StoryBufferingLoader(isWaiting: true),
        StoryLoadingTop(person: person, onClose: onClose),
      ],
    );
  }
}
