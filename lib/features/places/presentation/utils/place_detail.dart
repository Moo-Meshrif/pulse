import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/l10n.dart';
import '../../domain/entity/place_entity.dart';
import 'place_kind_display.dart';

/// The second line of a place row: its kind, where it is, and how far, e.g. "Neighborhood · Cairo ·
/// 1.4 km" or "Zamalek, Cairo · 0.8 km". Parts that are not known are left out.
String placeDetail(BuildContext context, PlaceEntity place) {
  final km = place.distanceKm;
  final parts = [
    place.kind.label(context),
    if (place.subtitle.isNotEmpty) place.subtitle,
    if (km != null)
      context.l10n.locationDistance(
        NumberFormat(
          '0.#',
          Localizations.localeOf(context).toLanguageTag(),
        ).format(km),
      ),
  ];
  return parts.nonNulls.join(' · ');
}
