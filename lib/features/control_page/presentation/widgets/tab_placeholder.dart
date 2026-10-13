import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/enums/main_tab.dart';

/// Stand-in for a tab's root page until its feature exists. Keeps clear of the nav bar like a real page.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({super.key, required this.tab});

  final MainTab tab;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppSafeArea(
      bottomSpace: NavClearance.of(context),
      child: Center(
        child: AppText(
          tab.l10n(context),
          style: context.text.title,
          color: context.appColors.textSecondary,
        ),
      ),
    ),
  );
}
