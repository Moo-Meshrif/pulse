import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

/// A person's round picture, or their initials when they have none or it fails to load.
class PostPersonAvatar extends StatelessWidget {
  const PostPersonAvatar({
    super.key,
    required this.id,
    required this.name,
    required this.size,
    this.url,
  });

  final String id;
  final String name;
  final double size;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final initials = AvatarInitials(name: name, seed: id, size: size);
    final link = url;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: link == null || link.isEmpty
            ? initials
            : AppImage.network(
                link,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_) => initials,
                placeholder: initials,
              ),
      ),
    );
  }
}
