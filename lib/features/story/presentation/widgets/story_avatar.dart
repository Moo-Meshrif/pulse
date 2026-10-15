import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({
    super.key,
    required this.size,
    required this.seed,
    required this.name,
    this.imageUrl,
    this.ringWidth = 0,
  });

  final double size;
  final double ringWidth;

  final String seed;
  final String? name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final inner = size - 2 * ringWidth;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: ringWidth == 0
            ? null
            : Border.all(color: context.appColors.onDark, width: ringWidth),
      ),
      child: ClipOval(
        child: imageUrl == null
            ? AvatarInitials(name: name, seed: seed, size: inner)
            : AppImage.network(
                imageUrl!,
                width: inner,
                height: inner,
                cacheWidth: (inner * 2).round(),
                errorBuilder: (_) =>
                    AvatarInitials(name: name, seed: seed, size: inner),
              ),
      ),
    );
  }
}
