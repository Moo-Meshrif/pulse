import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/widgets/add_edit_post/media_thumb.dart';
import 'package:pulse/features/post/presentation/widgets/media/post_retry_badge.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpThumb(
    WidgetTester tester, {
    VoidCallback? onRetryUpload,
    Locale locale = const Locale('en'),
  }) => tester.pumpApp(
    Center(
      child: MediaThumb(
        index: 0,
        onRemove: () {},
        onRetryUpload: onRetryUpload,
      ),
    ),
    locale: locale,
  );

  testWidgets('a file that is uploading or uploaded shows nothing extra', (
    tester,
  ) async {
    await pumpThumb(tester);
    expect(find.byType(PostRetryBadge), findsNothing);
    expect(find.bySemanticsLabel(l10nEn.newPostUploadFailed), findsNothing);
  });

  testWidgets('a failed upload shows the retry badge; a tap tries again', (
    tester,
  ) async {
    var retries = 0;
    await pumpThumb(tester, onRetryUpload: () => retries++);
    expect(find.byType(PostRetryBadge), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(l10nEn.newPostUploadFailed));
    expect(retries, 1);
  });

  testWidgets('the remove button still works on a failed file', (tester) async {
    var removed = 0;
    var retries = 0;
    await tester.pumpApp(
      Center(
        child: MediaThumb(
          index: 0,
          onRemove: () => removed++,
          onRetryUpload: () => retries++,
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel(l10nEn.newPostRemoveMedia(1)));
    expect(removed, 1);
    expect(retries, 0);
  });

  testWidgets('in Arabic, right to left', (tester) async {
    await pumpThumb(tester, onRetryUpload: () {}, locale: const Locale('ar'));
    final badge = find.bySemanticsLabel(l10nAr.newPostUploadFailed);
    expect(badge, findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(PostRetryBadge))),
      TextDirection.rtl,
    );
  });
}
