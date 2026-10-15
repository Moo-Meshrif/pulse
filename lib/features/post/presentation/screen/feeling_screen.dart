import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../data/enums/mood_kind.dart';
import '../../domain/entity/post_mood_entity.dart';
import '../utils/mood_choice.dart';
import '../view/feeling_view.dart';

/// `/create/post/feeling`: choose how you feel (docs/specs/post/screens/s8-feeling-activity.md, Feelings
/// only). A tap on a feeling goes back with it at once; the chosen one tapped again, or Remove, goes back
/// with no mood; the back arrow goes back with nothing. [current] is the mood the post has.
class FeelingScreen extends StatelessWidget {
  const FeelingScreen({super.key, this.current});

  final PostMoodEntity? current;

  @override
  Widget build(BuildContext context) => FeelingView(
    selectedKey: current?.kind == MoodKind.feeling ? current?.key : null,
    canRemove: current != null,
    onPick: (key) => AppNavigator.back(
      context,
      MoodChoice(
        key == current?.key && current?.kind == MoodKind.feeling
            ? null
            : PostMoodEntity(kind: MoodKind.feeling, key: key),
      ),
    ),
    onRemove: () => AppNavigator.back(context, const MoodChoice(null)),
    onBack: () => AppNavigator.back(context),
    // TODO(post-plan T13): activities (list, verbs, suggestions) come later from an API or a database.
    onActivities: () => Notices.info(context.l10n.comingSoon),
  );
}
