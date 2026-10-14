import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';
import 'package:pulse/shared/content/domain/entity/audience_summary_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_audience_summary_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/remove_media_files_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/report_content_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_content_audience_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_mute_use_case.dart';

class MockSetMute extends Mock implements SetMuteUseCase {}

class MockReportContent extends Mock implements ReportContentUseCase {}

class MockGetAudienceSummary extends Mock
    implements GetAudienceSummaryUseCase {}

class MockRemoveMediaFiles extends Mock implements RemoveMediaFilesUseCase {}

class MockSetContentAudience extends Mock
    implements SetContentAudienceUseCase {}

/// Fallback values the mocks above need for `any()`; call once in `setUpAll`.
void registerContentFallbacks() {
  registerFallbackValue(ContentKind.story);
  registerFallbackValue(ContentAudience.followers);
  registerFallbackValue(MuteScope.stories);
  registerFallbackValue(ReportReason.spam);
}

/// A [MockSetMute] that succeeds until a test stubs it.
MockSetMute okSetMute() {
  registerContentFallbacks();
  final mock = MockSetMute();
  when(
    () => mock(
      any(),
      muted: any(named: 'muted'),
      scope: any(named: 'scope'),
    ),
  ).thenAnswer((_) async {});
  return mock;
}

MockReportContent okReportContent() {
  registerContentFallbacks();
  final mock = MockReportContent();
  when(() => mock(any(), any(), any(), note: any(named: 'note')))
      .thenAnswer((_) async {});
  return mock;
}

MockRemoveMediaFiles okRemoveMediaFiles() {
  registerContentFallbacks();
  final mock = MockRemoveMediaFiles();
  when(() => mock(any())).thenAnswer((_) async {});
  return mock;
}

MockSetContentAudience okSetContentAudience() {
  registerContentFallbacks();
  final mock = MockSetContentAudience();
  when(() => mock(any(), any(), any())).thenAnswer((_) async {});
  return mock;
}

MockGetAudienceSummary okGetAudienceSummary([
  AudienceSummaryEntity summary = const AudienceSummaryEntity(
    followers: 312,
    closeFriends: 12,
    hidden: 1,
  ),
]) {
  final mock = MockGetAudienceSummary();
  when(() => mock()).thenAnswer((_) async => summary);
  return mock;
}
