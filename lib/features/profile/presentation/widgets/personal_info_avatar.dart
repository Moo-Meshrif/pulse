import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/services/photo_picker_service.dart';
import '../../../../core/widgets/widgets.dart';
import '../dimens/profile_dimens.dart';

/// The big avatar of Personal info with the camera badge; a tap opens the photo sheet.
class PersonalInfoAvatar extends StatelessWidget {
  const PersonalInfoAvatar({
    super.key,
    required this.name,
    required this.seed,
    required this.photo,
    required this.url,
    required this.onTap,
  });

  final String? name;
  final String? seed;

  /// A new picture, shown before the saved [url].
  final PickedPhoto? photo;
  final String? url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = ProfileDimens.editAvatar;
    final initials = AvatarInitials(
      name: name,
      seed: seed,
      size: size,
      fontSize: ProfileDimens.avatarInitials,
    );
    final saved = url;
    return Semantics(
      button: true,
      label: context.l10n.personalInfoChangePhotoA11y,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(ProfileDimens.editAvatarRing),
              decoration: BoxDecoration(
                color: colors.storyRing,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: photo != null
                    ? AppImage.memory(
                        photo!.bytes,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        cacheWidth: size.round() * 2,
                      )
                    : saved == null
                    ? initials
                    : AppImage.network(
                        saved,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        cacheWidth: size.round() * 2,
                        errorBuilder: (_) => initials,
                      ),
              ),
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                width: ProfileDimens.editBadge,
                height: ProfileDimens.editBadge,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.background,
                    width: ProfileDimens.editBadgeRing,
                  ),
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(
                  AppAssets.camera,
                  size: ProfileDimens.editBadgeIcon,
                  color: colors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
