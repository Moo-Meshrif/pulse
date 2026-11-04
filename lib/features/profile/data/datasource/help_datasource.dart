import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/guard.dart';
import '../model/help_article_model.dart';
import '../model/help_topic_model.dart';

abstract interface class HelpDatasource {
  Future<List<HelpTopicModel>> getTopics();
  Future<List<HelpArticleModel>> getCommonQuestions();
  Future<List<HelpArticleModel>> getTopicQuestions(int topicId);
}

@LazySingleton(as: HelpDatasource)
final class SupabaseHelpDatasource implements HelpDatasource {
  SupabaseHelpDatasource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<HelpTopicModel>> getTopics() => Guard.run(() async {
    final rows = await _client
        .from('help_topics')
        .select()
        .order('position', ascending: true);
    return rows.map(HelpTopicModel.fromJson).toList();
  });

  @override
  Future<List<HelpArticleModel>> getCommonQuestions() => Guard.run(() async {
    final rows = await _client
        .from('help_articles')
        .select()
        .eq('is_common', true)
        .order('position', ascending: true);
    return rows.map(HelpArticleModel.fromJson).toList();
  });

  @override
  Future<List<HelpArticleModel>> getTopicQuestions(int topicId) =>
      Guard.run(() async {
        final rows = await _client
            .from('help_articles')
            .select()
            .eq('topic_id', topicId)
            .order('position', ascending: true);
        return rows.map(HelpArticleModel.fromJson).toList();
      });
}
