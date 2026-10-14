import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../story/domain/entity/story_upload_status.dart';
import '../../cubit/story_rail_cubit.dart';
import '../../cubit/story_rail_state.dart';
import 'rail_label.dart';
import 'rail_rings.dart';
import 'ringed_photo.dart';
import 'story_item.dart';

/// The first tile of the rail. Idle it is the dashed circle with a plus that opens the camera; while a
/// story is posting it shows a progress ring ("Posting…"), and when posting failed a warning ring that
/// sends it again ("Retry") (docs/specs/story/screens/s4-posting-rail.md).
class YourStoryItem extends StatelessWidget {
  const YourStoryItem({super.key});

  static const _progressDuration = Duration(milliseconds: 240);

  void _createStory(BuildContext context) => AppNavigator.push<void>(
    context,
    AppRoutes.createStory,
    rootNavigator: true,
  );

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StoryRailCubit, StoryRailState>(
        buildWhen: (before, state) =>
            before.upload != state.upload || before.me != state.me,
        builder: (context, state) {
          final l10n = context.l10n;
          final colors = context.appColors;
          return switch (state.upload) {
            StoryUploading(:final progress) => _Tile(
              label: l10n.storyPosting,
              labelColor: colors.primary,
              onTap: null,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: _progressDuration,
                builder: (context, value, _) => RingedPhoto(
                  me: state.me,
                  progress: value,
                  color: colors.primary,
                  track: colors.border,
                ),
              ),
            ),
            StoryUploadFailed() => _Tile(
              label: l10n.retry,
              labelColor: colors.warningInk,
              onTap: context.read<StoryRailCubit>().retryUpload,
              child: RingedPhoto(
                me: state.me,
                progress: 1,
                color: colors.warningInk,
              ),
            ),
            _ when state.me != null => StoryItem(
              person: state.me!,
              label: l10n.storyYourStory,
              onAdd: () => _createStory(context),
            ),
            _ => _Tile(
              label: l10n.storyYourStory,
              onTap: () => _createStory(context),
              child: const _DashedPlus(),
            ),
          };
        },
      );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.child,
    required this.onTap,
    this.labelColor,
  });

  final String label;
  final Color? labelColor;
  final Widget child;

  /// Null while a story is posting: there is nothing to do.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    excludeSemantics: true,
    label: label,
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          RailLabel(label, color: labelColor),
        ],
      ),
    ),
  );
}

/// The empty "Your story" circle: a dashed ring around a soft disc with a plus.
class _DashedPlus extends StatelessWidget {
  const _DashedPlus();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return CustomPaint(
      painter: DashedRingPainter(
        color: colors.primary,
        width: StoryDimens.emptyRingDash,
      ),
      child: Container(
        width: StoryDimens.railAvatar,
        height: StoryDimens.railAvatar,
        decoration: BoxDecoration(
          color: colors.primarySoft,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: AppSvgIcon(
          AppAssets.plus,
          size: StoryDimens.plusIcon,
          color: colors.primary,
        ),
      ),
    );
  }
}
