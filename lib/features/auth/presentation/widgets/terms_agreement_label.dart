import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../utils/enums/legal_document.dart';

/// "I agree to the **Terms** and **Privacy Policy** *": the links are `primary`, bold and underlined and
/// open [onOpen]; the asterisk is `danger` (docs/specs/auth/screens/s3-signup-account.md).
class TermsAgreementLabel extends StatefulWidget {
  const TermsAgreementLabel({super.key, required this.onOpen});

  final ValueChanged<LegalDocument> onOpen;

  @override
  State<TermsAgreementLabel> createState() => _TermsAgreementLabelState();
}

class _TermsAgreementLabelState extends State<TermsAgreementLabel> {
  late final _terms = TapGestureRecognizer()
    ..onTap = () => widget.onOpen(LegalDocument.terms);
  late final _privacy = TapGestureRecognizer()
    ..onTap = () => widget.onOpen(LegalDocument.privacy);

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final base = context.text.body.copyWith(color: colors.textPrimary);
    final link = base.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: colors.primary,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: '${l10n.agreePrefix} '),
          TextSpan(
            text: LegalDocument.terms.l10n(context),
            style: link,
            recognizer: _terms,
          ),
          TextSpan(text: ' ${l10n.agreeAnd} '),
          TextSpan(
            text: LegalDocument.privacy.l10n(context),
            style: link,
            recognizer: _privacy,
          ),
          TextSpan(
            text: ' *',
            style: base.copyWith(color: colors.danger),
          ),
        ],
      ),
    );
  }
}
