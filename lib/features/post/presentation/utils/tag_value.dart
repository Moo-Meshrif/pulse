import '../../../../l10n/app_localizations.dart';
import 'tag_choice.dart';

/// The value on the "Tag people" row: the names, then "and N others" after the first two. Null with nobody
/// tagged.
String? tagValue(AppLocalizations l10n, List<TagChoice> tags) =>
    switch (tags.length) {
      0 => null,
      1 => tags[0].shownName,
      2 => l10n.postTagValueTwo(tags[0].shownName, tags[1].shownName),
      final count => l10n.postTagValueMore(
        tags[0].shownName,
        tags[1].shownName,
        count - 2,
      ),
    };
