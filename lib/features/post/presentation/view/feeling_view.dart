import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../dimens/feeling_dimens.dart';
import '../utils/post_feeling.dart';
import '../widgets/feeling/feeling_header.dart';
import '../widgets/feeling/feeling_segmented.dart';
import '../widgets/feeling/feeling_tile.dart';

/// The Feeling layout: header, the Feelings | Activities switch, search and a two-column grid of feelings.
/// The search text is local to the page.
class FeelingView extends StatefulWidget {
  const FeelingView({
    super.key,
    required this.selectedKey,
    required this.canRemove,
    required this.onPick,
    required this.onRemove,
    required this.onBack,
    required this.onActivities,
  });

  /// The feeling the post has, or null.
  final String? selectedKey;

  /// The post has a mood: "Remove" shows.
  final bool canRemove;
  final ValueChanged<String> onPick;
  final VoidCallback onRemove;
  final VoidCallback onBack;
  final VoidCallback onActivities;

  @override
  State<FeelingView> createState() => _FeelingViewState();
}

class _FeelingViewState extends State<FeelingView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keys = matchingFeelings(_query);
    return AppPage(
      showTopBar: false,
      backgroundColor: context.appColors.background,
      child: Column(
        children: [
          FeelingHeader(
            onBack: widget.onBack,
            onRemove: widget.canRemove ? widget.onRemove : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
            child: Column(
              children: [
                FeelingSegmented(onActivities: widget.onActivities),
                SizedBox(height: AppSpacing.s12),
                SearchPillField(
                  onChanged: (text) => setState(() => _query = text),
                  hint: l10n.postFeelingSearch,
                  clearLabel: l10n.postFeelingClear,
                ),
                SizedBox(height: AppSpacing.s12),
              ],
            ),
          ),
          Expanded(
            child: keys.isEmpty
                ? const _NoMatches()
                : GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.cardMargin,
                      0,
                      AppSpacing.cardMargin,
                      AppSpacing.s16,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: FeelingDimens.tileGap,
                      crossAxisSpacing: FeelingDimens.tileGap,
                      mainAxisExtent: FeelingDimens.tileHeight,
                    ),
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      final key = keys[index];
                      return FeelingTile(
                        emoji: feelingEmoji(key) ?? '',
                        word: feelingWord(l10n, key) ?? key,
                        isSelected: key == widget.selectedKey,
                        onTap: () => widget.onPick(key),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: AppSvgIcon(
                AppAssets.search,
                size: FeelingDimens.emptyIcon,
                color: colors.primary,
              ),
            ),
            SizedBox(height: AppSpacing.s16),
            AppText(
              context.l10n.postFeelingNoMatches,
              style: context.text.stat,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
