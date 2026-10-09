import 'package:flutter/widgets.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../profile/data/enums/suggestion_tab.dart';

/// The tabs of the Follow step. "From contacts" has no backend list yet ([source] is null).
enum FollowTab {
  suggested(source: SuggestionTab.suggested),
  contacts(),
  popular(source: SuggestionTab.popular);

  const FollowTab({this.source});

  final SuggestionTab? source;

  String l10n(BuildContext context) => switch (this) {
    FollowTab.suggested => context.l10n.tabSuggested,
    FollowTab.contacts => context.l10n.tabContacts,
    FollowTab.popular => context.l10n.tabPopular,
  };
}
