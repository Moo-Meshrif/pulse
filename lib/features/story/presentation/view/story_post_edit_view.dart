import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/model/story_overlay_model.dart';
import '../cubit/story_post_edit/story_post_edit_cubit.dart';
import '../cubit/story_post_edit/story_post_edit_state.dart';
import '../dimens/story_dimens.dart';
import '../utils/story_snapshot.dart';
import '../utils/story_sticker.dart';
import '../widgets/story_edit/story_edit_actions.dart';
import '../widgets/story_edit/story_edit_tools.dart';
import '../widgets/story_edit/story_sticker_canvas.dart';
import '../widgets/story_edit/story_text_editor.dart';
import '../widgets/story_overlays_layer.dart';
import '../widgets/story_post/story_post_hint.dart';
import '../widgets/story_post/story_post_sticker.dart';
import '../widgets/story_post/story_post_sticker_box.dart';

/// The body of the post story editor: the gradient, the post sticker, your text, the tools and the bottom
/// actions, laid out like the photo story editor.
class StoryPostEditView extends StatelessWidget {
  const StoryPostEditView({super.key, required this.onClose});

  final VoidCallback onClose;

  Future<void> _addText(BuildContext context) async {
    final cubit = context.read<StoryPostEditCubit>();
    final text = await StoryTextEditor.show(context);
    if (text != null) cubit.addText(text);
  }

  Future<void> _editText(BuildContext context, StorySticker sticker) async {
    final cubit = context.read<StoryPostEditCubit>();
    final text = await StoryTextEditor.show(
      context,
      initial: sticker.overlay.text ?? '',
    );
    if (text != null) cubit.updateText(sticker.id, text);
  }

  /// The background and the text as a picture: what is posted. Save adds the post, which the viewer draws
  /// itself.
  Future<StoryImage?> _render(BuildContext context, {bool withPost = false}) {
    final state = context.read<StoryPostEditCubit>().state;
    return renderStoryBackdrop(
      context,
      colors: state.backgrounds[state.backgroundIndex].colors,
      overlays: [for (final s in state.stickers) s.overlay],
      post: withPost
          ? StoryOverlayPlacement(
              overlay: StoryOverlayModel(
                x: state.x,
                y: state.y,
                scale: state.scale,
                rotation: state.rotation,
              ),
              child: StoryPostSticker(post: state.post, style: state.style),
            )
          : null,
    );
  }

  Future<void> _share(BuildContext context) async {
    final cubit = context.read<StoryPostEditCubit>();
    final image = await _render(context);
    await cubit.share(image);
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<StoryPostEditCubit>();
    final image = await _render(context, withPost: true);
    await cubit.saveImage(image?.bytes);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final cubit = context.read<StoryPostEditCubit>();
    final actionsBottom =
        media.viewPadding.bottom + StoryCameraDimens.actionBottom;
    return Stack(
      fit: StackFit.expand,
      children: [
        BlocSelector<StoryPostEditCubit, StoryPostEditState, List<Color>>(
          selector: (state) => state.backgrounds[state.backgroundIndex].colors,
          builder: (context, colors) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
          ),
        ),
        BlocBuilder<StoryPostEditCubit, StoryPostEditState>(
          buildWhen: (before, now) =>
              before.style != now.style ||
              before.x != now.x ||
              before.y != now.y ||
              before.scale != now.scale ||
              before.rotation != now.rotation,
          builder: (context, state) => StoryPostStickerBox(
            post: state.post,
            style: state.style,
            x: state.x,
            y: state.y,
            scale: state.scale,
            rotation: state.rotation,
            onTap: cubit.cycleStyle,
            onTransform: cubit.transformPost,
          ),
        ),
        BlocSelector<
          StoryPostEditCubit,
          StoryPostEditState,
          List<StorySticker>
        >(
          selector: (state) => state.stickers,
          builder: (context, stickers) => StoryStickerCanvas(
            stickers: stickers,
            zoneBottom:
                actionsBottom +
                StoryCameraDimens.actionHeight +
                StoryCameraDimens.deleteZoneAbove,
            onTransform: cubit.transformText,
            onRemove: cubit.remove,
            onEdit: (s) => _editText(context, s),
          ),
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
            onText: () => _addText(context),
            onPalette: cubit.togglePalette,
            onSave: () => _save(context),
          ),
        ),
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom:
              actionsBottom +
              StoryCameraDimens.actionHeight +
              StoryPostDimens.hintAboveActions,
          child: BlocBuilder<StoryPostEditCubit, StoryPostEditState>(
            buildWhen: (before, now) =>
                before.style != now.style ||
                before.isPaletteOpen != now.isPaletteOpen ||
                before.backgrounds != now.backgrounds ||
                before.backgroundIndex != now.backgroundIndex,
            builder: (context, state) => StoryPostHint(
              style: state.style,
              isPaletteOpen: state.isPaletteOpen,
              backgrounds: state.backgrounds,
              selected: state.backgroundIndex,
              onChoose: cubit.chooseBackground,
            ),
          ),
        ),
        PositionedDirectional(
          start: StoryCameraDimens.actionSide,
          end: StoryCameraDimens.actionSide,
          bottom: actionsBottom,
          child: BlocSelector<StoryPostEditCubit, StoryPostEditState, bool>(
            selector: (state) => state.isSharing,
            builder: (context, isSharing) => StoryEditActions(
              me: cubit.me,
              isSharing: isSharing,
              onShare: () => _share(context),
            ),
          ),
        ),
      ],
    );
  }
}
