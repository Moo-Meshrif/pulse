import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_page_dimens.dart';

/// "October 25, 2026 · 6:42 PM", under the post's actions.
class PostPageDate extends StatelessWidget {
  const PostPageDate({super.key, required this.createdAt});

  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final local = createdAt.toLocal();
    return Padding(
      padding: PostPageDimens.datePadding,
      child: AppText(
        context.l10n.postDateLine(
          DateFormat.yMMMMd(locale).format(local),
          DateFormat.jm(locale).format(local),
        ),
        style: context.text.caption,
        color: context.appColors.textSecondary,
      ),
    );
  }
}
