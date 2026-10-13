import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/router/placeholder_screen.dart';

void main() {
  for (final route in [AppRoutes.createPost, AppRoutes.createShort]) {
    testWidgets('$route opens its placeholder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: route,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
        ),
      );
      expect(find.byType(PlaceholderScreen), findsOneWidget);
      expect(find.text(route), findsOneWidget);
    });
  }
}
