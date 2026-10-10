import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/profile/data/datasource/profile_local_datasource.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:pulse/features/profile/data/model/profile_update_model.dart';
import 'package:pulse/features/profile/data/repository/profile_repository.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/entity/profile_update_entity.dart';

import '../../../../helpers/pump_app.dart';

import '../../../../helpers/failure_of.dart';

class MockLocal extends Mock implements ProfileLocalDatasource {}

class FakeUpdate extends Fake implements ProfileUpdateModel {}

void main() {
  late MockProfileDatasource remote;
  late MockLocal local;
  late ProfileRepositoryImpl repository;

  const server = ProfileModel(
    id: 'u1',
    username: 'dip',
    signupStep: SignupStep.profile,
  );
  const saved = ProfileModel(
    id: 'u1',
    username: 'saved',
    signupStep: SignupStep.aboutYou,
  );

  /// What the repository must build from [model]: every field carried over.
  ProfileEntity entityOf(ProfileModel model) => ProfileEntity(
    id: model.id,
    username: model.username,
    fullName: model.fullName,
    birthday: model.birthday,
    gender: model.gender,
    bio: model.bio,
    city: model.city,
    phone: model.phone,
    avatarUrl: model.avatarUrl,
    signupStep: model.signupStep,
  );

  setUpAll(() {
    registerFallbackValue(server);
    registerFallbackValue(FakeUpdate());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    remote = MockProfileDatasource();
    local = MockLocal();
    repository = ProfileRepositoryImpl(remote, local);
    when(() => remote.currentUserId).thenReturn('u1');
    when(() => local.write(any())).thenAnswer((_) async {});
    when(() => local.clear(any())).thenAnswer((_) async {});
  });

  group('getProfile', () {
    test(
      'returns the server profile as an entity and saves it locally',
      () async {
        when(() => remote.getProfile()).thenAnswer((_) async => server);

        final result = await repository.getProfile();

        expect(result, entityOf(server));
        verify(() => local.write(server)).called(1);
      },
    );

    test('a lost connection falls back to the saved copy', () async {
      when(() => remote.getProfile()).thenThrow(const NetworkFailure());
      when(() => local.read('u1')).thenReturn(saved);

      expect(await repository.getProfile(), entityOf(saved));
    });

    test('a timeout falls back to the saved copy too', () async {
      when(() => remote.getProfile()).thenThrow(const TimeoutFailure());
      when(() => local.read('u1')).thenReturn(saved);

      expect(await repository.getProfile(), entityOf(saved));
    });

    test('offline with nothing saved is the connection failure', () async {
      when(() => remote.getProfile()).thenThrow(const NetworkFailure());
      when(() => local.read('u1')).thenReturn(null);

      expect(await failureOf(repository.getProfile()), const NetworkFailure());
    });

    test(
      'any other failure is returned as it is, never hidden by the copy',
      () async {
        when(() => remote.getProfile())
            .thenThrow(const AuthFailure(AuthFailureReason.sessionExpired));
        when(() => local.read('u1')).thenReturn(saved);

        expect(
          await failureOf(repository.getProfile()),
          const AuthFailure(AuthFailureReason.sessionExpired),
        );
        verifyNever(() => local.read(any()));
      },
    );

    test('offline without a session has no copy to use', () async {
      when(() => remote.getProfile()).thenThrow(const NetworkFailure());
      when(() => remote.currentUserId).thenReturn(null);

      expect(await failureOf(repository.getProfile()), const NetworkFailure());
      verifyNever(() => local.read(any()));
    });
  });

  group('updateProfile', () {
    test('writes to the server, saves what it returns locally, and returns the entity', () async {
      const stored = ProfileModel(
        id: 'u1',
        username: 'dip',
        bio: 'hi',
        signupStep: SignupStep.interests,
      );
      when(() => remote.updateProfile(any())).thenAnswer((_) async => stored);

      final result = await repository.updateProfile(
        const ProfileUpdateEntity(bio: 'hi', signupStep: SignupStep.interests),
      );

      expect(result, entityOf(stored));
      verify(
        () => remote.updateProfile(
          const ProfileUpdateModel(bio: 'hi', signupStep: SignupStep.interests),
        ),
      ).called(1);
      verify(() => local.write(stored)).called(1);
    });

    test('a failed write saves nothing locally', () async {
      when(() => remote.updateProfile(any()))
          .thenThrow(const ConflictFailure());

      expect(
        await failureOf(
          repository.updateProfile(
            const ProfileUpdateEntity(username: 'taken'),
          ),
        ),
        const ConflictFailure(),
      );
      verifyNever(() => local.write(any()));
    });
  });

  group('removeAvatar', () {
    test(
      'clears the picture in the saved copy after the server removed it',
      () async {
        when(() => remote.removeAvatar()).thenAnswer((_) async {});
        when(() => local.read('u1')).thenReturn(
          const ProfileModel(
            id: 'u1',
            username: 'dip',
            avatarUrl: 'https://x/y',
          ),
        );

        await repository.removeAvatar();

        final written =
            verify(() => local.write(captureAny())).captured.single
                as ProfileModel;
        expect(written.avatarUrl, isNull);
        expect(written.username, 'dip');
      },
    );

    test('a failed removal leaves the saved copy alone', () async {
      when(() => remote.removeAvatar()).thenThrow(const NetworkFailure());

      expect(
        await failureOf(repository.removeAvatar()),
        const NetworkFailure(),
      );
      verifyNever(() => local.write(any()));
    });

    test('with no saved copy there is nothing to update', () async {
      when(() => remote.removeAvatar()).thenAnswer((_) async {});
      when(() => local.read('u1')).thenReturn(null);

      await repository.removeAvatar();
      verifyNever(() => local.write(any()));
    });
  });

  test('uploading and the username check go straight to the server', () async {
    when(
      () => remote.uploadAvatar(any(), contentType: any(named: 'contentType')),
    ).thenAnswer((_) async => 'https://x/avatar?v=1');
    when(() => remote.isUsernameAvailable('dip')).thenAnswer((_) async => true);

    expect(
      await repository.uploadAvatar(Uint8List(1), contentType: 'image/jpeg'),
      'https://x/avatar?v=1',
    );
    expect(await repository.isUsernameAvailable('dip'), true);
    verifyNever(() => local.write(any()));
  });

  group('clearLocalProfile', () {
    test('forgets the signed-in user\'s copy', () async {
      await repository.clearLocalProfile();
      verify(() => local.clear('u1')).called(1);
    });

    test('without a session there is nothing to forget', () async {
      when(() => remote.currentUserId).thenReturn(null);
      await repository.clearLocalProfile();
      verifyNever(() => local.clear(any()));
    });
  });

  group('mapping', () {
    test('a profile carries every field into the entity', () async {
      final full = ProfileModel(
        id: 'u1',
        username: 'dip',
        fullName: 'Dip Roy',
        birthday: DateTime.utc(1999, 2, 3),
        gender: Gender.male,
        bio: 'hi',
        city: 'Cairo',
        phone: '+201234567',
        avatarUrl: 'https://x/y',
        signupStep: SignupStep.profile,
      );
      when(() => remote.getProfile()).thenAnswer((_) async => full);

      final result = await repository.getProfile();

      expect(
        result,
        ProfileEntity(
          id: 'u1',
          username: 'dip',
          fullName: 'Dip Roy',
          birthday: DateTime.utc(1999, 2, 3),
          gender: Gender.male,
          bio: 'hi',
          city: 'Cairo',
          phone: '+201234567',
          avatarUrl: 'https://x/y',
          signupStep: SignupStep.profile,
        ),
      );
    });

    test(
      'an update entity is sent to the server as the matching update model',
      () async {
        when(() => remote.updateProfile(any())).thenAnswer((_) async => server);

        await repository.updateProfile(
          const ProfileUpdateEntity(
            bio: 'a',
            gender: Gender.female,
            signupStep: SignupStep.follow,
          ),
        );

        verify(
          () => remote.updateProfile(
            const ProfileUpdateModel(
              bio: 'a',
              gender: Gender.female,
              signupStep: SignupStep.follow,
            ),
          ),
        ).called(1);
      },
    );
  });
}
