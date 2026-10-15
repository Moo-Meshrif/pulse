import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/tag_in_photo_cubit.dart';
import '../cubit/tag_in_photo_state.dart';
import '../dimens/tag_people_dimens.dart';
import '../widgets/tag_in_photo/tag_no_spot_card.dart';
import '../widgets/tag_in_photo/tag_photo_canvas.dart';
import '../widgets/tag_in_photo/tag_photo_strip.dart';
import '../widgets/tag_people/tag_page_header.dart';

/// The Tag in photo layout (docs/specs/post/screens/s7-tag-in-photo.md): header, hint, the photo with its
/// labels, the thumbnails and the card for people without a spot.
class TagInPhotoView extends StatelessWidget {
  const TagInPhotoView({super.key, required this.onBack, required this.onDone});

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => AppPage(
    showTopBar: false,
    backgroundColor: context.appColors.background,
    child: Column(
      children: [
        TagPageHeader(
          title: context.l10n.postTagInPhotoTitle,
          onBack: onBack,
          onDone: onDone,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, area) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: TagPeopleDimens.hintSide,
                    ),
                    child: AppText(
                      context.l10n.postTagInPhotoHint,
                      style: context.text.bodySm,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s12),
                  SizedBox(
                    height: max(
                      area.maxHeight * TagPeopleDimens.photoShare,
                      TagPeopleDimens.photoMinHeight,
                    ),
                    child: const _Photo(),
                  ),
                  SizedBox(height: AppSpacing.s8),
                  const _Strip(),
                  const _NoSpot(),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Photo extends StatelessWidget {
  const _Photo();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TagInPhotoCubit>();
    return BlocBuilder<TagInPhotoCubit, TagInPhotoState>(
      builder: (context, state) => Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
        child: TagPhotoCanvas(
          key: ValueKey(state.photo.position),
          photo: state.photo,
          number: state.selected + 1,
          total: state.photos.length,
          labels: state.labels,
          pendingX: state.pendingX,
          pendingY: state.pendingY,
          onTap: cubit.tapPhoto,
          onMove: cubit.move,
          onRemove: cubit.removeSpot,
        ),
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TagInPhotoCubit>();
    return BlocBuilder<TagInPhotoCubit, TagInPhotoState>(
      builder: (context, state) => state.photos.length < 2
          ? const SizedBox.shrink()
          : TagPhotoStrip(
              photos: state.photos,
              selected: state.selected,
              countOf: state.countOn,
              onSelect: cubit.selectPhoto,
            ),
    );
  }
}

class _NoSpot extends StatelessWidget {
  const _NoSpot();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TagInPhotoCubit, TagInPhotoState>(
        buildWhen: (before, now) => before.chosen != now.chosen,
        builder: (context, state) => Padding(
          padding: state.withoutSpot.isEmpty
              ? EdgeInsets.zero
              : EdgeInsets.fromLTRB(
                  AppSpacing.cardMargin,
                  AppSpacing.s8,
                  AppSpacing.cardMargin,
                  AppSpacing.s12,
                ),
          child: TagNoSpotCard(people: state.withoutSpot),
        ),
      );
}
