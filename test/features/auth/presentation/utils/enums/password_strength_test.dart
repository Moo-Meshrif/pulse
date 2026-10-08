import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/features/auth/presentation/utils/enums/password_strength.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  test('maps the score to a strength; a score of 0 has none', () {
    expect(PasswordStrength.of(''), isNull);
    expect(PasswordStrength.of('abcdefgh'), PasswordStrength.weak);
    expect(PasswordStrength.of('abcdefgH'), PasswordStrength.fair);
    expect(PasswordStrength.of('abcdefH1'), PasswordStrength.good);
    expect(PasswordStrength.of('abcdefH1!'), PasswordStrength.strong);
  });

  test('each strength fills its number of segments', () {
    expect(PasswordStrength.values.map((s) => s.segments), [1, 2, 3, 4]);
  });

  testWidgets('colors and labels follow the spec, in English and Arabic', (
    tester,
  ) async {
    final colors = AppColors.light;
    late BuildContext context;
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      await tester.pumpApp(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
        locale: locale,
      );
      expect(PasswordStrength.weak.color(context), colors.danger);
      expect(PasswordStrength.fair.color(context), colors.warning);
      expect(PasswordStrength.good.color(context), colors.primary);
      expect(PasswordStrength.strong.color(context), colors.primary);
      final l10n = locale.languageCode == 'en' ? l10nEn : l10nAr;
      expect(PasswordStrength.weak.l10n(context), l10n.strengthWeak);
      expect(PasswordStrength.strong.l10n(context), l10n.strengthStrong);
    }
  });
}
