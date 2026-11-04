import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/profile/data/datasource/notification_prefs_datasource.dart';
import 'package:pulse/features/profile/data/enums/notification_pref.dart';
import 'package:pulse/features/profile/data/model/notification_prefs_model.dart';
import 'package:pulse/features/profile/presentation/cubit/notifications/notifications_cubit.dart';

class _MockPrefs extends Mock implements NotificationPrefsDatasource {}

void main() {
  late _MockPrefs prefs;
  late NotificationsCubit cubit;

  setUpAll(() => registerFallbackValue(NotificationPref.push));

  setUp(() {
    prefs = _MockPrefs();
    cubit = NotificationsCubit(prefs);
  });

  tearDown(() => cubit.close());

  test('a missing row loads the defaults', () async {
    when(() => prefs.get())
        .thenAnswer((_) async => NotificationPrefsModel.fromJson(null));
    await cubit.load();
    final loaded = cubit.state.prefs!;
    expect(loaded[NotificationPref.likes], isTrue);
    expect(loaded[NotificationPref.groupChats], isFalse);
    expect(loaded[NotificationPref.emailDigest], isFalse);
  });

  test('a failed load offers a retry', () async {
    when(() => prefs.get()).thenThrow(const NetworkFailure());
    await cubit.load();
    expect(cubit.state.loadFailed, isTrue);
    expect(cubit.state.prefs, isNull);
  });

  test('toggle shows the new value and saves it', () async {
    when(() => prefs.get())
        .thenAnswer((_) async => NotificationPrefsModel.fromJson(null));
    when(() => prefs.set(any(), any())).thenAnswer((_) async {});
    await cubit.load();
    await cubit.toggle(NotificationPref.likes, false);
    expect(cubit.state.prefs![NotificationPref.likes], isFalse);
    verify(() => prefs.set(NotificationPref.likes, false)).called(1);
  });

  test('a failed save puts only that switch back and reports it', () async {
    when(() => prefs.get())
        .thenAnswer((_) async => NotificationPrefsModel.fromJson(null));
    when(() => prefs.set(any(), any())).thenThrow(const NetworkFailure());
    await cubit.load();
    await cubit.toggle(NotificationPref.likes, false);
    expect(cubit.state.prefs![NotificationPref.likes], isTrue);
    expect(cubit.state.failure, const NetworkFailure());
  });
}
