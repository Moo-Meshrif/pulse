import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/locale_service.dart';
import '../view/language_view.dart';

/// `/settings/language` (docs/specs/profile/screens/s8-language.md).
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      LanguageView(localeService: getIt<LocaleService>());
}
