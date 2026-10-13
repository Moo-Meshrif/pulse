import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/enums/signed_out_reason.dart';
import 'package:pulse/core/services/session_events.dart';

void main() {
  test('revoked reaches a listener', () async {
    final events = SessionEvents();
    final ended = <SignedOutReason>[];
    final sub = events.ended.listen(ended.add);

    events.revoked();
    await Future<void>.value();

    expect(ended, [SignedOutReason.revoked]);
    await sub.cancel();
    await events.dispose();
  });

  test('revoked after dispose does nothing', () async {
    final events = SessionEvents();
    await events.dispose();
    events.revoked();
  });
}
