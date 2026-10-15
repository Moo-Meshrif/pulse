import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/tag_people_dimens.dart';
import '../../utils/tag_photo.dart';

/// The post's photos as small thumbnails: the one on screen has a green ring, and a badge counts the
/// people placed on each.
class TagPhotoStrip extends StatelessWidget {
  const TagPhotoStrip({
    super.key,
    required this.photos,
    required this.selected,
    required this.countOf,
    required this.onSelect,
  });

  final List<TagPhoto> photos;
  final int selected;
  final int Function(TagPhoto photo) countOf;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: TagPeopleDimens.thumb + AppSpacing.s16,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
      itemCount: photos.length,
      separatorBuilder: (_, _) => SizedBox(width: AppSpacing.s8),
      itemBuilder: (context, index) => Center(
        child: _Thumb(
          photo: photos[index],
          number: index + 1,
          isSelected: index == selected,
          count: countOf(photos[index]),
          onTap: () => onSelect(index),
        ),
      ),
    ),
  );
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.photo,
    required this.number,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  final TagPhoto photo;
  final int number;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  ImageProvider? get _image {
    final path = photo.filePath;
    if (path != null) {
      return ResizeImage(
        FileImage(File(path)),
        width: TagPeopleDimens.thumbCachePixels,
      );
    }
    final url = photo.url;
    return url == null ? null : NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final image = _image;
    final outer = TagPeopleDimens.thumb + 2 * TagPeopleDimens.thumbRingGap;
    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: context.l10n.postTagInPhotoThumb(number, count),
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: outer,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(TagPeopleDimens.thumbRingGap),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    TagPeopleDimens.thumbRadius + TagPeopleDimens.thumbRingGap,
                  ),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: TagPeopleDimens.thumbRing,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    TagPeopleDimens.thumbRadius,
                  ),
                  child: ColoredBox(
                    color: colors.border,
                    child: image == null
                        ? null
                        : Image(
                            image: image,
                            fit: BoxFit.cover,
                            width: TagPeopleDimens.thumb,
                            height: TagPeopleDimens.thumb,
                          ),
                  ),
                ),
              ),
              if (count > 0)
                PositionedDirectional(
                  top: -AppSpacing.s4,
                  end: -AppSpacing.s4,
                  child: Container(
                    width: TagPeopleDimens.thumbBadge,
                    height: TagPeopleDimens.thumbBadge,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: AppText(
                      '$count',
                      style: context.text.badge,
                      color: colors.textOnPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
