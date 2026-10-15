import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/router/end_slide_page_route.dart';
import 'package:pulse/core/router/placeholder_screen.dart';
import 'package:pulse/features/post/presentation/screen/add_edit_post_screen.dart';

void main() {
  for (final route in [
    AppRoutes.createShort,
    AppRoutes.search,
    AppRoutes.activity,
    AppRoutes.commentsOf('p1'),
  ]) {
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

  testWidgets('/create/post opens the New post screen', (tester) async {
    late Widget screen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final route = AppRouter.onGenerateRoute(
              const RouteSettings(name: AppRoutes.createPost),
            );
            screen = (route as MaterialPageRoute<dynamic>).builder(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(screen, isA<AddEditPostScreen>());
  });

  testWidgets('/create/post/location opens Add location with the place', (
    tester,
  ) async {
    late Route<dynamic> route;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            route = AppRouter.onGenerateRoute(
              const RouteSettings(
                name: AppRoutes.pickPlace,
                arguments: 'Zamalek, Cairo',
              ),
            );
            return const SizedBox();
          },
        ),
      ),
    );
    expect(route, isA<EndSlidePageRoute<dynamic>>());
    expect(route.settings.arguments, 'Zamalek, Cairo');
  });
}
