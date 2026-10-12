import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/enums/signed_out_reason.dart';
import 'package:pulse/features/auth/presentation/widgets/account_card.dart';
import 'package:pulse/features/auth/presentation/widgets/session_banner.dart';

import '../../../../helpers/pump_app.dart';

/// The two S14 widgets: texts, the "Not you?" action and no overflow at small widths, big text and RTL.
void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Locale locale = const Locale('en'),
  }) => tester.pumpApp(
    Scaffold(body: SingleChildScrollView(child: child)),
    locale: locale,
  );

  Widget both({VoidCallback? onNotYou}) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const SessionBanner(reason: SignedOutReason.revoked),
        const SizedBox(height: 28),
        AccountCard(
          id: 'u1',
          fullName: 'Nour Adel Mohamed Abdelrahman Ibrahim',
          username: 'nour.adel.with.a.long.username',
          onNotYou: onNotYou,
        ),
      ],
    ),
  );

  testView('the banner words each reason', (tester) async {
    await pump(
      tester,
      const Column(
        children: [
          SessionBanner(reason: SignedOutReason.expired),
          SessionBanner(reason: SignedOutReason.revoked),
        ],
      ),
    );

    expect(find.text(l10nEn.signedOutTitle), findsNWidgets(2));
    expect(find.text(l10nEn.signedOutExpiredBody), findsOneWidget);
    expect(find.text(l10nEn.signedOutRevokedBody), findsOneWidget);
  });

  testView('the card shows initials, name and @username; Not you? calls back', (
    tester,
  ) async {
    var tapped = 0;
    await pump(
      tester,
      AccountCard(
        id: 'u1',
        fullName: 'Nour Adel',
        username: 'nour.adel',
        onNotYou: () => tapped++,
      ),
    );

    expect(find.text(l10nEn.accountLabel), findsOneWidget);
    expect(find.text('NA'), findsOneWidget);
    expect(find.text('Nour Adel'), findsOneWidget);
    expect(find.text('@nour.adel'), findsOneWidget);

    await tester.tap(find.text(l10nEn.notYou));
    expect(tapped, 1);
  });

  testView('with no full name the username is the name', (tester) async {
    await pump(
      tester,
      AccountCard(
        id: 'u1',
        fullName: null,
        username: 'nour.adel',
        onNotYou: () {},
      ),
    );
    expect(find.text('nour.adel'), findsOneWidget);
    expect(find.text('@nour.adel'), findsOneWidget);
  });

  testView('Not you? does nothing while busy (no callback)', (tester) async {
    await pump(tester, both());
    await tester.tap(find.text(l10nEn.notYou));
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final scale in const [1.0, 2.0]) {
      for (final width in const [320.0, 390.0]) {
        testWidgets(
          '${locale.languageCode} text x$scale at $width: no overflow',
          (tester) async {
            setUpView(tester, size: Size(width, 700), textScale: scale);
            await pump(tester, both(onNotYou: () {}), locale: locale);

            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
