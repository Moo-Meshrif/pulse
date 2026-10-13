import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/not_found_screen.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the not-found copy and no action', (tester) async {
    await tester.pumpApp(const NotFoundScreen(), settle: false);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10nEn.notFoundPageTitle), findsOneWidget);
    expect(find.text(l10nEn.goToHome), findsNothing);
  });
}
