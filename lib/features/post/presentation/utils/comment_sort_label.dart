import '../../../../l10n/app_localizations.dart';
import '../../data/enums/comment_sort.dart';

/// The words for a comment sort.
String commentSortLabel(AppLocalizations l10n, CommentSort sort) =>
    switch (sort) {
      CommentSort.relevant => l10n.commentsSortRelevant,
      CommentSort.newest => l10n.commentsSortNewest,
    };
