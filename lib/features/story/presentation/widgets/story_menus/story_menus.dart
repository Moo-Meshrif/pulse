import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/enums/sheet_tone.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/story_audience.dart';
import '../../cubit/story_viewer_cubit.dart';
import '../../utils/enums/story_option.dart';
import '../../utils/enums/story_pause_reason.dart';
import '../story_audience/story_audience_sheet.dart';
import 'story_menu_actions.dart';
import 'story_options_sheet.dart';
import 'story_viewers_sheet.dart';

/// The flows behind the viewer's "···" button and the swipe up on your own story
/// (docs/specs/story/screens/s6-viewer-menus.md). The story stands still ([StoryPauseReason.overlay]) from
/// the first sheet until the last one closes. They take what they need from the screen before the first
/// `await`: the screen may be gone when a flow ends (the last story deleted).
abstract final class StoryMenus {
  /// The "···" sheet, then whatever the person picked.
  static Future<void> showOptions(BuildContext context) async {
    final cubit = context.read<StoryViewerCubit>();
    final person = cubit.state.person;
    final story = cubit.state.story;
    if (person == null || story?.id == null) return;
    await _paused(cubit, () async {
      final option = await AppBottomSheet.show<StoryOption>(
        context,
        tone: SheetTone.dark,
        child: StoryOptionsSheet(
          person: person,
          viewCount: story!.viewCount ?? 0,
          audience: story.audience ?? StoryAudience.followers,
        ),
      );
      if (option == null || !context.mounted) return;
      await _carryOut(context, cubit, option);
    });
  }

  /// The viewers sheet of your own story.
  static Future<void> showViewers(BuildContext context) async {
    final cubit = context.read<StoryViewerCubit>();
    if (!(cubit.state.person?.isMe ?? false) || cubit.state.story == null) {
      return;
    }
    await _paused(cubit, () => _viewers(context, cubit));
  }

  static Future<void> _carryOut(
    BuildContext context,
    StoryViewerCubit cubit,
    StoryOption option,
  ) async {
    switch (option) {
      case StoryOption.mute:
        await StoryMenuActions.mute(context, cubit);
      case StoryOption.goToProfile:
        final id = cubit.state.person?.authorId;
        if (id != null) {
          await AppNavigator.push(
            context,
            AppRoutes.profileOf(id),
            rootNavigator: true,
          );
        }
      case StoryOption.report:
        await StoryMenuActions.report(context, cubit);
      case StoryOption.save:
        await StoryMenuActions.save(context, cubit);
      case StoryOption.audience:
        await _audience(context, cubit);
      case StoryOption.viewers:
        await _viewers(context, cubit);
      case StoryOption.delete:
        await StoryMenuActions.delete(context, cubit);
    }
  }

  static Future<void> _audience(
    BuildContext context,
    StoryViewerCubit cubit,
  ) async {
    final story = cubit.state.story;
    final id = story?.id;
    if (id == null) return;
    final audience = await StoryAudienceSheet.show(
      context,
      storyId: id,
      audience: story!.audience ?? StoryAudience.followers,
    );
    cubit.updateAudience(id, audience);
  }

  static Future<void> _viewers(
    BuildContext context,
    StoryViewerCubit cubit,
  ) async {
    final story = cubit.state.story;
    final id = story?.id;
    if (id == null) return;
    final option = await StoryViewersSheet.show(
      context,
      storyId: id,
      viewCount: story!.viewCount ?? 0,
    );
    if (option == null || !context.mounted) return;
    await _carryOut(context, cubit, option);
  }

  static Future<void> _paused(
    StoryViewerCubit cubit,
    Future<void> Function() flow,
  ) async {
    cubit.pause(StoryPauseReason.overlay);
    try {
      await flow();
    } finally {
      cubit.resume(StoryPauseReason.overlay);
    }
  }
}
