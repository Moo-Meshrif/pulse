import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/shared/content/data/datasource/audience_datasource.dart';
import 'package:pulse/shared/content/data/model/audience_summary_model.dart';
import 'package:pulse/shared/content/domain/entity/audience_summary_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_audience_summary_use_case.dart';

class _Audience extends Mock implements AudienceDatasource {}

void main() {
  late _Audience audience;
  late GetAudienceSummaryUseCase useCase;

  setUp(() {
    audience = _Audience();
    useCase = GetAudienceSummaryUseCase(audience);
  });

  test('returns the follower, close-friends and hidden counts', () async {
    when(() => audience.getSummary()).thenAnswer(
      (_) async => const AudienceSummaryModel(
        followers: 120,
        closeFriends: 12,
        hidden: 3,
      ),
    );

    expect(
      await useCase(),
      const AudienceSummaryEntity(followers: 120, closeFriends: 12, hidden: 3),
    );
  });

  test('missing numbers count as zero', () async {
    when(() => audience.getSummary())
        .thenAnswer((_) async => const AudienceSummaryModel());

    expect(await useCase(), const AudienceSummaryEntity());
  });
}
