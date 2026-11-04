import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/app_version_service.dart';
import 'package:pulse/features/auth/domain/use_case/sign_out_use_case.dart';
import 'package:pulse/features/auth/domain/use_case/verify_password_use_case.dart';
import 'package:pulse/features/profile/data/datasource/app_preferences_datasource.dart';
import 'package:pulse/features/profile/data/datasource/settings_datasource.dart';
import 'package:pulse/features/profile/data/model/settings_summary_model.dart';
import 'package:pulse/features/profile/domain/use_case/clear_local_profile_use_case.dart';
import 'package:pulse/features/profile/presentation/cubit/settings/settings_cubit.dart';

class _MockSettings extends Mock implements SettingsDatasource {}

class _MockPreferences extends Mock implements AppPreferencesDatasource {}

class _MockClear extends Mock implements ClearLocalProfileUseCase {}

class _MockSignOut extends Mock implements SignOutUseCase {}

class _MockVerify extends Mock implements VerifyPasswordUseCase {}

class _MockVersion extends Mock implements AppVersionService {}

void main() {
  late _MockSettings settings;
  late _MockPreferences preferences;
  late _MockClear clear;
  late _MockSignOut signOut;
  late _MockVerify verifyPassword;
  late _MockVersion version;
  late SettingsCubit cubit;

  const wrongPassword = AuthFailure(AuthFailureReason.invalidCredentials);

  setUp(() {
    settings = _MockSettings();
    preferences = _MockPreferences();
    clear = _MockClear();
    signOut = _MockSignOut();
    verifyPassword = _MockVerify();
    version = _MockVersion();
    when(() => preferences.autoplayShorts).thenReturn(true);
    when(() => preferences.dataSaver).thenReturn(false);
    when(() => preferences.setAutoplayShorts(any())).thenAnswer((_) async {});
    when(() => preferences.setDataSaver(any())).thenAnswer((_) async {});
    when(() => clear()).thenAnswer((_) async {});
    when(() => signOut()).thenAnswer((_) async {});
    when(() => settings.deleteAccount()).thenAnswer((_) async {});
    when(() => verifyPassword(any())).thenAnswer((_) async {});
    when(() => version.version()).thenAnswer((_) async => '1.2.0');
    cubit = SettingsCubit(
      settings,
      preferences,
      clear,
      signOut,
      verifyPassword,
      version,
    );
  });

  tearDown(() => cubit.close());

  test('starts with the switches saved on the phone', () {
    when(() => preferences.autoplayShorts).thenReturn(false);
    when(() => preferences.dataSaver).thenReturn(true);
    final saved = SettingsCubit(
      settings,
      preferences,
      clear,
      signOut,
      verifyPassword,
      version,
    );
    addTearDown(saved.close);

    expect(saved.state.autoplayShorts, isFalse);
    expect(saved.state.dataSaver, isTrue);
  });

  group('load', () {
    test('shows the summary and the version', () async {
      const summary = SettingsSummaryModel(
        isPrivate: true,
        blockedCount: 3,
        pushEnabled: false,
      );
      when(() => settings.getSummary()).thenAnswer((_) async => summary);

      await cubit.load();

      expect(cubit.state.summary, summary);
      expect(cubit.state.version, '1.2.0');
    });

    test('a failed summary leaves the rows without a value', () async {
      when(() => settings.getSummary()).thenThrow(const NetworkFailure());

      await cubit.load();

      expect(cubit.state.summary, isNull);
      expect(cubit.state.version, '1.2.0');
    });
  });

  test('a switch changes at once and is saved on the phone', () {
    cubit.setAutoplayShorts(false);
    cubit.setDataSaver(true);

    expect(cubit.state.autoplayShorts, isFalse);
    expect(cubit.state.dataSaver, isTrue);
    verify(() => preferences.setAutoplayShorts(false)).called(1);
    verify(() => preferences.setDataSaver(true)).called(1);
  });

  group('logOut', () {
    test('clears the saved profile, ends the session and signs out', () async {
      await cubit.logOut();

      expect(cubit.state.signedOut, isTrue);
      expect(cubit.state.isLoggingOut, isFalse);
      verifyInOrder([() => clear(), () => signOut()]);
    });

    test('a failure stays on Settings and reaches the screen', () async {
      when(() => signOut()).thenThrow(const NetworkFailure());

      await cubit.logOut();

      expect(cubit.state.signedOut, isFalse);
      expect(cubit.state.isLoggingOut, isFalse);
      expect(cubit.state.failure, const NetworkFailure());
    });
  });

  group('deleteAccount', () {
    test(
      'a wrong password shows under the field and deletes nothing',
      () async {
        when(() => verifyPassword('nope')).thenThrow(wrongPassword);

        await cubit.deleteAccount('nope');

        expect(cubit.state.passwordWrong, isTrue);
        expect(cubit.state.isDeleting, isFalse);
        expect(cubit.state.signedOut, isFalse);
        verifyNever(() => settings.deleteAccount());
      },
    );

    test('typing again clears the wrong password message', () async {
      when(() => verifyPassword('nope')).thenThrow(wrongPassword);
      await cubit.deleteAccount('nope');

      cubit.passwordEdited();

      expect(cubit.state.passwordWrong, isFalse);
    });

    test('a right password deletes, clears the phone and signs out', () async {
      await cubit.deleteAccount('secret');

      expect(cubit.state.signedOut, isTrue);
      expect(cubit.state.isDeleting, isFalse);
      verifyInOrder([
        () => verifyPassword('secret'),
        () => settings.deleteAccount(),
        () => clear(),
        () => signOut(),
      ]);
    });

    test('a clean-up that fails after the delete still leaves', () async {
      when(() => signOut()).thenThrow(const NetworkFailure());

      await cubit.deleteAccount('secret');

      expect(cubit.state.signedOut, isTrue);
      expect(cubit.state.failure, isNull);
    });

    test(
      'a server failure is reported, not shown as a wrong password',
      () async {
        when(() => settings.deleteAccount()).thenThrow(const ServerFailure());

        await cubit.deleteAccount('secret');

        expect(cubit.state.passwordWrong, isFalse);
        expect(cubit.state.signedOut, isFalse);
        expect(cubit.state.failure, const ServerFailure());
      },
    );

    test('an empty password does nothing', () async {
      await cubit.deleteAccount('');

      verifyNever(() => verifyPassword(any()));
    });
  });
}
