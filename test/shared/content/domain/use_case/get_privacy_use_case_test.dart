import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/shared/content/data/datasource/privacy_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/model/privacy_model.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';

class _MockPrivacy extends Mock implements PrivacyDatasource {}

void main() {
  late _MockPrivacy privacy;
  late GetPrivacyUseCase useCase;

  setUp(() {
    privacy = _MockPrivacy();
    useCase = GetPrivacyUseCase(privacy);
  });

  void answer(PrivacyModel model) =>
      when(() => privacy.getPrivacy()).thenAnswer((_) async => model);

  test('a new account starts Public', () async {
    answer(const PrivacyModel());

    final result = await useCase();

    expect(result.isPrivate, isFalse);
    expect(result.defaultVisibility, ContentAudience.public);
  });

  test('uses the saved default', () async {
    answer(
      const PrivacyModel(
        isPrivate: false,
        defaultAudience: ContentAudience.onlyMe,
      ),
    );

    expect((await useCase()).defaultVisibility, ContentAudience.onlyMe);
  });

  test('a private account never starts Public', () async {
    answer(
      const PrivacyModel(
        isPrivate: true,
        defaultAudience: ContentAudience.public,
      ),
    );

    final result = await useCase();

    expect(result.isPrivate, isTrue);
    expect(result.defaultVisibility, ContentAudience.followers);
  });

  test('a private account keeps a narrower saved default', () async {
    answer(
      const PrivacyModel(
        isPrivate: true,
        defaultAudience: ContentAudience.closeFriends,
      ),
    );

    expect((await useCase()).defaultVisibility, ContentAudience.closeFriends);
  });
}
