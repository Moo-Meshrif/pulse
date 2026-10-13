import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_assets.dart';
import '../../di/injection.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/l10n.dart';
import '../../state/camera_permission_cubit.dart';
import '../../state/camera_permission_state.dart';
import '../app_loading_view.dart';
import 'permission_panel.dart';
import 'permission_status_card.dart';

/// Shows the camera only when it may be used (docs/specs/story/screens/s5-camera-permissions.md). Not asked
/// yet or still askable -> panel 1; off for good -> panel 2; allowed -> [cameraBuilder], told whether the
/// microphone is off (panel 3: the camera shows [MicOffPill], unless it is a photo-only flow).
/// Coming back from Settings re-checks and goes on by itself. [onGallery] is always reachable once the
/// camera is blocked: a missing permission never blocks picking from the gallery.
///
/// TODO(story-plan T7): also used by the short and profile-photo camera flows; only story uses it now.
class CameraPermissionGate extends StatelessWidget {
  const CameraPermissionGate({
    super.key,
    required this.cameraBuilder,
    required this.onGallery,
    required this.onClose,
  });

  /// Builds the camera. [isMicOff] is true when only the microphone is refused; [onFixMic] asks for the microphone, or opens Settings when it was refused for good.
  final Widget Function(
    BuildContext context,
    bool isMicOff,
    VoidCallback onFixMic,
  )
  cameraBuilder;
  final VoidCallback onGallery;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<CameraPermissionCubit>()..check(),
    child: _Gate(
      cameraBuilder: cameraBuilder,
      onGallery: onGallery,
      onClose: onClose,
    ),
  );
}

class _Gate extends StatefulWidget {
  const _Gate({
    required this.cameraBuilder,
    required this.onGallery,
    required this.onClose,
  });

  final Widget Function(BuildContext, bool, VoidCallback) cameraBuilder;
  final VoidCallback onGallery;
  final VoidCallback onClose;

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) {
      context.read<CameraPermissionCubit>().check();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CameraPermissionCubit>();
    final l10n = context.l10n;
    final colors = context.appColors;
    return BlocBuilder<CameraPermissionCubit, CameraPermissionState>(
      builder: (context, state) => switch (state.step) {
        CameraPermissionStep.checking => ColoredBox(
          color: colors.textPrimary,
          child: const AppLoadingView(),
        ),
        CameraPermissionStep.ask => PermissionPanel(
          icons: [
            (asset: AppAssets.camera, color: null),
            (asset: AppAssets.mic, color: null),
          ],
          title: l10n.permAllowTitle,
          body: l10n.permAllowBody,
          card: PermissionStatusCard(
            camera: state.camera,
            microphone: state.microphone,
          ),
          primaryLabel: l10n.permAllowAccess,
          onPrimary: cubit.allow,
          linkLabel: l10n.permNotNow,
          onLink: widget.onClose,
          onClose: widget.onClose,
        ),
        CameraPermissionStep.blocked => PermissionPanel(
          icons: [(asset: AppAssets.cameraOff, color: colors.storyWarning)],
          title: l10n.permCameraOffTitle,
          body: state.isRestricted
              ? l10n.permCameraRestrictedBody
              : l10n.permCameraOffBody,
          card: PermissionStatusCard(
            camera: state.camera,
            microphone: state.microphone,
          ),
          primaryLabel: state.isRestricted ? null : l10n.permOpenSettings,
          onPrimary: cubit.openSettings,
          secondaryLabel: l10n.permChooseGallery,
          onSecondary: widget.onGallery,
          onClose: widget.onClose,
        ),
        CameraPermissionStep.ready => widget.cameraBuilder(
          context,
          state.isMicOff,
          cubit.fixMicrophone,
        ),
      },
    );
  }
}
