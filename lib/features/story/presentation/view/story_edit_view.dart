import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/utils/location_choice.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/enums/story_media_type.dart';
import '../../data/enums/story_overlay_type.dart';
import '../cubit/story_edit_cubit.dart';
import '../cubit/story_edit_state.dart';
import '../dimens/story_dimens.dart';
import '../utils/story_snapshot.dart';
import '../utils/story_sticker.dart';
import '../widgets/story_edit/story_edit_actions.dart';
import '../widgets/story_edit/story_edit_media.dart';
import '../widgets/story_edit/story_edit_tools.dart';
import '../widgets/story_edit/story_sticker_canvas.dart';
import '../widgets/story_edit/story_text_editor.dart';
import '../widgets/story_shades.dart';

/// The edit screen's body (S3): the media with its stickers, the tools and the bottom actions.
class StoryEditView extends StatelessWidget {
  const StoryEditView({super.key, required this.onClose});

  final VoidCallback onClose;

  Future<void> _addText(BuildContext context) async {
    final cubit = context.read<StoryEditCubit>();
    final text = await StoryTextEditor.show(context);
    if (text != null) cubit.addText(text);
  }

  Future<void> _chooseLocation(
    BuildContext context, {
    StorySticker? current,
  }) async {
    final cubit = context.read<StoryEditCubit>();
    final existing =
        current ??
        cubit.state.stickers
            .where((s) => s.overlay.type == StoryOverlayType.location)
            .firstOrNull;
    // `Object?`: the router builds its routes without a result type, so a typed push cannot cast to them.
    final choice = await AppNavigator.push<Object?>(
      context,
      AppRoutes.pickPlace,
      arguments: existing?.overlay.text,
    );
    if (choice is! LocationChoice) return;
    final name = choice.name;
    if (name != null) {
      cubit.setLocation(name);
    } else if (existing != null) {
      cubit.remove(existing.id);
    }
  }

  Future<void> _editText(BuildContext context, StorySticker sticker) async {
    if (sticker.overlay.type == StoryOverlayType.location) {
      return _chooseLocation(context, current: sticker);
    }
    final cubit = context.read<StoryEditCubit>();
    final text = await StoryTextEditor.show(
      context,
      initial: sticker.overlay.text ?? '',
    );
    if (text != null) cubit.updateText(sticker.id, text);
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<StoryEditCubit>();
    final media = cubit.state.media;
    if (media.type == StoryMediaType.video) {
      await cubit.saveVideo();
      return;
    }
    final bytes = await renderStoryImage(
      context,
      image: FileImage(File(media.path)),
      overlays: [for (final s in cubit.state.stickers) s.overlay],
      width: media.width,
    );
    await cubit.saveImage(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final cubit = context.read<StoryEditCubit>();
    final actionsBottom =
        media.viewPadding.bottom + StoryCameraDimens.actionBottom;
    return BlocBuilder<StoryEditCubit, StoryEditState>(
      builder: (context, state) => Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          StoryEditMedia(media: state.media, isMuted: state.isMuted),
          const StoryShades(),
          StoryStickerCanvas(
            stickers: state.stickers,
            zoneBottom:
                actionsBottom +
                StoryCameraDimens.actionHeight +
                StoryCameraDimens.deleteZoneAbove,
            onTransform: cubit.transform,
            onRemove: cubit.remove,
            onEdit: (s) => _editText(context, s),
          ),
          PositionedDirectional(
            top: media.viewPadding.top + StoryDimens.barBelowInset,
            start: StoryDimens.headerStart / 2,
            child: Semantics(
              button: true,
              label: context.l10n.close,
              excludeSemantics: true,
              child: InkResponse(
                onTap: onClose,
                child: SizedBox.square(
                  dimension: CameraPermissionDimens.roundControl,
                  child: Center(
                    child: AppSvgIcon(
                      AppAssets.close,
                      size: CameraPermissionDimens.closeIcon,
                      color: context.appColors.onDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: media.viewPadding.top + StoryCameraDimens.toolBelowInset,
            end: StoryCameraDimens.toolRight,
            child: StoryEditTools(
              isVideo: state.media.type == StoryMediaType.video,
              isMuted: state.isMuted,
              onText: () => _addText(context),
              onLocation: () => _chooseLocation(context),
              onMute: cubit.toggleMute,
              onSave: () => _save(context),
            ),
          ),
          PositionedDirectional(
            start: StoryCameraDimens.actionSide,
            end: StoryCameraDimens.actionSide,
            bottom: actionsBottom,
            child: StoryEditActions(
              me: cubit.me,
              isSharing: state.isSharing,
              onShare: cubit.share,
            ),
          ),
        ],
      ),
    );
  }
}
