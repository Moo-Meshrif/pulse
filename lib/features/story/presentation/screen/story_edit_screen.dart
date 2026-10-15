import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/model/story_overlay_model.dart';
import '../../domain/entity/captured_story_media.dart';
import '../cubit/story_edit_cubit.dart';
import '../cubit/story_edit_state.dart';
import '../utils/enums/story_edit_notice.dart';
import '../view/story_edit_view.dart';
import '../widgets/story_menus/story_confirm_dialog.dart';

/// `/create/story/edit`: stickers and Share for the photo or video the camera (or the library) gave
/// (docs/specs/story/screens/s3-create-edit.md). Share goes back to Home while the upload runs.
class StoryEditScreen extends StatelessWidget {
  const StoryEditScreen({super.key, required this.media});

  final CapturedStoryMedia media;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<StoryEditCubit>(param1: media),
    child: Builder(
      builder: (context) => BlocListener<StoryEditCubit, StoryEditState>(
        listenWhen: (before, now) =>
            (!before.isShared && now.isShared) ||
            (before.notice == null && now.notice != null),
        listener: _onEffect,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _discard(context);
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              backgroundColor: context.appColors.black,
              resizeToAvoidBottomInset: false,
              body: StoryEditView(onClose: () => _discard(context)),
            ),
          ),
        ),
      ),
    ),
  );

  /// X and system back: nothing is lost without asking.
  Future<void> _discard(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await StoryConfirmDialog.show(
      context,
      title: l10n.storyDiscardTitle,
      body: l10n.storyDiscardBody,
      confirmLabel: l10n.storyDiscard,
      cancelLabel: l10n.storyKeepEditing,
    );
    if (confirmed && context.mounted) AppNavigator.back(context);
  }

  void _onEffect(BuildContext context, StoryEditState state) {
    final cubit = context.read<StoryEditCubit>();
    if (state.isShared) {
      AppNavigator.backTo(context, AppRoutes.home);
      return;
    }
    final l10n = context.l10n;
    final notice = state.notice;
    if (notice == null) return;
    switch (notice) {
      case StoryEditNotice.uploadBusy:
        Notices.info(l10n.storyUploadBusy);
      case StoryEditNotice.shareFailed:
        Notices.error(l10n.storyShareFailed);
      case StoryEditNotice.saved:
        Notices.success(l10n.storySaved);
      case StoryEditNotice.saveFailed:
        Notices.error(l10n.errorGeneric);
      case StoryEditNotice.stickerLimit:
        Notices.info(l10n.storyStickerLimit(StoryOverlayModel.maxPerStory));
    }
    cubit.clearNotice();
  }
}
