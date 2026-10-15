import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/tag_people_dimens.dart';
import '../../utils/tag_choice.dart';
import '../post_person_avatar.dart';

/// Who goes at the spot just tapped: the people chosen on Tag people who have no spot on this photo, with a
/// box that filters them. Closes with the id picked, or null when dismissed. Nobody new can be added here.
class TagPersonPickerSheet extends StatefulWidget {
  const TagPersonPickerSheet({super.key, required this.people});

  final List<TagChoice> people;

  static Future<String?> show(
    BuildContext context, {
    required List<TagChoice> people,
  }) => AppBottomSheet.show<String>(
    context,
    title: context.l10n.postTagInPhotoTitle,
    child: TagPersonPickerSheet(people: people),
  );

  @override
  State<TagPersonPickerSheet> createState() => _TagPersonPickerSheetState();
}

class _TagPersonPickerSheetState extends State<TagPersonPickerSheet> {
  String _filter = '';

  List<TagChoice> get _shown {
    final text = _filter.trim().toLowerCase();
    if (text.isEmpty) return widget.people;
    return [
      for (final person in widget.people)
        if (person.username.toLowerCase().contains(text) ||
            person.shownName.toLowerCase().contains(text))
          person,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final people = _shown;
    if (widget.people.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s24),
        child: Center(
          child: AppText(
            context.l10n.postTagInPhotoAllPlaced,
            style: context.text.bodySm,
            color: colors.textSecondary,
          ),
        ),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: TagPeopleDimens.pickerMaxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchPillField(
            onChanged: (text) => setState(() => _filter = text),
            hint: context.l10n.postTagPeopleSearch,
            clearLabel: context.l10n.postTagPeopleClear,
          ),
          SizedBox(height: AppSpacing.s8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];
                return Semantics(
                  button: true,
                  excludeSemantics: true,
                  label: person.shownName,
                  onTap: () => AppNavigator.back(context, person.id),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => AppNavigator.back(context, person.id),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: AppSizes.tapTarget,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
                        child: Row(
                          children: [
                            PostPersonAvatar(
                              id: person.id,
                              name: person.shownName,
                              size: TagPeopleDimens.pickerRowAvatar,
                              url: person.avatarUrl,
                            ),
                            SizedBox(width: TagPeopleDimens.rowGap),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    person.shownName,
                                    style: context.text.name,
                                    color: colors.textPrimary,
                                    maxLines: 1,
                                  ),
                                  AppText(
                                    '@${person.username}',
                                    style: context.text.label,
                                    color: colors.textSecondary,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
