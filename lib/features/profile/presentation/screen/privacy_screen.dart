import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/notice_context.dart';
import '../cubit/privacy/privacy_cubit.dart';
import '../cubit/privacy/privacy_state.dart';
import '../view/privacy_view.dart';

/// `/settings/privacy` (docs/specs/profile/screens/s5-privacy.md): provides the cubit and shows a failed
/// save once.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<PrivacyCubit>()..load(),
    child: BlocListener<PrivacyCubit, PrivacyState>(
      listenWhen: (before, now) =>
          now.failure != null && now.failure != before.failure,
      listener: (context, state) => context.showFailure(state.failure),
      child: const PrivacyView(),
    ),
  );
}
