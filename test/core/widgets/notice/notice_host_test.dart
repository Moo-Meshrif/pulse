import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/notice/notices.dart';
import 'package:pulse/core/widgets/notice/notice_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    await tester.pumpApp(const Scaffold(body: Text('page')));
    addTearDown(Notices.clear);
  }

  testView('a notice drops in, and its action runs once and dismisses', (
    tester,
  ) async {
    await open(tester);
    var undone = 0;
    Notices.info('Muted', actionLabel: 'Undo', onAction: () => undone++);
    await tester.pumpAndSettle();
    expect(find.text('Muted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undone, 1);
    expect(find.byType(NoticeCard), findsNothing);
  });

  testView('a tap on the card dismisses it', (tester) async {
    await open(tester);
    Notices.success('Post published');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Post published'));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeCard), findsNothing);
  });

  testView('a swipe up dismisses it', (tester) async {
    await open(tester);
    Notices.error('Couldn\'t sign in');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(NoticeCard), const Offset(0, -60));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeCard), findsNothing);
  });

  testView('it runs out by itself after its duration', (tester) async {
    await open(tester);
    Notices.autoDismiss = true;
    Notices.success('Saved');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Saved'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(NoticeCard), findsNothing);
  });

  testView('a notice of another kind waits and then shows', (tester) async {
    await open(tester);
    Notices.success('First');
    await tester.pumpAndSettle();
    Notices.error('Second');
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);

    await tester.tap(find.text('First'));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
  });
}
