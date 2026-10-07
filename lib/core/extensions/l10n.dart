// Features import only this file.
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// For `intl` formatters: `NumberFormat…(locale: context.localeName)`.
  String get localeName => l10n.localeName;
}
