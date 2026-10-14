import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/snack_bar_context.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/new_post_cubit.dart';
import '../cubit/new_post_state.dart';
import '../utils/enums/new_post_notice.dart';
import '../view/new_post_view.dart';

/// `/create/post`: write and share a post (docs/specs/post/screens/s1-new-post.md). Closing with
/// something written asks first; nothing closes it while it uploads.
class NewPostScreen extends StatelessWidget {
  const NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<NewPostCubit>()..loadDefaultVisibility(),
    child: Builder(
      builder: (context) => BlocListener<NewPostCubit, NewPostState>(
        listenWhen: _isSharedOrHasNewNotice,
        listener: _closeOrShowNotice,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeAskingFirst(context);
          },
          child: NewPostView(onClose: () => _closeAskingFirst(context)),
        ),
      ),
    ),
  );

  bool _isSharedOrHasNewNotice(NewPostState before, NewPostState now) =>
      (!before.isShared && now.isShared) ||
      (before.notice == null && now.notice != null);

  Future<void> _closeAskingFirst(BuildContext context) async {
    final state = context.read<NewPostCubit>().state;
    if (state.isSharing) return;
    if (!state.hasContent) {
      AppNavigator.back(context);
      return;
    }
    final l10n = context.l10n;
    final discard = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: l10n.newPostDiscardTitle,
      message: l10n.newPostDiscardBody,
      confirmLabel: l10n.newPostDiscard,
      cancelLabel: l10n.newPostKeepEditing,
    );
    if (discard == true && context.mounted) AppNavigator.back(context);
  }

  void _closeOrShowNotice(BuildContext context, NewPostState state) {
    final cubit = context.read<NewPostCubit>();
    if (state.isShared) {
      final messenger = ScaffoldMessenger.of(context);
      final message = context.l10n.newPostShared;
      // TODO(post-plan T5): Home does not exist yet, so its feed is not refreshed here.
      AppNavigator.back(context);
      messenger.showNotice(message);
      return;
    }
    final notice = state.notice;
    if (notice == null) return;
    context.showSnackBar(
      notice.message(context),
      actionLabel: notice == NewPostNotice.shareFailed
          ? context.l10n.retry
          : null,
      onAction: notice == NewPostNotice.shareFailed ? cubit.share : null,
    );
    cubit.clearNotice();
  }
}
