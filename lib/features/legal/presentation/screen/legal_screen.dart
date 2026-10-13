import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/enums/legal_document.dart';
import '../cubit/legal_cubit.dart';
import '../view/legal_view.dart';

/// `/terms` and `/privacy`: a legal page whose HTML comes from the backend (docs/specs/auth/open-questions.md, Q45).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<LegalCubit>()
          ..load(document.wire, Localizations.localeOf(context).languageCode),
    child: LegalView(document: document),
  );
}
