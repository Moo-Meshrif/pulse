import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_dimens.dart';
import '../theme/app_scale.dart';
import '../theme/app_text_styles.dart';
import '../utils/country_codes.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';
import 'app_text_field.dart';
import 'country_code_sheet.dart';

/// An international phone field: a country-code button (opens [CountryCodeSheet]) before the number.
/// [initialPhone] and [onChanged] use the joined form ("+966 5…", empty while no number is typed), so the
/// owner stores one string and validates it with `isValidPhone`.
class PhoneField extends StatefulWidget {
  const PhoneField({
    super.key,
    this.initialPhone = '',
    required this.onChanged,
    this.focusNode,
    this.onSubmitted,
    this.errorText,
    this.helperText,
    this.readOnly = false,
    this.textInputAction,
  });

  final String initialPhone;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final String? helperText;
  final bool readOnly;
  final TextInputAction? textInputAction;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late final _initial = splitPhone(widget.initialPhone);
  late final _number = TextEditingController(text: _initial.number);
  late final ValueNotifier<CountryCode> _country = ValueNotifier(
    _initial.country,
  );

  @override
  void dispose() {
    _number.dispose();
    _country.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(joinPhone(_country.value, _number.text));

  Future<void> _chooseCountry() async {
    final picked = await CountryCodeSheet.show(
      context,
      selected: _country.value,
    );
    if (picked == null) return;
    _country.value = picked;
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppTextField(
      label: l10n.phoneLabel,
      hint: l10n.phoneHint,
      controller: _number,
      focusNode: widget.focusNode,
      forceLtr: true,
      readOnly: widget.readOnly,
      keyboardType: TextInputType.phone,
      textInputAction: widget.textInputAction,
      autofillHints: [AutofillHints.telephoneNumberNational],
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s]'))],
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefix: ValueListenableBuilder<CountryCode>(
        valueListenable: _country,
        builder: (context, country, _) => _CountryButton(
          country: country,
          enabled: !widget.readOnly,
          onTap: _chooseCountry,
        ),
      ),
      onChanged: (_) => _emit(),
      onSubmitted: widget.onSubmitted,
    );
  }
}

/// The tappable "flag +code ⌄" before the phone number.
class _CountryButton extends StatelessWidget {
  const _CountryButton({
    required this.country,
    required this.enabled,
    required this.onTap,
  });

  final CountryCode country;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: '${country.name(context)} ${country.label}',
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.s16,
            end: AppSpacing.s8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                country.flag,
                style: TextStyle(fontSize: AppScale.scale(20)),
              ),
              SizedBox(width: AppSpacing.s8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: AppText(
                  country.label,
                  style: context.text.body,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(width: AppSpacing.s4),
              AppSvgIcon(
                AppAssets.chevronDown,
                size: AppSpacing.s16,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
