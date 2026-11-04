import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/failure_l10n.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/services/photo_picker_service.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/enums/problem_category.dart';
import '../cubit/report/report_cubit.dart';
import '../cubit/report/report_state.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ReportCubit>(),
    child: BlocListener<ReportCubit, ReportState>(
      listenWhen: (previous, current) =>
          current.sent != previous.sent ||
          (current.failure != null && current.failure != previous.failure),
      listener: (context, state) {
        if (state.sent) {
          Notices.success(context.l10n.reportThanks);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) AppNavigator.back(context);
          });
        } else if (state.failure != null) {
          final cubit = context.read<ReportCubit>();
          Notices.error(
            state.failure!.l10n(context),
            actionLabel: context.l10n.retry,
            onResult: (retry) {
              if (retry && !cubit.isClosed) cubit.send();
            },
          );
        }
      },
      child: const _ReportView(),
    ),
  );
}

class _ReportView extends StatefulWidget {
  const _ReportView();
  @override
  State<_ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<_ReportView> {
  final _controller = TextEditingController();
  bool _messageTouched = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    final cubit = context.read<ReportCubit>();
    if (cubit.state.sending) return;
    if (cubit.state.message.isEmpty) {
      AppNavigator.back(context);
      return;
    }
    final l10n = context.l10n;
    final discard = await ConfirmationDialog.destructive(
      context,
      icon: AppAssets.trash,
      title: l10n.editPostDiscardTitle,
      message: l10n.reportDiscardBody,
      confirmLabel: l10n.newPostDiscard,
      cancelLabel: l10n.keepEditing,
    );
    if (discard == true && mounted) AppNavigator.back(context);
  }

  Future<void> _addPhoto() async {
    final cubit = context.read<ReportCubit>();
    final photos = await getIt<PhotoPickerService>().pickMany(
      limit: 3 - cubit.state.photos.length,
    );
    if (!mounted || photos.isEmpty) return;
    final valid = photos
        .where((photo) => photo.bytes.length <= 5 * 1024 * 1024)
        .toList();
    if (valid.length != photos.length) {
      Notices.error(context.l10n.reportImageTooLarge);
    }
    cubit.addPhotos(valid);
  }

  String _categoryLabel(ProblemCategory category) => switch (category) {
    ProblemCategory.feed => context.l10n.reportCatFeed,
    ProblemCategory.shorts => context.l10n.reportCatShorts,
    ProblemCategory.chat => context.l10n.reportCatChat,
    ProblemCategory.profile => context.l10n.reportCatProfile,
    ProblemCategory.signingIn => context.l10n.reportCatSigningIn,
    ProblemCategory.other => context.l10n.reportReasonOther,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ReportCubit>();
    final colors = context.appColors;
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) => PopScope(
        canPop: !state.sending && (state.sent || state.message.isEmpty),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _close();
        },
        child: AppPage(
          title: l10n.reportTitle,
          onBack: _close,
          backgroundColor: colors.background,
          bottomSpace: NavClearance.of(context) + AppSpacing.s12,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.s24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.reportWhatsWrong,
                        style: context.text.name,
                        color: colors.textPrimary,
                      ),
                      SizedBox(height: AppSpacing.s8),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: ProblemCategory.values
                            .map(
                              (category) => SelectableChip(
                                label: _categoryLabel(category),
                                selected: state.category == category,
                                dark: true,
                                height: AppScale.scale(40),
                                onTap: () => cubit.categoryChanged(category),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: AppSpacing.s24),
                      AppTextField(
                        label: l10n.reportTellMore,
                        hint: l10n.reportHint,
                        controller: _controller,
                        counterMax: 500,
                        minLines: 5,
                        maxLines: 7,
                        enabled: !state.sending,
                        errorText: _messageTouched && !state.isMessageValid
                            ? l10n.reportMessageTooShort
                            : null,
                        onChanged: (message) {
                          if (!_messageTouched) {
                            setState(() => _messageTouched = true);
                          }
                          cubit.messageChanged(message);
                        },
                      ),
                      SizedBox(height: AppSpacing.s24),
                      AppText(
                        '${l10n.reportScreenshots} ${l10n.genderOptional}',
                        style: context.text.name,
                        color: colors.textPrimary,
                      ),
                      SizedBox(height: AppSpacing.s12),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          for (var i = 0; i < state.photos.length; i++)
                            _Screenshot(
                              photo: state.photos[i],
                              onRemove: state.sending
                                  ? null
                                  : () => cubit.removePhoto(i),
                              uploaded: state.sending && i < state.completed,
                              uploading: state.sending && i == state.completed,
                            ),
                          if (state.photos.length < 3)
                            SizedBox(
                              width: AppScale.scale(84),
                              height: AppScale.scale(84),
                              child: CustomPaint(
                                foregroundPainter: DashedRoundedRectPainter(
                                  color: colors.dashed,
                                  radius: AppRadius.input,
                                  width: AvatarDimens.dashedWidth,
                                ),
                                child: TextButton(
                                  onPressed: state.sending ? null : _addPhoto,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add),
                                      AppText(
                                        l10n.reportAdd,
                                        style: context.text.caption,
                                        color: colors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.s16),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: state.includeLogs,
                        onChanged: state.sending
                            ? null
                            : (value) => cubit.logsChanged(value ?? false),
                        title: AppText(
                          l10n.reportIncludeLogs,
                          style: context.text.bodySm,
                          color: colors.textPrimary,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s8,
                  AppSpacing.s24,
                  NavClearance.of(context) + AppSpacing.s12,
                ),
                child: PrimaryButton(
                  label: l10n.reportSend,
                  expand: true,
                  loading: state.sending,
                  onPressed: state.canSend ? cubit.send : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Screenshot extends StatelessWidget {
  const _Screenshot({
    required this.photo,
    required this.onRemove,
    required this.uploaded,
    required this.uploading,
  });
  final PickedPhoto photo;
  final VoidCallback? onRemove;
  final bool uploaded;
  final bool uploading;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: AppScale.scale(84),
    height: AppScale.scale(84),
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: Image.memory(photo.bytes, fit: BoxFit.cover),
        ),
        if (uploaded) const Center(child: Icon(Icons.check_circle)),
        if (uploading) const AppInlineLoading.refresh(),
        PositionedDirectional(
          top: 0,
          end: 0,
          child: IconButton(
            tooltip: context.l10n.reportRemoveScreenshot,
            onPressed: onRemove,
            icon: Container(
              width: AppSpacing.s24,
              height: AppSpacing.s24,
              decoration: BoxDecoration(
                color: context.appColors.mediaChip,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppSvgIcon(
                AppAssets.close,
                size: AppSpacing.s16,
                color: context.appColors.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
