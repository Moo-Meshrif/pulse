import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/avatar_initials.dart';
import '../dimens/post_card_dimens.dart';

/// The author picture inside the story ring; initials when there is no picture or it fails.
class PostRingedAvatar extends StatelessWidget {
  static const double _cacheScale = 2;

  const PostRingedAvatar({
    super.key,
    required this.authorId,
    required this.name,
    required this.avatarUrl,
    this.size,
  });

  final String authorId;
  final String name;
  final String? avatarUrl;

  /// The picture's side; the card's author size when null.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = this.size ?? PostCardDimens.avatar;
    final initials = AvatarInitials(name: name, seed: authorId, size: size);
    final url = avatarUrl;
    return Container(
      padding: EdgeInsets.all(PostCardDimens.ringGap),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.surface,
        border: Border.all(
          color: colors.storyRing,
          width: PostCardDimens.ringWidth,
        ),
      ),
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: url == null || url.isEmpty
              ? initials
              : AppImage.network(
                  url,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  cacheWidth: (size * _cacheScale).round(),
                  errorBuilder: (_) => initials,
                  placeholder: initials,
                ),
        ),
      ),
    );
  }
}
