import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/features/auth/domain/use_case/is_recovery_pending_use_case.dart';
import 'package:pulse/features/control/presentation/cubit/control_cubit.dart';
import 'package:pulse/features/control/presentation/screen/control_screen.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/glass_nav_bar.dart';
import 'package:pulse/features/home/presentation/screen/home_screen.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../../../helpers/feed_refresh_mocks.dart';
import '../../../home/home_doubles.dart';

class MockIsRecoveryPending extends Mock implements IsRecoveryPendingUseCase {}

void main() {
  late MockIsRecoveryPending recovery;

  setUp(() async {
    await getIt.reset();
    recovery = MockIsRecoveryPending();
    when(() => recovery()).thenReturn(false);
    getIt.registerFactory<ControlCubit>(
      () => ControlCubit(recovery, MockRequestFeedRefresh()),
    );
    registerHomeDoubles();
  });

  tearDown(() => getIt.reset());

  Future<void> pumpHome(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => settings.name == AppRoutes.resetPassword
            ? const Text('reset screen')
            : const ControlScreen(),
      ),
    ),
  );

  testWidgets('opens on Home with the nav bar and the Home screen', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.pumpAndSettle();
    expect(find.byType(GlassNavBar), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('reset screen'), findsNothing);
  });

  testWidgets('a reset that was started and not finished goes to the reset '
      'screen, never stays on Home', (tester) async {
    when(() => recovery()).thenReturn(true);
    await pumpHome(tester);
    await tester.pumpAndSettle();
    expect(find.text('reset screen'), findsOneWidget);
    expect(find.byType(GlassNavBar), findsNothing);
  });
}
