import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/audience_tab.dart';
import '../../cubit/audience_list_cubit.dart';
import '../../cubit/audience_list_state.dart';

/// The Suggested and Selected tabs.
class AudienceListTabs extends StatelessWidget {
  const AudienceListTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<AudienceListCubit>();
    return BlocBuilder<AudienceListCubit, AudienceListState>(
      buildWhen: (before, now) =>
          before.tab != now.tab || before.selectedCount != now.selectedCount,
      builder: (context, state) => Wrap(
        spacing: AppSpacing.s8,
        runSpacing: AppSpacing.s8,
        children: [
          _Tab(
            label: l10n.storyAudienceTabSuggested,
            active: state.tab == AudienceTab.suggested,
            onTap: () => cubit.setTab(AudienceTab.suggested),
          ),
          _Tab(
            label: l10n.storyAudienceTabSelected(state.selectedCount),
            active: state.tab == AudienceTab.selected,
            onTap: () => cubit.setTab(AudienceTab.selected),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? colors.onDark : colors.darkSurfaceRow,
            borderRadius: BorderRadius.circular(
              CameraPermissionDimens.fixChipHeight,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          child: AppText(
            label,
            style: context.text.label,
            maxLines: 1,
            color: active ? colors.textPrimary : colors.onDark,
          ),
        ),
      ),
    );
  }
}
