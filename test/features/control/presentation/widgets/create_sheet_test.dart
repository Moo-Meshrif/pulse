import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/control/presentation/utils/enums/create_option.dart';
import 'package:pulse/features/control/presentation/widgets/create_sheet/create_option_row.dart';
import 'package:pulse/features/control/presentation/widgets/create_sheet/create_sheet.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  CreateOption? picked;
  bool answered = false;

  setUp(() {
    picked = null;
    answered = false;
  });

  Future<void> openSheet(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            picked = await CreateSheet.show(context);
            answered = true;
          },
          child: const Text('open'),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder row(CreateOption option) =>
      find.byWidgetPredicate((w) => w is CreateOptionRow && w.option == option);

  testWidgets('shows the title and both options with their description', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.text(l10nEn.createTitle), findsOneWidget);
    expect(find.text(l10nEn.createPost), findsOneWidget);
    expect(find.text(l10nEn.createPostSub), findsOneWidget);
    expect(find.text(l10nEn.createShort), findsOneWidget);
    expect(find.text(l10nEn.createShortSub), findsOneWidget);
  });

  testWidgets('each row shows its own icon', (tester) async {
    await openSheet(tester);
    for (final option in CreateOption.values) {
      expect(
        find.descendant(
          of: row(option),
          matching: find.byWidgetPredicate(
            (w) => w is AppSvgIcon && w.asset == option.icon,
          ),
        ),
        findsOneWidget,
      );
    }
    expect(CreateOption.post.icon, AppAssets.createPost);
    expect(CreateOption.short.icon, AppAssets.createShort);
  });

  testWidgets('Post closes the sheet with the Post option', (tester) async {
    await openSheet(tester);
    await tester.tap(row(CreateOption.post));
    await tester.pumpAndSettle();
    expect(picked, CreateOption.post);
    expect(find.byType(AppBottomSheetShell), findsNothing);
  });

  testWidgets('Short closes the sheet with the Short option', (tester) async {
    await openSheet(tester);
    await tester.tap(row(CreateOption.short));
    await tester.pumpAndSettle();
    expect(picked, CreateOption.short);
  });

  testWidgets('the close button, the scrim and back pick nothing', (
    tester,
  ) async {
    await openSheet(tester);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Close',
      ),
    );
    await tester.pumpAndSettle();
    expect(answered, isTrue);
    expect(picked, isNull);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(picked, isNull);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(picked, isNull);
  });

  testWidgets('a row is read as one button: title and description', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await openSheet(tester);
    expect(
      find.bySemanticsLabel('${l10nEn.createPost}. ${l10nEn.createPostSub}'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('Arabic: Arabic texts, and the chevron is on the left', (
    tester,
  ) async {
    await openSheet(tester, locale: const Locale('ar'));
    expect(find.text(l10nAr.createTitle), findsOneWidget);
    expect(find.text(l10nAr.createPostSub), findsOneWidget);
    final chevron = find.descendant(
      of: row(CreateOption.post),
      matching: find.byWidgetPredicate(
        (w) => w is AppSvgIcon && w.asset == AppAssets.chevronRight,
      ),
    );
    expect(
      tester.getCenter(chevron).dx,
      lessThan(tester.getCenter(find.text(l10nAr.createPost)).dx),
    );
  });

  testWidgets('with text at 1.5x the descriptions wrap and nothing overflows', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openSheet(tester);
    expect(tester.takeException(), isNull);
    expect(find.text(l10nEn.createShortSub), findsOneWidget);
  });
}
