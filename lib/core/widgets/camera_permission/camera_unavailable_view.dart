import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../extensions/l10n.dart';
import 'permission_panel.dart';

/// Panel 4: the camera could not start (another app uses it, none found). The camera screen shows it
/// when opening the camera throws; [onTryAgain] opens the camera again.
class CameraUnavailableView extends StatelessWidget {
  const CameraUnavailableView({
    super.key,
    required this.onTryAgain,
    required this.onGallery,
    required this.onClose,
  });

  final VoidCallback onTryAgain;
  final VoidCallback onGallery;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PermissionPanel(
      icons: const [(asset: AppAssets.cameraOff, color: null)],
      title: l10n.permUnavailableTitle,
      body: l10n.permUnavailableBody,
      primaryLabel: l10n.permTryAgain,
      onPrimary: onTryAgain,
      secondaryLabel: l10n.permChooseGallery,
      onSecondary: onGallery,
      onClose: onClose,
    );
  }
}
