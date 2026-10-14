import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/extensions/l10n.dart';
import '../../../../core/utils/post_time.dart';

/// `{city} · {time}`, or just the time when the post has no city.
String postAuthorMeta(
  BuildContext context, {
  String? city,
  required DateTime createdAt,
}) {
  final trimmedCity = city?.trim();
  return [
    if (trimmedCity != null && trimmedCity.isNotEmpty) trimmedCity,
    postTime(context.l10n, createdAt, clock.now()),
  ].join(' · ');
}
