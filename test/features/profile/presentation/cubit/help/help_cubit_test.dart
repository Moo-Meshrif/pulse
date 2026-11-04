import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/profile/data/datasource/help_datasource.dart';
import 'package:pulse/features/profile/data/model/help_article_model.dart';
import 'package:pulse/features/profile/data/model/help_topic_model.dart';
import 'package:pulse/features/profile/presentation/cubit/help/help_cubit.dart';

class _Help extends Mock implements HelpDatasource {}

void main() {
  late _Help datasource;
  late HelpCubit cubit;
  const topic = HelpTopicModel(id: 1, slug: 'account');
  const article = HelpArticleModel(id: 1);
  setUp(() {
    datasource = _Help();
    cubit = HelpCubit(datasource);
  });
  tearDown(() => cubit.close());

  test('loads topics and common articles', () async {
    when(() => datasource.getTopics()).thenAnswer((_) async => [topic]);
    when(() => datasource.getCommonQuestions())
        .thenAnswer((_) async => [article]);
    await cubit.load();
    expect(cubit.state.topics, [topic]);
    expect(cubit.state.articles, [article]);
    expect(cubit.state.loading, false);
  });

  test('opens the questions for a topic', () async {
    when(() => datasource.getTopics()).thenAnswer((_) async => [topic]);
    when(() => datasource.getTopicQuestions(1))
        .thenAnswer((_) async => [article]);
    await cubit.load(slug: 'account');
    expect(cubit.state.topic, topic);
    expect(cubit.state.articles, [article]);
  });

  test('failure offers retry', () async {
    when(() => datasource.getTopics()).thenThrow(const NetworkFailure());
    when(() => datasource.getCommonQuestions()).thenAnswer((_) async => []);
    await cubit.load();
    expect(cubit.state.failed, true);
    expect(cubit.state.loading, false);
  });
}
