import 'package:flutter/widgets.dart';

import '../../../../core/extensions/l10n.dart';
import '../../data/enums/place_kind.dart';

/// How a [PlaceKind] reads in the place rows; a point of interest has no label of its own.
extension PlaceKindDisplay on PlaceKind {
  String? label(BuildContext context) => switch (this) {
    PlaceKind.city => context.l10n.locationKindCity,
    PlaceKind.town => context.l10n.locationKindTown,
    PlaceKind.neighborhood => context.l10n.locationKindNeighborhood,
    PlaceKind.poi => null,
  };
}
