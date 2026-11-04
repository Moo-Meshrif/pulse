import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../widgets/language_row.dart';

/// The Language page: a search field and the two languages the app has. Choosing one applies it at once
/// and stays on the page.
class LanguageView extends StatefulWidget {
  const LanguageView({super.key, required this.localeService});

  final LocaleService localeService;

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  String _query = '';

  bool _matches(List<String> names) {
    final query = _query.trim().toLowerCase();
    return names.any((name) => name.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final current = Localizations.localeOf(context).languageCode;
    final bottom = NavClearance.of(context) + AppSpacing.s32;
    // The names of both languages in English too, so "arabic" finds العربية whatever the app language.
    final languages = [
      (
        locale: const Locale('en'),
        native: l10n.settingsLanguageEnglish,
        shown: l10n.languageNameEnglish,
        searchable: [l10n.settingsLanguageEnglish, 'English'],
      ),
      (
        locale: const Locale('ar'),
        native: l10n.settingsLanguageArabic,
        shown: l10n.languageNameArabic,
        searchable: [
          l10n.settingsLanguageArabic,
          'Arabic',
          l10n.languageNameArabic,
        ],
      ),
    ].where((language) => _matches(language.searchable)).toList();
    return AppPage(
      backgroundColor: colors.background,
      title: l10n.languageTitle,
      bottomSpace: bottom,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottom),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.cardMargin,
                AppSpacing.s16,
                AppSpacing.cardMargin,
                0,
              ),
              child: SearchPillField(
                onChanged: (value) => setState(() => _query = value),
                hint: l10n.languageSearch,
                clearLabel: l10n.languageSearchClear,
              ),
            ),
            if (languages.isEmpty)
              Padding(
                padding: EdgeInsets.all(AppSpacing.s32),
                child: AppText(
                  l10n.languageNone,
                  style: context.text.body,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              SettingsGroup(
                label: l10n.languageSectionApp,
                children: [
                  for (final language in languages)
                    LanguageRow(
                      nativeName: language.native,
                      englishName: language.shown,
                      selected: language.locale.languageCode == current,
                      onTap: () => widget.localeService.choose(language.locale),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                  vertical: AppSpacing.s12,
                ),
                child: AppText(
                  l10n.languageRtlNote,
                  style: context.text.bodyXs,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
