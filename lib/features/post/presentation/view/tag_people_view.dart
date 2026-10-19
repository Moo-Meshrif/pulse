import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entity/tag_person_entity.dart';
import '../cubit/tag_people/tag_people_cubit.dart';
import '../cubit/tag_people/tag_people_state.dart';
import '../dimens/tag_people_dimens.dart';
import '../utils/enums/tag_people_status.dart';
import '../utils/new_post_limits.dart';
import '../utils/tag_choice.dart';
import '../widgets/tag_people/tag_page_header.dart';
import '../widgets/tag_people/tag_people_chips.dart';
import '../widgets/tag_people/tag_person_pick_row.dart';

/// The Tag people layout (docs/specs/post/screens/s6-tag-people.md): header, search, the chosen people, the
/// list, and "Tag in photo" at the bottom when the post has photos.
class TagPeopleView extends StatelessWidget {
  const TagPeopleView({
    super.key,
    required this.hasPhotos,
    required this.onBack,
    required this.onDone,
    required this.onTagInPhoto,
  });

  final bool hasPhotos;
  final VoidCallback onBack;
  final VoidCallback onDone;
  final VoidCallback onTagInPhoto;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TagPeopleCubit>();
    return AppPage(
      showTopBar: false,
      backgroundColor: context.appColors.background,
      child: Column(
        children: [
          BlocSelector<TagPeopleCubit, TagPeopleState, bool>(
            selector: (state) => state.chosen.isNotEmpty || cubit.hasChanges,
            builder: (context, enabled) => TagPageHeader(
              title: context.l10n.postTagPeopleTitle,
              onBack: onBack,
              onDone: onDone,
              isDoneEnabled: enabled,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
            child: SearchPillField(
              onChanged: cubit.queryChanged,
              hint: context.l10n.postTagPeopleSearch,
              clearLabel: context.l10n.postTagPeopleClear,
            ),
          ),
          const _Chosen(),
          const _SectionRow(),
          const Expanded(child: _List()),
          if (hasPhotos) _TagInPhotoButton(onTap: onTagInPhoto),
        ],
      ),
    );
  }
}

class _Chosen extends StatelessWidget {
  const _Chosen();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TagPeopleCubit>();
    return BlocSelector<TagPeopleCubit, TagPeopleState, List<TagChoice>>(
      selector: (state) => state.chosen,
      builder: (context, chosen) => chosen.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(top: AppSpacing.s8),
              child: TagPeopleChips(chosen: chosen, onRemove: cubit.remove),
            ),
    );
  }
}

/// "SUGGESTED" and the "3 / 20" counter; a search shows only the counter.
class _SectionRow extends StatelessWidget {
  const _SectionRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<TagPeopleCubit, TagPeopleState>(
      buildWhen: (before, now) =>
          before.isSearching != now.isSearching ||
          before.chosen.length != now.chosen.length,
      builder: (context, state) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.cardMargin + AppSpacing.s4,
          AppSpacing.s16,
          AppSpacing.cardMargin + AppSpacing.s4,
          AppSpacing.s8,
        ),
        child: Row(
          children: [
            Expanded(
              child: state.isSearching
                  ? const SizedBox.shrink()
                  : AppText(
                      context.l10n.postTagPeopleSuggested.toUpperCase(),
                      style: context.text.section,
                      color: colors.textSecondary,
                    ),
            ),
            AppText(
              context.l10n.postTagPeopleCounter(
                state.chosen.length,
                TagLimits.maxPeople,
              ),
              style: context.text.caption,
              color: state.isFull ? colors.danger : colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TagPeopleCubit, TagPeopleState>(
        buildWhen: (before, now) =>
            before.status != now.status ||
            before.people != now.people ||
            before.chosen != now.chosen,
        builder: (context, state) {
          if (state.status == TagPeopleStatus.loading) {
            return Center(
              child: PulseLineLoader(
                color: context.appColors.primary,
                width: TagPeopleDimens.loaderWidth,
              ),
            );
          }
          if (state.status == TagPeopleStatus.failed) {
            return const SizedBox.shrink();
          }
          if (state.people.isEmpty) return const _Empty();
          return _Rows(state: state);
        },
      );
}

class _Rows extends StatelessWidget {
  const _Rows({required this.state});

  final TagPeopleState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TagPeopleCubit>();
    final colors = context.appColors;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(TagPeopleDimens.cardRadius),
          ),
          child: Column(
            children: [
              for (final TagPersonEntity person in state.people)
                TagPersonPickRow(
                  person: person,
                  isChosen: state.isChosen(person.id),
                  isFull: state.isFull,
                  onTap: () => cubit.toggle(person),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

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
                size: TagPeopleDimens.emptyIcon,
                color: colors.primary,
              ),
            ),
            SizedBox(height: AppSpacing.s16),
            AppText(
              context.l10n.postTagPeopleEmpty,
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

/// The outlined button pinned at the bottom; off until someone is chosen.
class _TagInPhotoButton extends StatelessWidget {
  const _TagInPhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocSelector<TagPeopleCubit, TagPeopleState, bool>(
      selector: (state) => state.chosen.isNotEmpty,
      builder: (context, enabled) {
        if (enabled) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              TagPeopleDimens.buttonSide,
              AppSpacing.s8,
              TagPeopleDimens.buttonSide,
              AppSpacing.s12,
            ),
            child: Semantics(
              button: true,
              enabled: true,
              excludeSemantics: true,
              label: context.l10n.postTagPeopleInPhoto,
              onTap: onTap,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Container(
                  height: TagPeopleDimens.buttonHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppRadius.pill(TagPeopleDimens.buttonHeight),
                    ),
                    border: Border.all(
                      color: colors.primary,
                      width: TagPeopleDimens.buttonBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgIcon(
                        AppAssets.image,
                        size: TagPeopleDimens.buttonIcon,
                        color: colors.primary,
                      ),
                      SizedBox(width: AppSpacing.s8),
                      Flexible(
                        child: AppText(
                          context.l10n.postTagPeopleInPhoto,
                          style: context.text.name,
                          color: colors.primary,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
