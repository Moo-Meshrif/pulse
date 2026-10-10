import 'package:flutter/widgets.dart';

import '../constants/app_assets.dart';
import 'photo_source.dart';
import '../extensions/l10n.dart';

/// What the photo sheet offers.
enum PhotoChoice {
  take(icon: AppAssets.camera, source: PhotoSource.camera),
  choose(icon: AppAssets.image, source: PhotoSource.gallery),
  remove(icon: AppAssets.trash);

  const PhotoChoice({required this.icon, this.source});

  final String icon;

  /// Where the picture comes from; null for [remove].
  final PhotoSource? source;

  String l10n(BuildContext context) => switch (this) {
    PhotoChoice.take => context.l10n.takePhoto,
    PhotoChoice.choose => context.l10n.chooseGallery,
    PhotoChoice.remove => context.l10n.removePhoto,
  };
}
