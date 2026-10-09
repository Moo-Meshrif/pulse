import 'package:flutter/widgets.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../profile/data/enums/gender.dart';

extension GenderL10n on Gender {
  String l10n(BuildContext context) => switch (this) {
    Gender.female => context.l10n.genderFemale,
    Gender.male => context.l10n.genderMale,
    Gender.preferNotToSay => context.l10n.genderPreferNot,
  };
}
