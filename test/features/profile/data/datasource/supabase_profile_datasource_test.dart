import 'dart:convert';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pulse/core/enums/auth_failure_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/profile/data/datasource/profile_datasource.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:pulse/features/profile/data/model/profile_update_model.dart';

import '../../../../helpers/backend_double.dart';

void main() {
  const uid = BackendDouble.uid;

  Failure? failureOf(Either<Failure, Object?> result) =>
      result.fold((f) => f, (_) => null);

  /// A signed-in client whose non-auth requests go to [handler].
  Future<BackendDouble> signedIn(
    Future<http.Response> Function(http.Request request) handler,
  ) async {
    final backend = BackendDouble((request) {
      if (request.url.path.endsWith('/token')) {
        return Future.value(BackendDouble.sessionResponse());
      }
      return handler(request);
    });
    await backend.signIn();
    return backend;
  }

  dynamic jsonBody(http.Request request) => jsonDecode(request.body);

  group('getProfile', () {
    test('reads the signed-in user\'s own row', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json({
          'id': uid,
          'username': 'dip',
          'full_name': 'Dip Roy',
          'birthday': '1999-02-03',
          'gender': 'male',
          'signup_step': 4,
        }),
      );
      final result = await SupabaseProfileDatasource(backend.client)
          .getProfile();

      final profile = result.getOrElse((_) => const ProfileModel());
      expect(profile.username, 'dip');
      expect(profile.birthday, DateTime.utc(1999, 2, 3));
      expect(profile.gender, Gender.male);
      expect(profile.signupStep, SignupStep.profile);
      final request = backend.to('/profiles').single;
      expect(request.method, 'GET');
      expect(request.url.queryParameters['id'], 'eq.$uid');
    });

    test('no row is NotFoundFailure', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.postgrestError(406, 'PGRST116'),
      );
      expect(
        failureOf(await SupabaseProfileDatasource(backend.client).getProfile()),
        const NotFoundFailure(),
      );
    });

    test('without a session it is sessionExpired and sends nothing', () async {
      final backend = BackendDouble((_) async => BackendDouble.json({}));
      final result = await SupabaseProfileDatasource(backend.client)
          .getProfile();
      expect(
        failureOf(result),
        const AuthFailure(AuthFailureReason.sessionExpired),
      );
      expect(backend.requests, isEmpty);
    });
  });

  group('isUsernameAvailable', () {
    test('asks the function and returns its answer', () async {
      final backend = await signedIn((_) async => BackendDouble.json(true));
      final repo = SupabaseProfileDatasource(backend.client);
      expect(
        await repo.isUsernameAvailable('dip'),
        const Right<Failure, bool>(true),
      );
      expect(jsonBody(backend.to('is_username_available').single), {
        'p_username': 'dip',
      });
    });

    test('a taken username is false', () async {
      final backend = await signedIn((_) async => BackendDouble.json(false));
      expect(
        await SupabaseProfileDatasource(backend.client)
            .isUsernameAvailable('dip'),
        const Right<Failure, bool>(false),
      );
    });
  });

  group('updateProfile', () {
    test('patches only the set columns of the user\'s own row', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json({
          'id': uid,
          'username': 'dip',
          'full_name': 'Dip Roy',
          'birthday': '2001-02-03',
          'signup_step': 4,
        }),
      );
      final result = await SupabaseProfileDatasource(backend.client)
          .updateProfile(
            ProfileUpdateModel(
              fullName: 'Dip Roy',
              username: 'dip',
              birthday: DateTime.utc(2001, 2, 3),
              signupStep: SignupStep.profile,
            ),
          );
      // It returns the row as the server now stores it, for the repository to save.
      expect(
        result.getOrElse((_) => const ProfileModel()),
        ProfileModel(
          id: uid,
          username: 'dip',
          fullName: 'Dip Roy',
          birthday: DateTime.utc(2001, 2, 3),
          signupStep: SignupStep.profile,
        ),
      );
      final request = backend.to('/profiles').single;
      expect(request.method, 'PATCH');
      expect(request.url.queryParameters['id'], 'eq.$uid');
      expect(request.headers['prefer'], contains('return=representation'));
      expect(jsonBody(request), {
        'full_name': 'Dip Roy',
        'username': 'dip',
        'birthday': '2001-02-03',
        'signup_step': 4,
      });
    });

    test('a taken username (unique violation) is ConflictFailure', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.postgrestError(409, '23505'),
      );
      final result = await SupabaseProfileDatasource(backend.client)
          .updateProfile(const ProfileUpdateModel(username: 'dip'));
      expect(failureOf(result), const ConflictFailure());
    });
  });

  group('avatar', () {
    test('uploads one file per user, upserting, and returns a versioned public URL', () async {
      final backend = await signedIn(
        (_) async => BackendDouble.json({'Key': 'avatars/$uid/avatar'}),
      );
      final repo = SupabaseProfileDatasource(backend.client);

      final result = await withClock(
        Clock.fixed(DateTime.utc(2026, 10, 8)),
        () => repo.uploadAvatar(
          Uint8List.fromList([1, 2, 3]),
          contentType: 'image/jpeg',
        ),
      );

      final request = backend.requests.single;
      expect(request.url.path, '/storage/v1/object/avatars/$uid/avatar');
      expect(request.headers['x-upsert'], 'true');
      expect(
        request.headers['content-type'],
        startsWith('multipart/form-data'),
      );
      expect(
        request.body,
        contains('image/jpeg'),
      ); // the part's own content type
      expect(
        result.getOrElse((_) => ''),
        'https://test.supabase.co/storage/v1/object/public/avatars/$uid/avatar'
        '?v=${DateTime.utc(2026, 10, 8).millisecondsSinceEpoch}',
      );
    });

    test('removing deletes the file and clears avatar_url', () async {
      final backend = await signedIn((request) async {
        if (request.url.path.contains('/storage/')) {
          return BackendDouble.json(<dynamic>[]);
        }
        return http.Response('', 204);
      });
      final result = await SupabaseProfileDatasource(backend.client)
          .removeAvatar();

      expect(result.isRight, isTrue);
      expect(jsonBody(backend.requests.first), {
        'prefixes': ['$uid/avatar'],
      });
      expect(backend.requests.first.method, 'DELETE');
      expect(jsonBody(backend.to('/profiles').single), {'avatar_url': null});
    });
  });

  group('wire values', () {
    test('gender values and the step number both ways', () async {
      final backend = await signedIn((request) async {
        if (request.method == 'GET') {
          return BackendDouble.json({
            'id': uid,
            'gender': 'prefer_not_to_say',
            'signup_step': 0,
          });
        }
        return BackendDouble.json({'id': uid});
      });
      final datasource = SupabaseProfileDatasource(backend.client);

      final profile = (await datasource.getProfile()).getOrElse(
        (_) => const ProfileModel(),
      );
      expect(profile.gender, Gender.preferNotToSay);
      expect(profile.signupStep, SignupStep.complete);

      await datasource.updateProfile(
        const ProfileUpdateModel(
          gender: Gender.female,
          signupStep: SignupStep.follow,
        ),
      );
      expect(jsonBody(backend.requests.last), {
        'gender': 'female',
        'signup_step': 6,
      });
    });

    test('an unknown gender or step is null, not a failure', () async {
      final backend = await signedIn(
        (_) async =>
            BackendDouble.json({'id': uid, 'gender': 'x', 'signup_step': 9}),
      );
      final profile = (await SupabaseProfileDatasource(
        backend.client,
      ).getProfile()).getOrElse((_) => const ProfileModel(id: 'failed'));
      expect(profile, const ProfileModel(id: uid));
    });
  });

  test(
    'currentUserId is the signed-in user, or null without a session',
    () async {
      final backend = await signedIn((_) async => BackendDouble.json({}));
      expect(SupabaseProfileDatasource(backend.client).currentUserId, uid);
      final signedOut = BackendDouble((_) async => BackendDouble.json({}));
      expect(SupabaseProfileDatasource(signedOut.client).currentUserId, isNull);
    },
  );
}
