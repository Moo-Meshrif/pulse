import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/extensions/failure_l10n.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<String> words(WidgetTester tester, Failure failure) async {
    late String text;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            text = failure.l10n(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return text;
  }

  testWidgets('each failure gets its own words', (tester) async {
    expect(
      await words(
        tester,
        const AuthFailure(AuthFailureReason.invalidCredentials),
      ),
      l10nEn.errorCredentials,
    );
    expect(
      await words(
        tester,
        const AuthFailure(
          AuthFailureReason.tooManyAttempts,
          retryAfter: Duration(seconds: 90),
        ),
      ),
      l10nEn.errorTooManyAttempts('1:30'),
    );
    expect(await words(tester, const NetworkFailure()), l10nEn.errorNetwork);
    expect(await words(tester, const TimeoutFailure()), l10nEn.errorNetwork);
    expect(await words(tester, const ServerFailure()), l10nEn.errorServer);
    expect(await words(tester, const UnexpectedFailure()), l10nEn.errorGeneric);
    expect(
      await words(tester, const AuthFailure(AuthFailureReason.weakPassword)),
      l10nEn.errorWeakPassword,
    );
    expect(
      await words(tester, const AuthFailure(AuthFailureReason.samePassword)),
      l10nEn.errorSamePassword,
    );
    expect(
      await words(tester, const AuthFailure(AuthFailureReason.sessionExpired)),
      l10nEn.errorSessionExpired,
    );
  });
}
