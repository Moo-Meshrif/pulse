import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/device_name_service.dart';
import 'package:pulse/features/auth/domain/use_case/change_password_use_case.dart';
import 'package:pulse/features/auth/domain/use_case/send_own_password_reset_use_case.dart';
import 'package:pulse/features/auth/domain/use_case/sign_out_others_use_case.dart';
import 'package:pulse/features/profile/presentation/cubit/security/security_cubit.dart';
import 'package:pulse/features/profile/presentation/utils/enums/security_notice.dart';

class _MockChange extends Mock implements ChangePasswordUseCase {}

class _MockReset extends Mock implements SendOwnPasswordResetUseCase {}

class _MockOthers extends Mock implements SignOutOthersUseCase {}

class _MockDevice extends Mock implements DeviceNameService {}

void main() {
  late _MockChange change;
  late _MockReset reset;
  late _MockOthers others;
  late _MockDevice device;
  late SecurityCubit cubit;

  setUp(() {
    change = _MockChange();
    reset = _MockReset();
    others = _MockOthers();
    device = _MockDevice();
    cubit = SecurityCubit(change, reset, others, device);
  });

  tearDown(() => cubit.close());

  void fill({String current = 'old', String next = 'Newpass1'}) {
    cubit
      ..currentChanged(current)
      ..nextChanged(next)
      ..confirmChanged(next);
  }

  test('Update needs the current password, a valid new one and a match', () {
    expect(cubit.state.canUpdate, isFalse);
    fill(next: 'short');
    expect(cubit.state.canUpdate, isFalse);
    fill();
    expect(cubit.state.canUpdate, isTrue);
    cubit.confirmChanged('Other123');
    expect(cubit.state.mismatch, isTrue);
    expect(cubit.state.canUpdate, isFalse);
  });

  test('a valid change tells the user and clears the fields', () async {
    when(() => change(current: 'old', next: 'Newpass1'))
        .thenAnswer((_) async {});
    fill();
    await cubit.update();
    expect(cubit.state.notice, SecurityNotice.passwordUpdated);
    expect(cubit.state.current, isEmpty);
    expect(cubit.state.next, isEmpty);
    expect(cubit.state.confirm, isEmpty);
    expect(cubit.state.isUpdating, isFalse);
  });

  test('a wrong current password is shown under its field', () async {
    when(() => change(current: any(named: 'current'), next: any(named: 'next')))
        .thenThrow(const AuthFailure(AuthFailureReason.invalidCredentials));
    fill();
    await cubit.update();
    expect(cubit.state.currentWrong, isTrue);
    expect(cubit.state.failure, isNull);
    expect(cubit.state.next, 'Newpass1');
    cubit.currentChanged('x');
    expect(cubit.state.currentWrong, isFalse);
  });

  test('another failure is reported and keeps the fields', () async {
    when(() => change(current: any(named: 'current'), next: any(named: 'next')))
        .thenThrow(const NetworkFailure());
    fill();
    await cubit.update();
    expect(cubit.state.failure, const NetworkFailure());
    expect(cubit.state.current, 'old');
  });

  test('log out of other devices', () async {
    when(() => others()).thenAnswer((_) async {});
    await cubit.logOutOthers();
    expect(cubit.state.notice, SecurityNotice.othersLoggedOut);
    expect(cubit.state.isLoggingOutOthers, isFalse);
  });

  test('forgot password emails the reset link', () async {
    when(() => reset()).thenAnswer((_) async {});
    await cubit.sendReset();
    expect(cubit.state.notice, SecurityNotice.resetEmailSent);
  });
}
