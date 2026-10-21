import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/services/connectivity_service.dart';
import 'package:pulse/features/profile/domain/entity/last_account_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';
import 'package:pulse/shared/content/data/enums/pending_content_state.dart';
import 'package:pulse/shared/content/data/repository/content_discard_repository.dart';
import 'package:pulse/shared/content/domain/entity/audience_summary_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_audience_summary_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/remove_media_files_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/report_content_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/resume_content_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_content_audience_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_mute_use_case.dart';

/// A [ContentDiscardRepository] that records what it is asked and answers [answer] (null: offline,
/// which marks the kind waiting until [setWaiting] clears it).
class FakeContentDiscards implements ContentDiscardRepository {
  PendingContentState? answer = PendingContentState.discarded;
  final saved = <String>[];
  final sent = <String>[];
  var sweeps = 0;
  final _waiting = <ContentKind>{};
  final _changes = StreamController<ContentKind>.broadcast();

  void setWaiting(ContentKind kind, {required bool isWaiting}) {
    isWaiting ? _waiting.add(kind) : _waiting.remove(kind);
    _changes.add(kind);
  }

  @override
  Future<void> save(String id, ContentKind kind) async => saved.add(id);

  @override
  Future<PendingContentState?> send(String id, ContentKind kind) async {
    sent.add(id);
    if (answer == null) setWaiting(kind, isWaiting: true);
    return answer;
  }

  @override
  Future<void> sendSaved() async => sweeps++;

  @override
  bool isWaiting(ContentKind kind) => _waiting.contains(kind);

  @override
  Stream<ContentKind> get changes => _changes.stream;

  @override
  void useAccount(String? userId) {}
}

/// A [ConnectivityService] whose connection never comes back unless the test calls [back].
class FakeConnectivity extends Mock implements ConnectivityService {
  final _hints = StreamController<void>.broadcast();

  void back() => _hints.add(null);

  @override
  Stream<void> get connectionHints => _hints.stream;
}

class MockResumeContent extends Mock implements ResumeContentUseCase {}

/// A [MockResumeContent] that does nothing.
MockResumeContent okResumeContent() {
  final mock = MockResumeContent();
  when(() => mock(any())).thenAnswer((_) async {});
  return mock;
}

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

/// No saved account: the posting ring shows an empty circle.
class FakeLastAccount extends Fake implements GetLastAccountUseCase {
  @override
  LastAccountEntity? call() => null;
}
