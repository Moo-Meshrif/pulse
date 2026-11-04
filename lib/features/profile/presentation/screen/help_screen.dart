import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/model/help_topic_model.dart';
import '../cubit/help/help_cubit.dart';
import '../cubit/help/help_state.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key, this.slug});
  final String? slug;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<HelpCubit>()..load(slug: slug),
    child: _HelpView(slug: slug),
  );
}

class _HelpView extends StatelessWidget {
  const _HelpView({this.slug});
  final String? slug;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    return BlocBuilder<HelpCubit, HelpState>(
      builder: (context, state) {
        final title = state.topic?.title(language) ?? l10n.helpTitle;
        final bottom = NavClearance.of(context) + AppSpacing.s32;
        return AppPage(
          title: title,
          backgroundColor: context.appColors.background,
          bottomSpace: bottom,
          child: state.loading
              ? const AppLoadingView()
              : state.failed
              ? AppEmpty.failed(
                  onRetry: () => context.read<HelpCubit>().load(slug: slug),
                )
              : slug != null && state.articles.isEmpty
              ? AppEmpty(
                  icon: AppAssets.help,
                  title: l10n.helpTopicEmpty,
                  message: '',
                )
              : CustomScrollView(
                  slivers: [
                    if (slug == null) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.s24,
                            AppSpacing.s24,
                            AppSpacing.s24,
                            AppSpacing.s8,
                          ),
                          child: AppText(
                            l10n.helpTopics.toUpperCase(),
                            style: context.text.section,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12,
                        ),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.textScalerOf(context).scale(1) >=
                                        1.5
                                    ? 1
                                    : 2,
                                mainAxisExtent:
                                    SettingsDimens.rowMinHeight +
                                    AppSpacing.s24,
                                mainAxisSpacing: AppSpacing.s8,
                                crossAxisSpacing: AppSpacing.s8,
                              ),
                          itemCount: state.topics.length,
                          itemBuilder: (context, index) => _TopicCard(
                            topic: state.topics[index],
                            language: language,
                          ),
                        ),
                      ),
                    ],
                    if (state.articles.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: AppSpacing.s24),
                          child: SettingsGroup(
                            label: slug == null ? l10n.commonQuestions : null,
                            children: [
                              FaqAccordion(
                                firstOpen: slug == null,
                                items: state.articles
                                    .map(
                                      (article) => FaqItem(
                                        question: article.question(language),
                                        answer: article.answer(language),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (slug == null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.s12),
                          child: Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: l10n.chatWithUs,
                                  onPressed: () {
                                    // TODO(profile-plan T7): chat support
                                    Notices.info(l10n.chatSoon);
                                  },
                                ),
                              ),
                              SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: PillButton.outline(
                                  label: l10n.reportTitle,
                                  onPressed: () => AppNavigator.push(
                                    context,
                                    AppRoutes.settingsReport,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: SizedBox(height: bottom)),
                  ],
                ),
        );
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.language});
  final HelpTopicModel topic;
  final String language;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final icon = switch (topic.icon) {
      'ic_lock' => AppAssets.lock,
      'ic_play' => AppAssets.play,
      'ic_chat_bubble' => AppAssets.chatBubble,
      _ => AppAssets.user,
    };
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: topic.slug == null
            ? null
            : () => AppNavigator.push(
                context,
                Uri(
                  path: AppRoutes.settingsHelpTopic,
                  queryParameters: {'slug': topic.slug!},
                ).toString(),
              ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s12),
          child: Row(
            children: [
              Container(
                width: SettingsDimens.tile,
                height: SettingsDimens.tile,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.settingsTile),
                ),
                child: Center(
                  child: AppSvgIcon(
                    icon,
                    size: SettingsDimens.tileIcon,
                    color: colors.primary,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: AppText(
                  topic.title(language),
                  style: context.text.name,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
