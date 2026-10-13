import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/signed_out_reason.dart';
import 'package:pulse/core/services/session_events.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';
import 'package:pulse/features/auth/domain/use_case/watch_session_ended_use_case.dart';

class _MockAuth extends Mock implements AuthDatasource {}

void main() {
  late _MockAuth auth;
  late StreamController<SignedOutReason> fromSdk;
  late SessionEvents events;
  late WatchSessionEndedUseCase useCase;

  setUp(() {
    auth = _MockAuth();
    fromSdk = StreamController<SignedOutReason>.broadcast();
    events = SessionEvents();
    when(() => auth.sessionEnded).thenAnswer((_) => fromSdk.stream);
    useCase = WatchSessionEndedUseCase(auth, events);
  });

  tearDown(() async {
    await fromSdk.close();
    await events.dispose();
  });

  test('relays the SDK ending and a revoked request, in order', () async {
    final ended = <SignedOutReason>[];
    final sub = useCase().listen(ended.add);

    fromSdk.add(SignedOutReason.expired);
    await Future<void>.value();
    events.revoked();
    await Future<void>.value();

    expect(ended, [SignedOutReason.expired, SignedOutReason.revoked]);
    await sub.cancel();
  });

  test('cancelling stops both sources', () async {
    final ended = <SignedOutReason>[];
    final sub = useCase().listen(ended.add);
    await sub.cancel();

    fromSdk.add(SignedOutReason.expired);
    events.revoked();
    await Future<void>.value();

    expect(ended, isEmpty);
    expect(fromSdk.hasListener, isFalse);
    expect(events.ended.isBroadcast, isTrue);
  });
}
