import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// `country_picker`'s own delegate loads on the next microtask, which delays the first frame; this one
/// answers at once. It gives [CountryLocalizations] (country names in the app's language).
class CountryNamesDelegate extends LocalizationsDelegate<CountryLocalizations> {
  const CountryNamesDelegate();

  @override
  bool isSupported(Locale locale) =>
      CountryLocalizations.delegate.isSupported(locale);

  @override
  Future<CountryLocalizations> load(Locale locale) =>
      SynchronousFuture(CountryLocalizations(locale));

  @override
  bool shouldReload(CountryNamesDelegate old) => false;
}
