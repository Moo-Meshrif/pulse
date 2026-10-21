import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/enums/dialog_choice.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entity/post_entity.dart';
import '../cubit/add_edit_post/add_edit_post_cubit.dart';
import '../cubit/add_edit_post/add_edit_post_state.dart';
import '../view/add_edit_post_view.dart';

/// `/create/post`: write and share a post (docs/specs/post/screens/s1-new-post.md). Closing with
/// something written asks first: a new post offers Save draft / Discard post / Keep editing, an edit asks
/// to discard the changes. The draft is also saved when the app goes to the background. Share closes it
/// at once; the post is sent in the background.

class AddEditPostArgs {
  final PostEntity? post;
  final Map<String, String>? signedUrls;

  AddEditPostArgs({this.post, this.signedUrls});
}

class AddEditPostScreen extends StatelessWidget {
  /// [AddEditPostArgs] is the data to edit; null adds a new one.
  const AddEditPostScreen({super.key, this.args});

  final AddEditPostArgs? args;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<AddEditPostCubit>(param1: args?.post, param2: args?.signedUrls)
          ..loadDefaultVisibility()
          ..loadUrls(),
    child: Builder(
      builder: (context) => BlocListener<AddEditPostCubit, AddEditPostState>(
        listenWhen: _isSavedOrHasNewNotice,
        listener: _closeOrShowNotice,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeAskingFirst(context);
          },
          // A phone may kill the app once it is hidden: the draft is saved at once.
          child: OnAppVisibility(
            onHide: () => context.read<AddEditPostCubit>().saveDraftOpen(),
            child: AddEditPostView(onClose: () => _closeAskingFirst(context)),
          ),
        ),
      ),
    ),
  );

  bool _isSavedOrHasNewNotice(AddEditPostState before, AddEditPostState now) =>
      (!before.isSaved && now.isSaved) ||
      (before.notice == null && now.notice != null);

  Future<void> _closeAskingFirst(BuildContext context) async {
    final state = context.read<AddEditPostCubit>().state;
    if (!state.hasContent) {
      AppNavigator.back(context);
      return;
    }
    if (state.isEditing) {
      await _closeEditAskingFirst(context);
    } else {
      await _closeNewAskingFirst(context);
    }
  }

  Future<void> _closeEditAskingFirst(BuildContext context) async {
    final l10n = context.l10n;
    final discard = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: l10n.editPostDiscardTitle,
      message: l10n.editPostDiscardBody,
      confirmLabel: l10n.newPostDiscard,
      cancelLabel: l10n.newPostKeepEditing,
    );
    if (discard == true && context.mounted) AppNavigator.back(context);
  }

  Future<void> _closeNewAskingFirst(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<AddEditPostCubit>();
    final choice = await ConfirmationDialog.choice(
      context,
      icon: AppAssets.document,
      title: l10n.newPostDraftTitle,
      message: l10n.newPostDraftBody,
      primaryLabel: l10n.newPostSaveDraft,
      dangerLabel: l10n.newPostDiscardPost,
      cancelLabel: l10n.newPostKeepEditing,
    );
    switch (choice) {
      case DialogChoice.primary:
        await cubit.saveDraft();
      case DialogChoice.danger:
        await cubit.discardDraft();
      case DialogChoice.cancel || null:
        return;
    }
    if (context.mounted) AppNavigator.back(context);
  }

  void _closeOrShowNotice(BuildContext context, AddEditPostState state) {
    final cubit = context.read<AddEditPostCubit>();
    if (state.isSaved) {
      AppNavigator.back(context);
      return;
    }
    final notice = state.notice;
    if (notice == null) return;
    Notices.info(notice.message(context));
    cubit.clearNotice();
  }
}
