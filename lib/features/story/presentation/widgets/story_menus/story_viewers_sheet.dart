import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_breakpoints.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/story_viewers/story_viewers_cubit.dart';
import '../../dimens/story_constants.dart';
import '../../utils/enums/story_option.dart';
import 'viewers_body.dart';

/// Who viewed your story (docs/specs/story/screens/s6-viewer-menus.md > Viewers sheet): a dark sheet over
/// the dimmed story, 430 high and draggable to 90%. Pops with [StoryOption.delete] or [StoryOption.save]
/// when the header buttons are used.
abstract final class StoryViewersSheet {
  static Future<StoryOption?> show(
    BuildContext context, {
    required String storyId,
    required int viewCount,
  }) => showModalBottomSheet<StoryOption>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: context.appColors.black.withValues(
      alpha: StoryOpacity.viewersDim,
    ),
    constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxContentWidth),
    sheetAnimationStyle: AppBottomSheet.storySheetAnimation(context),
    builder: (_) => BlocProvider(
      create: (_) =>
          getIt<StoryViewersCubit>()..load(storyId, knownTotal: viewCount),
      child: const ViewersBody(),
    ),
  );
}
