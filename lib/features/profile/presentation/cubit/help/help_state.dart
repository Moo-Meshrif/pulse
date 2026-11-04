import '../../../../../core/utils/equatable.dart';
import '../../../data/model/help_article_model.dart';
import '../../../data/model/help_topic_model.dart';

class HelpState extends Equatable {
  const HelpState({
    this.loading = true,
    this.failed = false,
    this.topics = const [],
    this.articles = const [],
    this.topic,
  });
  final bool loading;
  final bool failed;
  final List<HelpTopicModel> topics;
  final List<HelpArticleModel> articles;
  final HelpTopicModel? topic;
  @override
  List<Object?> get props => [loading, failed, topics, articles, topic];
}
