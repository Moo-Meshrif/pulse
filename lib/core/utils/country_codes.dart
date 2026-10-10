import 'package:country_picker/country_picker.dart';
import 'package:flutter/widgets.dart';

/// A country's calling code for the phone field, over the `country_picker` data (all countries, names in
/// 40+ languages through `CountryLocalizations`). [dial] has no "+".
class CountryCode {
  const CountryCode._(this.iso, this.flag, this.nameEn, this.dial, this.level);

  factory CountryCode._from(Country c) =>
      CountryCode._(c.countryCode, c.flagEmoji, c.name, c.phoneCode, c.level);

  /// ISO 3166 alpha-2, the identity of a country (several share a dial code).
  final String iso;
  final String flag;
  final String nameEn;
  final String dial;

  /// 1 for the main country of a shared dial code (the US for "1"), higher for the others.
  final int level;

  /// The name in the app's language, English when the package has none.
  String name(BuildContext context) =>
      CountryLocalizations.of(context)?.countryName(countryCode: iso) ?? nameEn;

  String get label => '+$dial';

  @override
  bool operator ==(Object other) => other is CountryCode && other.iso == iso;

  @override
  int get hashCode => iso.hashCode;
}

/// Every country with a calling code, A to Z.
final List<CountryCode> countryCodes = () {
  final list = [
    for (final c in CountryService().getAll())
      if (c.geographic) CountryCode._from(c),
  ]..sort((a, b) => a.nameEn.compareTo(b.nameEn));
  return List<CountryCode>.unmodifiable(list);
}();

final CountryCode defaultCountry = countryCodes.firstWhere(
  (c) => c.iso == 'EG',
);

/// Splits a stored international [phone] ("+966 5…") into its country and the rest. A number without a
/// known "+code" keeps [defaultCountry] and is returned whole.
({CountryCode country, String number}) splitPhone(String phone) {
  final trimmed = phone.trim();
  if (!trimmed.startsWith('+')) {
    return (country: defaultCountry, number: trimmed);
  }
  final digits = trimmed.substring(1).replaceAll(RegExp(r'\s'), '');
  CountryCode? best;
  for (final c in countryCodes) {
    if (!digits.startsWith(c.dial)) continue;
    if (best == null ||
        c.dial.length > best.dial.length ||
        (c.dial.length == best.dial.length && c.level < best.level)) {
      best = c;
    }
  }
  if (best == null) return (country: defaultCountry, number: trimmed);
  return (country: best, number: digits.substring(best.dial.length));
}

/// "+dial number", or empty while no number is typed.
String joinPhone(CountryCode country, String number) {
  final n = number.trim();
  return n.isEmpty ? '' : '${country.label} $n';
}
