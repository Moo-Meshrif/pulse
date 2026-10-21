import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/story_post_args.dart';
import '../cubit/story_post_edit/story_post_edit_cubit.dart';
import '../cubit/story_post_edit/story_post_edit_state.dart';
import '../utils/story_edit_effects.dart';
import '../view/story_post_edit_view.dart';

/// `/create/story/post`: a story that shows a post as a sticker over a gradient background
/// (docs/specs/post/screens/s13-add-to-story.md). Share goes back to Home while the upload runs.
class StoryPostEditScreen extends StatelessWidget {
  const StoryPostEditScreen({super.key, required this.post});

  final StoryPostArgs post;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<StoryPostEditCubit>(param1: post)..loadMediaColors(),
    child: Builder(
      builder: (context) =>
          BlocListener<StoryPostEditCubit, StoryPostEditState>(
            listenWhen: (before, now) =>
                (!before.isShared && now.isShared) ||
                (before.notice == null && now.notice != null),
            listener: _onEffect,
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) StoryEditEffects.discard(context);
              },
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: Scaffold(
                  backgroundColor: context.appColors.black,
                  resizeToAvoidBottomInset: false,
                  body: StoryPostEditView(
                    onClose: () => StoryEditEffects.discard(context),
                  ),
                ),
              ),
            ),
          ),
    ),
  );

  void _onEffect(BuildContext context, StoryPostEditState state) {
    final cubit = context.read<StoryPostEditCubit>();
    if (state.isShared) {
      AppNavigator.backTo(context, AppRoutes.home);
      return;
    }
    final notice = state.notice;
    if (notice == null) return;
    StoryEditEffects.showNotice(context, notice);
    cubit.clearNotice();
  }
}
