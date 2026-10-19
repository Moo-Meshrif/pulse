import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/story_camera/story_camera_cubit.dart';
import '../cubit/story_camera/story_camera_state.dart';
import '../dimens/story_constants.dart';
import '../dimens/story_dimens.dart';
import '../utils/enums/story_camera_status.dart';
import '../widgets/story_camera/story_camera_controls.dart';
import '../widgets/story_camera/story_camera_top_bar.dart';

/// The camera itself (S2), shown once the permission gate lets it through. Opens the camera when it
/// appears, lets go of it when the app goes to the background and opens it again on return.
class StoryCameraView extends StatefulWidget {
  const StoryCameraView({
    super.key,
    required this.isMicOff,
    required this.onFixMic,
  });

  /// Only the microphone is refused: videos are silent and the Fix pill shows (panel 3).
  final bool isMicOff;
  final VoidCallback onFixMic;

  @override
  State<StoryCameraView> createState() => _StoryCameraViewState();
}

class _StoryCameraViewState extends State<StoryCameraView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void didUpdateWidget(StoryCameraView old) {
    super.didUpdateWidget(old);
    // Back from Settings: record with sound now.
    if (old.isMicOff != widget.isMicOff) {
      _open();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    switch (lifecycle) {
      case AppLifecycleState.paused:
        _cubit.stop();
      case AppLifecycleState.resumed:
        if (_cubit.state.status == StoryCameraStatus.idle) _open();
      default:
        break;
    }
  }

  StoryCameraCubit get _cubit => context.read<StoryCameraCubit>();

  void _open() {
    if (mounted) _cubit.start(withAudio: !widget.isMicOff);
  }

  void _close() {
    _cubit.cancelRecording();
    AppNavigator.back(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return BlocBuilder<StoryCameraCubit, StoryCameraState>(
      builder: (context, state) {
        if (state.status == StoryCameraStatus.unavailable) {
          return CameraUnavailableView(
            onTryAgain: _open,
            onGallery: _cubit.pickFromGallery,
            onClose: _close,
          );
        }
        final ready = state.status == StoryCameraStatus.ready;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (ready)
              _cubit.preview()
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [StoryColors.cameraStart, StoryColors.cameraEnd],
                  ),
                ),
              ),
            // Keys: the hint and the pill come and go, and the controls must stay the same element
            // (a hold on the shutter is in progress when the hint disappears).
            PositionedDirectional(
              key: const ValueKey('top-bar'),
              top: media.viewPadding.top + StoryCameraDimens.topBarBelowInset,
              start: CameraPermissionDimens.topBarSide,
              end: CameraPermissionDimens.topBarSide,
              child: StoryCameraTopBar(
                isRecording: state.isRecording,
                elapsed: state.elapsed,
                hasFlash: state.hasFlash,
                isFlashOn: state.isFlashOn,
                onClose: _close,
                onFlash: _cubit.toggleFlash,
              ),
            ),
            if (widget.isMicOff && !state.isRecording)
              PositionedDirectional(
                key: const ValueKey('mic-pill'),
                top:
                    media.viewPadding.top +
                    CameraPermissionDimens.micPillBelowInset,
                start: 0,
                end: 0,
                child: Center(child: MicOffPill(onFix: widget.onFixMic)),
              ),
            if (state.hintVisible && !state.isRecording)
              PositionedDirectional(
                key: const ValueKey('hint'),
                bottom: media.viewPadding.bottom + StoryCameraDimens.hintBottom,
                start: 0,
                end: 0,
                child: Center(
                  child: AppText(
                    context.l10n.storyHint,
                    style: context.text.bodyXs,
                    color: context.appColors.onDark.withValues(
                      alpha: StoryOpacity.hint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            PositionedDirectional(
              key: const ValueKey('controls'),
              bottom:
                  media.viewPadding.bottom + StoryCameraDimens.bottomRowBottom,
              start: 0,
              end: 0,
              child: StoryCameraControls(
                isRecording: state.isRecording,
                progress:
                    state.elapsed.inMilliseconds /
                    StoryTiming.maxVideo.inMilliseconds,
                onGallery: _cubit.pickFromGallery,
                onFlip: _cubit.flip,
                onTap: _cubit.takePhoto,
                onHoldStart: _cubit.startRecording,
                onHoldEnd: _cubit.stopRecording,
              ),
            ),
          ],
        );
      },
    );
  }
}
