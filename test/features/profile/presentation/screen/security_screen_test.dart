import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/notice/notice.dart';
import 'package:pulse/core/notice/notices.dart';
import 'package:pulse/core/services/device_name_service.dart';
import 'package:pulse/core/widgets/app_dialog_shell.dart';
import 'package:pulse/core/widgets/loading_overlay/pulse_line_loader.dart';
import 'package:pulse/features/auth/domain/use_case/change_password_use_case.dart';
import 'package:pulse/features/auth/domain/use_case/send_own_password_reset_use_case.dart';
import 'package:pulse/features/auth/domain/use_case/sign_out_others_use_case.dart';
import 'package:pulse/features/profile/presentation/cubit/security/security_cubit.dart';
import 'package:pulse/features/profile/presentation/screen/security_screen.dart';

import '../../../../helpers/pump_app.dart';

class _MockChange extends Mock implements ChangePasswordUseCase {}

class _MockReset extends Mock implements SendOwnPasswordResetUseCase {}

class _MockOthers extends Mock implements SignOutOthersUseCase {}

class _MockDevice extends Mock implements DeviceNameService {}

void main() {
  late _MockReset reset;

  setUpAll(() async {
    final font = FontLoader('NotoSans')
      ..addFont(rootBundle.load('assets/fonts/NotoSans-Bold.ttf'));
    await font.load();
  });

  setUp(() async {
    Notices.clear();
    await getIt.reset();
    reset = _MockReset();
    final device = _MockDevice();
    when(device.name).thenAnswer((_) async => 'Phone');
    getIt.registerFactory<SecurityCubit>(
      () => SecurityCubit(_MockChange(), reset, _MockOthers(), device),
    );
  });

  tearDown(() async {
    Notices.clear();
    await getIt.reset();
  });

  testWidgets('forgot password shows inline progress then a success notice', (
    tester,
  ) async {
    setUpView(tester);
    final pending = Completer<void>();
    when(reset.call).thenAnswer((_) => pending.future);
    await tester.pumpApp(const SecurityScreen());

    await tester.tap(find.text(l10nEn.forgotPassword));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AppDialogShell), findsNothing);
    expect(find.byType(PulseLineLoader), findsOneWidget);
    expect(find.text(l10nEn.securityResetSent), findsNothing);
    final forgotButton = tester.widget<TextButton>(
      find.ancestor(
        of: find.byType(PulseLineLoader),
        matching: find.byType(TextButton),
      ),
    );
    expect(forgotButton.onPressed, isNull);
    verify(reset.call).called(1);

    pending.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(Notices.current.value?.kind, NoticeKind.success);
    expect(Notices.current.value?.title, l10nEn.securityResetSent);
    expect(find.byType(AppDialogShell), findsNothing);
    expect(find.byType(PulseLineLoader), findsNothing);
  });

  testWidgets('forgot password displays failure in a notice', (tester) async {
    setUpView(tester);
    final pending = Completer<void>();
    when(reset.call).thenAnswer((_) => pending.future);
    await tester.pumpApp(const SecurityScreen());

    await tester.tap(find.text(l10nEn.forgotPassword));
    await tester.pump(const Duration(milliseconds: 300));
    pending.completeError(const NetworkFailure());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AppDialogShell), findsNothing);
    expect(Notices.current.value?.kind, NoticeKind.error);
    expect(Notices.current.value?.title, l10nEn.errorNetwork);
    expect(find.byType(PulseLineLoader), findsNothing);
  });
}
