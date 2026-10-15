import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entity/post_entity.dart';
import '../cubit/add_edit_post_cubit.dart';
import '../cubit/add_edit_post_state.dart';
import '../utils/enums/new_post_notice.dart';
import '../view/add_edit_post_view.dart';

/// `/create/post`: write and share a post (docs/specs/post/screens/s1-new-post.md). Closing with
/// something written asks first; nothing closes it while it uploads.
class AddEditPostScreen extends StatelessWidget {
  /// [post] is the post to edit; null adds a new one.
  const AddEditPostScreen({super.key, this.post});

  final PostEntity? post;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AddEditPostCubit>(param1: post)
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
          child: AddEditPostView(onClose: () => _closeAskingFirst(context)),
        ),
      ),
    ),
  );

  bool _isSavedOrHasNewNotice(AddEditPostState before, AddEditPostState now) =>
      (!before.isSaved && now.isSaved) ||
      (before.notice == null && now.notice != null);

  Future<void> _closeAskingFirst(BuildContext context) async {
    final state = context.read<AddEditPostCubit>().state;
    if (state.isSaving) return;
    if (!state.hasContent) {
      AppNavigator.back(context);
      return;
    }
    final l10n = context.l10n;
    final discard = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: state.isEditing
          ? l10n.editPostDiscardTitle
          : l10n.newPostDiscardTitle,
      message: state.isEditing
          ? l10n.editPostDiscardBody
          : l10n.newPostDiscardBody,
      confirmLabel: l10n.newPostDiscard,
      cancelLabel: l10n.newPostKeepEditing,
    );
    if (discard == true && context.mounted) AppNavigator.back(context);
  }

  void _closeOrShowNotice(BuildContext context, AddEditPostState state) {
    final cubit = context.read<AddEditPostCubit>();
    if (state.isSaved) {
      final messenger = ScaffoldMessenger.of(context);
      final message = state.isEditing
          ? context.l10n.postUpdated
          : context.l10n.newPostShared;
      AppNavigator.back(context);
      messenger.showNotice(message);
      return;
    }
    final notice = state.notice;
    if (notice == null) return;
    final isSendFailure =
        notice == NewPostNotice.shareFailed ||
        notice == NewPostNotice.saveFailed;
    context.showSnackBar(
      notice.message(context),
      actionLabel: isSendFailure ? context.l10n.retry : null,
      onAction: isSendFailure ? cubit.save : null,
    );
    cubit.clearNotice();
  }
}
