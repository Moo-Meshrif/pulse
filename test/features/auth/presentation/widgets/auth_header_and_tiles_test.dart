import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/features/auth/presentation/widgets/auth_header.dart';
import 'package:pulse/features/auth/presentation/widgets/icon_tile.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  testView('header: title, then subtitle 8 below; the emphasis is bold', (
    tester,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: AuthHeader(
          title: 'Check your email',
          subtitle: 'We sent a code to dip•••@gmail.com. Enter it below.',
          emphasis: 'dip•••@gmail.com',
        ),
      ),
    );
    expect(find.text('Check your email'), findsOneWidget);
    final title = tester.widget<Text>(find.text('Check your email')).style!;
    expect(title.fontSize, 30);
    expect(title.fontWeight, FontWeight.w700);

    final rich = tester.widget<RichText>(
      find.textContaining('We sent a code', findRichText: true),
    );
    final spans = ((rich.text as TextSpan).children!.first as TextSpan)
        .children!
        .cast<TextSpan>();
    expect(spans.map((s) => s.text), [
      'We sent a code to ',
      'dip•••@gmail.com',
      '. Enter it below.',
    ]);
    expect(spans[1].style!.fontWeight, FontWeight.w700);
    expect(spans[0].style, isNull);
  });

  testView('header: without emphasis the subtitle is one plain run', (
    tester,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: AuthHeader(title: 'T', subtitle: 'Just text.'),
      ),
    );
    expect(find.text('Just text.', findRichText: true), findsOneWidget);
  });

  testView('header: a leading tile sits 24 above the title', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: AuthHeader(
          leading: IconTile(icon: AppAssets.lock),
          title: 'Forgot password?',
          subtitle: 'Enter the email.',
        ),
      ),
    );
    final tileBottom = tester.getBottomLeft(find.byType(IconTile)).dy;
    final titleTop = tester.getTopLeft(find.text('Forgot password?')).dy;
    expect(titleTop - tileBottom, closeTo(24, 8)); // the line box adds a few dp
  });

  testView('header: a long title wraps and is never truncated', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: AuthHeader(
          title: 'Follow the people you already know on Pulse today',
          subtitle: 's',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(
      find.text('Follow the people you already know on Pulse today'),
    );
    expect(text.maxLines, isNull);
    expect(text.overflow, isNull);
  });

  testView('logo tile: 48 square, radius 14, primary fill', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: Align(alignment: Alignment.topLeft, child: LogoTile()),
      ),
    );
    expect(tester.getSize(find.byType(LogoTile)), const Size(48, 48));
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.circular(14));
    expect(
      tester
          .widget<ColoredBox>(
            find.descendant(
              of: find.byType(ClipRRect),
              matching: find.byType(ColoredBox),
            ),
          )
          .color,
      colors.primary,
    );
  });

  testView('icon tile: 72 square, radius 22, primarySoft, 32 primary icon', (
    tester,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: IconTile(icon: AppAssets.mail),
        ),
      ),
    );
    expect(tester.getSize(find.byType(IconTile)), const Size(72, 72));
    final box = tester.widget<Container>(find.byType(Container).first);
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, colors.primarySoft);
    expect(decoration.borderRadius, BorderRadius.circular(22));
  });

  testView('tiles are decorative: no semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      const Scaffold(
        body: Column(
          children: [
            LogoTile(),
            IconTile(icon: AppAssets.lock),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });
}
