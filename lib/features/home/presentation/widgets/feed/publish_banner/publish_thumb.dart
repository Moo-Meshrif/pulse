import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../shared/content/domain/entity/content_publish_line.dart';

/// The picture of a post being sent: its first file on this device, a link for an edited post, or the
/// app logo when it has none.
class PublishThumb extends StatelessWidget {
  const PublishThumb({super.key, required this.item, required this.size});

  final ContentLineItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = item.previewPath;
    final url = item.previewUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.settingsTile),
      child: SizedBox.square(
        dimension: size,
        child: path != null
            ? Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _LogoPreview(size: size),
              )
            : url != null
            ? AppImage.network(
                url,
                cacheKey: item.previewCacheKey,
                fit: BoxFit.cover,
                errorBuilder: (_) => _LogoPreview(size: size),
              )
            : _LogoPreview(size: size),
      ),
    );
  }
}

/// Shown when the post has no picture to draw: the app logo filling the square.
class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.appColors.primary,
    child: SvgPicture.asset(AppAssets.logo, width: size, height: size),
  );
}
