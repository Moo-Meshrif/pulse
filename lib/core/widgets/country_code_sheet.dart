import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_dimens.dart';
import '../theme/app_scale.dart';
import '../theme/app_text_styles.dart';
import 'app_text.dart';
import 'app_text_field.dart';
import '../utils/country_codes.dart';

/// A searchable bottom sheet to pick the phone's country code.
abstract final class CountryCodeSheet {
  /// The picked [CountryCode], or null when dismissed.
  static Future<CountryCode?> show(
    BuildContext context, {
    required CountryCode selected,
  }) {
    final colors = context.appColors;
    return showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colors.surface,
      barrierColor: colors.scrim,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheetTop),
        ),
      ),
      builder: (_) => _Sheet(selected: selected),
    );
  }
}

class _Sheet extends StatefulWidget {
  const _Sheet({required this.selected});

  final CountryCode selected;

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  String _query = '';

  List<CountryCode> _matches(BuildContext context) {
    final q = _query.trim().toLowerCase().replaceFirst('+', '');
    if (q.isEmpty) return countryCodes;
    return [
      for (final c in countryCodes)
        if (c.nameEn.toLowerCase().contains(q) ||
            c.name(context).toLowerCase().contains(q) ||
            c.iso.toLowerCase() == q ||
            c.dial.startsWith(q))
          c,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final matches = _matches(context);
    final height = MediaQuery.sizeOf(context).height * 0.75;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.formSide),
              child: AppText(
                l10n.countryPickerTitle,
                style: context.text.name,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.s12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.formSide),
              child: AppTextField(
                label: l10n.countrySearchHint,
                hint: l10n.countrySearchHint,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(height: AppSpacing.s8),
            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: AppText(
                        l10n.countryNoResults,
                        style: context.text.body,
                        color: colors.textSecondary,
                      ),
                    )
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, i) => _Row(
                        country: matches[i],
                        selected:
                            matches[i].dial == widget.selected.dial &&
                            matches[i].nameEn == widget.selected.nameEn,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.country, required this.selected});

  final CountryCode country;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () => Navigator.of(context).pop(country),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AuthDimens.tapTarget),
        child: Container(
          color: selected ? colors.primarySoft : null,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.formSide,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              Text(
                country.flag,
                style: TextStyle(fontSize: AppScale.scale(24)),
              ),
              SizedBox(width: AppSpacing.s16),
              Expanded(
                child: AppText(
                  country.name(context),
                  style: context.text.body,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(width: AppSpacing.s8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: AppText(
                  country.label,
                  style: context.text.body,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
