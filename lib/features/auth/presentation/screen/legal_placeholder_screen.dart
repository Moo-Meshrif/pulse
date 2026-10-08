import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/enums/legal_document.dart';

/// Terms / Privacy stand-in: title + "Coming soon" until the copy exists
/// (docs/specs/auth/open-questions.md, Q5).
class LegalPlaceholderScreen extends StatelessWidget {
  const LegalPlaceholderScreen({super.key, required this.kind});

  final LegalDocument kind;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: AppText(kind.l10n(context), style: context.text.title),
    ),
    body: Center(
      child: AppText(
        context.l10n.comingSoon,
        style: context.text.subtitle,
        color: context.appColors.textSecondary,
      ),
    ),
  );
}
