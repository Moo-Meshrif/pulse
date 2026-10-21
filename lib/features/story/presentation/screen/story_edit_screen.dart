import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entity/captured_story_media.dart';
import '../cubit/story_edit/story_edit_cubit.dart';
import '../cubit/story_edit/story_edit_state.dart';
import '../utils/story_edit_effects.dart';
import '../view/story_edit_view.dart';

/// `/create/story/edit`: stickers and Share for the photo or video the camera (or the library) gave
/// (docs/specs/story/screens/s3-create-edit.md). Share goes back to Home while the upload runs.
class StoryEditScreen extends StatelessWidget {
  const StoryEditScreen({super.key, required this.media});

  final CapturedStoryMedia media;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<StoryEditCubit>(param1: media)..loadTrimFrames(),
    child: Builder(
      builder: (context) => BlocListener<StoryEditCubit, StoryEditState>(
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
              body: StoryEditView(
                onClose: () => StoryEditEffects.discard(context),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  void _onEffect(BuildContext context, StoryEditState state) {
    final cubit = context.read<StoryEditCubit>();
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
