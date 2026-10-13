import 'package:flutter/material.dart';

import '../../../../../core/enums/sheet_tone.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/extensions/failure_l10n.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/extensions/snack_bar_context.dart';
import '../../../../../core/utils/cached_picture.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/story_media_type.dart';
import '../../cubit/story_viewer_cubit.dart';
import '../../utils/story_snapshot.dart';
import 'story_confirm_dialog.dart';

/// What the "···" sheet's rows do to the story on screen: mute, report, save, delete. Each takes what it
/// needs from the screen before its first `await` (the screen may be gone when it ends: the last story
/// deleted), and tells the person with a notice.
abstract final class StoryMenuActions {
  static Future<void> mute(BuildContext context, StoryViewerCubit cubit) async {
    final person = cubit.state.person;
    if (person == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final failure = await cubit.muteCurrent();
    if (failure != null) {
      if (context.mounted) context.showFailure(failure);
      return;
    }
    messenger.showNotice(
      l10n.storyMuted(person.username),
      actionLabel: l10n.undo,
      onAction: () => cubit.unmute(person.authorId),
    );
  }

  static Future<void> report(
    BuildContext context,
    StoryViewerCubit cubit,
  ) async {
    final storyId = cubit.state.story?.id;
    if (storyId == null) return;
    final l10n = context.l10n;
    final sent = await ReportSheet.show(
      context,
      tone: SheetTone.dark,
      copy: ReportCopy(
        title: l10n.storyReportTitle,
        body: l10n.storyReportBody,
        sentBody: l10n.storyReportSent,
        notePlaceholder: l10n.storyReportNotePlaceholder,
      ),
      onSubmit: (reason, note) => cubit.report(storyId, reason, note),
    );
    if (sent) await cubit.skipReported();
  }

  static Future<void> save(BuildContext context, StoryViewerCubit cubit) async {
    final story = cubit.state.story;
    if (story == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final Failure? failure;
    if (story.type == StoryMediaType.video) {
      // TODO(story-plan T4): the video is saved without its stickers; burn-in comes later (P4).
      failure = story.mediaUrl == null
          ? const UnexpectedFailure()
          : await cubit.saveVideo(story.mediaUrl!);
    } else {
      final url = story.mediaUrl;
      final bytes = url == null
          ? null
          : await renderStoryImage(
              context,
              image: cachedPicture(url, cacheKey: story.path),
              overlays: story.overlays ?? const [],
              width: story.width,
            );
      failure = bytes == null
          ? const UnexpectedFailure()
          : await cubit.saveImage(bytes);
    }
    if (!context.mounted) return;
    messenger.showNotice(
      failure == null ? l10n.storySaved : failure.l10n(context),
    );
  }

  static Future<void> delete(
    BuildContext context,
    StoryViewerCubit cubit,
  ) async {
    final story = cubit.state.story;
    if (story == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final confirmed = await StoryDeleteDialog.show(
      context,
      viewCount: story.viewCount ?? 0,
    );
    if (!confirmed) return;
    final failure = await cubit.deleteCurrent();
    messenger.showNotice(
      failure == null
          ? l10n.storyDeleted
          : context.mounted
          ? failure.l10n(context)
          : null,
    );
  }
}
