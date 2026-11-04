import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../data/datasource/help_datasource.dart';
import '../../../data/model/help_topic_model.dart';
import 'help_state.dart';

@injectable
class HelpCubit extends BaseCubit<HelpState> {
  HelpCubit(this._datasource) : super(const HelpState());
  final HelpDatasource _datasource;
  bool _loading = false;

  Future<void> load({String? slug}) async {
    if (_loading) return;
    _loading = true;
    await run(
      () async {
        if (slug == null) {
          final (topics, articles) = await (
            _datasource.getTopics(),
            _datasource.getCommonQuestions(),
          ).wait;
          return HelpState(loading: false, topics: topics, articles: articles);
        }
        final topics = await _datasource.getTopics();
        HelpTopicModel? topic;
        for (final item in topics) {
          if (item.slug == slug) {
            topic = item;
            break;
          }
        }
        if (topic?.id == null) {
          return const HelpState(loading: false, failed: true);
        }
        final articles = await _datasource.getTopicQuestions(topic!.id!);
        return HelpState(loading: false, topic: topic, articles: articles);
      },
      loading: const HelpState(),
      onSuccess: (value) => value,
      onFailure: (_) => const HelpState(loading: false, failed: true),
    );
    _loading = false;
  }
}
