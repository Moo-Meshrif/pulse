import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/profile/data/datasource/blocks_datasource.dart';
import 'package:pulse/features/profile/data/datasource/privacy_settings_datasource.dart';
import 'package:pulse/features/profile/data/enums/comment_audience.dart';
import 'package:pulse/features/profile/data/enums/message_audience.dart';
import 'package:pulse/features/profile/data/model/privacy_settings_model.dart';
import 'package:pulse/features/profile/presentation/cubit/privacy/privacy_cubit.dart';

class _MockPrivacy extends Mock implements PrivacySettingsDatasource {}

class _MockBlocks extends Mock implements BlocksDatasource {}

void main() {
  late _MockPrivacy privacy;
  late _MockBlocks blocks;
  late PrivacyCubit cubit;

  setUpAll(() {
    registerFallbackValue(MessageAudience.everyone);
    registerFallbackValue(CommentAudience.everyone);
  });

  setUp(() {
    privacy = _MockPrivacy();
    blocks = _MockBlocks();
    cubit = PrivacyCubit(privacy, blocks);
    when(() => privacy.get())
        .thenAnswer((_) async => const PrivacySettingsModel());
    when(() => blocks.count()).thenAnswer((_) async => 3);
  });

  tearDown(() => cubit.close());

  test('load reads the choices and the blocked count', () async {
    await cubit.load();
    expect(cubit.state.settings, const PrivacySettingsModel());
    expect(cubit.state.blockedCount, 3);
  });

  test('a failed load offers a retry', () async {
    when(() => privacy.get()).thenThrow(const NetworkFailure());
    await cubit.load();
    expect(cubit.state.loadFailed, isTrue);
    expect(cubit.state.settings, isNull);
  });

  test('a choice shows at once and is saved', () async {
    when(() => privacy.setWhoCanComment(any())).thenAnswer((_) async {});
    await cubit.load();
    await cubit.setWhoCanComment(CommentAudience.followers);
    expect(cubit.state.settings!.whoCanComment, CommentAudience.followers);
    verify(() => privacy.setWhoCanComment(CommentAudience.followers)).called(1);
  });

  test('a failed save puts only that choice back and reports it', () async {
    when(() => privacy.setPrivate(any())).thenThrow(const NetworkFailure());
    await cubit.load();
    await cubit.setPrivate(true);
    expect(cubit.state.settings!.isPrivate, isFalse);
    expect(cubit.state.failure, const NetworkFailure());
  });

  test('the same value is not saved again', () async {
    await cubit.load();
    await cubit.setShowActivity(true);
    verifyNever(() => privacy.setShowActivity(any()));
  });
}
