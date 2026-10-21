import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/story_camera/story_camera_cubit.dart';
import '../cubit/story_camera/story_camera_state.dart';
import '../utils/enums/story_camera_notice.dart';
import '../view/story_camera_view.dart';

/// `/create/story`: the camera behind the camera and microphone permission gate
/// (docs/specs/story/screens/s2-create-camera.md). A photo or video goes on to the edit screen.
class StoryCameraScreen extends StatelessWidget {
  const StoryCameraScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<StoryCameraCubit>(),
    child: Builder(
      builder: (context) => BlocListener<StoryCameraCubit, StoryCameraState>(
        listenWhen: (before, now) =>
            (before.captured == null && now.captured != null) ||
            (before.notice == null && now.notice != null),
        listener: _onEffect,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: context.appColors.textPrimary,
            body: CameraPermissionGate(
              onGallery: context.read<StoryCameraCubit>().pickFromGallery,
              onClose: () => AppNavigator.back(context),
              cameraBuilder: (context, isMicOff, onFixMic) =>
                  StoryCameraView(isMicOff: isMicOff, onFixMic: onFixMic),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _onEffect(BuildContext context, StoryCameraState state) async {
    final cubit = context.read<StoryCameraCubit>();
    final media = state.captured;
    if (media != null) {
      await AppNavigator.push(
        context,
        AppRoutes.createStoryEdit,
        arguments: media,
      );
      cubit.clearCaptured();
      return;
    }
    final notice = state.notice;
    if (notice == null) return;
    final l10n = context.l10n;
    switch (notice) {
      case StoryCameraNotice.captureFailed:
        Notices.error(l10n.storyCaptureFailed);
    }
    cubit.clearNotice();
  }
}
