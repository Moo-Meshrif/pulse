import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/local_storage_service.dart';
import 'package:pulse/core/services/storage_keys.dart';
import 'package:pulse/features/auth/data/datasource/password_recovery_tracker.dart';
import 'package:pulse/features/auth/data/enums/recovery_signal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPrefsStorageService storage;
  late PasswordRecoveryTracker tracker;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = SharedPrefsStorageService(await SharedPreferences.getInstance());
    tracker = PasswordRecoveryTracker(storage);
  });

  tearDown(() => tracker.dispose());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'opening the link sets the flag, which survives a new tracker',
    () async {
      expect(tracker.isPending, isFalse);
      await tracker.linkOpened();
      expect(tracker.isPending, isTrue);
      expect(PasswordRecoveryTracker(storage).isPending, isTrue);
    },
  );

  test('end clears the flag', () async {
    await tracker.linkOpened();
    await tracker.end();
    expect(tracker.isPending, isFalse);
    expect(storage.getValue<bool>(StorageKeys.recoveryPending), isNull);
  });

  test('a live listener gets the signal once', () async {
    final signals = <RecoverySignal>[];
    final sub = tracker.signals.listen(signals.add);
    await tracker.linkOpened();
    await settle();
    expect(signals, [RecoverySignal.started]);
    await sub.cancel();
  });

  test(
    'a signal with no listener is given to the next one, then forgotten',
    () async {
      await tracker.linkOpened();

      final first = <RecoverySignal>[];
      final sub = tracker.signals.listen(first.add);
      await settle();
      await sub.cancel();

      final second = <RecoverySignal>[];
      final again = tracker.signals.listen(second.add);
      await settle();

      expect(first, [RecoverySignal.started]);
      expect(second, isEmpty);
      await again.cancel();
    },
  );

  test('only the latest undelivered signal is kept', () async {
    await tracker.linkOpened();
    tracker.linkRefused();

    final signals = <RecoverySignal>[];
    final sub = tracker.signals.listen(signals.add);
    await settle();

    expect(signals, [RecoverySignal.linkFailed]);
    await sub.cancel();
  });

  test(
    'end drops an undelivered started signal but keeps a refused link',
    () async {
      await tracker.linkOpened();
      await tracker.end();
      var signals = <RecoverySignal>[];
      var sub = tracker.signals.listen(signals.add);
      await settle();
      expect(signals, isEmpty);
      await sub.cancel();

      tracker.linkRefused();
      await tracker.end();
      signals = [];
      sub = tracker.signals.listen(signals.add);
      await settle();
      expect(signals, [RecoverySignal.linkFailed]);
      await sub.cancel();
    },
  );

  test(
    'a listener that cancels before delivery does not lose the signal',
    () async {
      await tracker.linkOpened();
      final quitter = tracker.signals.listen((_) {});
      await quitter.cancel(); // before the microtask runs

      final signals = <RecoverySignal>[];
      final sub = tracker.signals.listen(signals.add);
      await settle();

      expect(signals, [RecoverySignal.started]);
      await sub.cancel();
    },
  );

  test('after dispose nothing is published and nothing throws', () async {
    await tracker.dispose();
    tracker.linkRefused();
    await tracker.linkOpened();
  });

  test('a pending signal reaches every listener that joins before delivery, once each', () async {
    await tracker.linkOpened();
    final a = <RecoverySignal>[];
    final b = <RecoverySignal>[];
    final subA = tracker.signals.listen(a.add);
    final subB = tracker.signals.listen(b.add);
    await settle();
    expect(a, [RecoverySignal.started]);
    expect(b, [RecoverySignal.started]);
    await subA.cancel();
    await subB.cancel();
  });

  test('dispose can be called twice', () async {
    await tracker.dispose();
    await tracker.dispose();
  });
}
