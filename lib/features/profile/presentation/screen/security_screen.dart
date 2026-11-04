import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/notice/notices.dart';
import '../cubit/security/security_cubit.dart';
import '../cubit/security/security_state.dart';
import '../utils/enums/security_notice.dart';
import '../view/security_view.dart';

/// `/settings/security` (docs/specs/profile/screens/s4-password-security.md): provides the cubit and shows
/// its notices and failures once.
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<SecurityCubit>()..load(),
    child: BlocListener<SecurityCubit, SecurityState>(
      listenWhen: (before, now) =>
          (now.notice != null && now.notice != before.notice) ||
          (now.failure != null && now.failure != before.failure),
      listener: (context, state) {
        final l10n = context.l10n;
        switch (state.notice) {
          case SecurityNotice.passwordUpdated:
            Notices.success(l10n.securityPasswordUpdated);
          case SecurityNotice.resetEmailSent:
            Notices.success(l10n.securityResetSent);
          case SecurityNotice.othersLoggedOut:
            Notices.success(l10n.securityOthersLoggedOut);
          case null:
            context.showFailure(state.failure);
        }
      },
      child: const SecurityView(),
    ),
  );
}
