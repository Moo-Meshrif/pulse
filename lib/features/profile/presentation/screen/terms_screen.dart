import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/enums/legal_document.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/services/app_version_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/datasource/legal_dates_datasource.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});
  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  Future<Map<String, DateTime>>? _dates;
  late final Future<String> _version = getIt<AppVersionService>().version();
  String? _language;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_language != language) {
      _language = language;
      _dates = getIt<LegalDatesDatasource>().getUpdatedDates(language);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = NavClearance.of(context) + AppSpacing.s32;
    return AppPage(
      title: l10n.helpTermsTitle,
      backgroundColor: context.appColors.background,
      bottomSpace: bottom,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: AppSpacing.s16, bottom: bottom),
        child: Column(
          children: [
            FutureBuilder<Map<String, DateTime>>(
              future: _dates,
              builder: (context, snapshot) => SettingsGroup(
                children: LegalDocument.values.map((doc) {
                  final date = snapshot.data?[doc.wire];
                  return SettingsRow(
                    icon: AppAssets.document,
                    title: doc == LegalDocument.terms
                        ? l10n.helpTermsOfService
                        : doc.l10n(context),
                    subtitle: date == null
                        ? null
                        : l10n.helpLastUpdated(
                            DateFormat.yMMMd(_language).format(date.toLocal()),
                          ),
                    onTap: () => AppNavigator.push(context, doc.route),
                  );
                }).toList(),
              ),
            ),
            SettingsGroup(
              label: l10n.helpYourData,
              children: [
                // TODO(profile-plan T8): data export and ad preferences are not built
                SettingsRow(
                  title: l10n.helpDownloadData,
                  subtitle: l10n.helpDownloadDataSub,
                  onTap: () => Notices.info(l10n.helpDataSoon),
                ),
                SettingsRow(
                  title: l10n.helpAdPreferences,
                  subtitle: l10n.helpAdPreferencesSub,
                  onTap: () => Notices.info(l10n.helpDataSoon),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s24),
            FutureBuilder<String>(
              future: _version,
              builder: (context, snapshot) => snapshot.hasData
                  ? AppText(
                      l10n.settingsVersion(snapshot.data!),
                      style: context.text.caption,
                      color: context.appColors.textSecondary,
                    )
                  : const SizedBox.shrink(),
            ),
            // TODO(profile-plan T2): placeholder company name
            AppText(
              l10n.helpCopyright(clock.now().year.toString(), 'Pulse'),
              style: context.text.caption,
              color: context.appColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
