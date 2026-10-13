import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../data/enums/story_audience.dart';
import '../../../domain/entity/story_rail_item_entity.dart';
import '../../utils/enums/story_option.dart';
import 'story_option_row.dart';

/// The "···" sheet of the viewer (docs/specs/story/screens/s6-viewer-menus.md, panels 7 and 8): pops with
/// the [StoryOption] picked. Someone's story offers mute, profile and report; yours offers save, the
/// audience (read-only), viewers and delete.
class StoryOptionsSheet extends StatelessWidget {
  const StoryOptionsSheet({
    super.key,
    required this.person,
    required this.viewCount,
    required this.audience,
  });

  final StoryRailItemEntity person;
  final int viewCount;

  /// Who can see your story; Followers when the server did not say.
  final StoryAudience audience;

  void _pick(BuildContext context, StoryOption option) =>
      AppNavigator.back(context, option);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: StorySheetDimens.gap,
      children: person.isMe
          ? [
              StoryOptionGroup(
                rows: [
                  StoryOptionRow(
                    icon: AppAssets.download,
                    title: l10n.storySaveToDevice,
                    onTap: () => _pick(context, StoryOption.save),
                  ),
                  StoryOptionRow(
                    icon: AppAssets.audience,
                    title: l10n.storyWhoCanSee,
                    subtitle: audience == StoryAudience.closeFriends
                        ? l10n.storyAudienceCloseFriends
                        : l10n.storyAudienceFollowers,
                    showsChevron: true,
                    onTap: () => _pick(context, StoryOption.audience),
                  ),
                  StoryOptionRow(
                    icon: AppAssets.eye,
                    title: l10n.storyViewersItem,
                    subtitle: '$viewCount',
                    onTap: () => _pick(context, StoryOption.viewers),
                  ),
                ],
              ),
              StoryOptionGroup(
                rows: [
                  StoryOptionRow(
                    icon: AppAssets.trash,
                    title: l10n.storyDelete,
                    isDanger: true,
                    onTap: () => _pick(context, StoryOption.delete),
                  ),
                ],
              ),
            ]
          : [
              StoryOptionGroup(
                rows: [
                  StoryOptionRow(
                    icon: AppAssets.volumeOff,
                    title: l10n.storyMute(person.username),
                    subtitle: l10n.storyMuteHint,
                    onTap: () => _pick(context, StoryOption.mute),
                  ),
                  StoryOptionRow(
                    icon: AppAssets.user,
                    title: l10n.storyGoToProfile,
                    onTap: () => _pick(context, StoryOption.goToProfile),
                  ),
                  // TODO(story-plan T2): Copy link is hidden until a story link format exists (P5).
                ],
              ),
              StoryOptionGroup(
                rows: [
                  StoryOptionRow(
                    icon: AppAssets.flag,
                    title: l10n.storyReportTitle,
                    isDanger: true,
                    onTap: () => _pick(context, StoryOption.report),
                  ),
                ],
              ),
            ],
    );
  }
}
