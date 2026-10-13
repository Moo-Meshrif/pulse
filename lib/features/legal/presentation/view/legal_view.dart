import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/legal_document.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/failure_l10n.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/legal_cubit.dart';
import '../cubit/legal_state.dart';

/// A legal page's UI: the title bar (the backend's title once loaded), then loading, the error with
/// Retry, or the HTML (`AppHtml`).
class LegalView extends StatelessWidget {
  const LegalView({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) => AppPage(
    appBar: AppBar(
      title: BlocSelector<LegalCubit, LegalState, String?>(
        selector: (state) => state.document?.title,
        builder: (context, title) =>
            AppText(title ?? document.l10n(context), style: context.text.title),
      ),
    ),
    child: BlocBuilder<LegalCubit, LegalState>(
      builder: (context, state) {
        if (state.loading) return const AppLoadingView();
        final html = state.document?.html;
        if (state.failure != null || html == null || html.trim().isEmpty) {
          return _LoadError(
            failure: state.failure ?? const NotFoundFailure(),
            onRetry: context.read<LegalCubit>().retry,
          );
        }
        return AppHtml(
          html: html,
          onLinkTap: context.read<LegalCubit>().openLink,
        );
      },
    ),
  );
}

/// The failure's message with a Retry text button.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.formSide),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            failure.l10n(context),
            style: context.text.subtitle,
            color: context.appColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AuthDimens.tapTarget,
                AuthDimens.tapTarget,
              ),
              foregroundColor: context.appColors.primary,
            ),
            child: AppText(
              context.l10n.retry,
              style: context.text.name,
              color: context.appColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
