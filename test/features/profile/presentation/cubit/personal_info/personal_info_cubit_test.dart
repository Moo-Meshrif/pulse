import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/photo_source.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/photo_picker_service.dart';
import 'package:pulse/core/utils/location_choice.dart';
import 'package:pulse/features/profile/data/repository/profile_repository.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/entity/profile_update_entity.dart';
import 'package:pulse/features/profile/domain/event/profile_updated.dart';
import 'package:pulse/features/profile/presentation/cubit/personal_info/personal_info_cubit.dart';
import 'package:pulse/features/profile/presentation/utils/enums/username_status.dart';

class _MockProfiles extends Mock implements ProfileRepository {}

class _MockPhotos extends Mock implements PhotoPickerService {}

void main() {
  late _MockProfiles profiles;
  late _MockPhotos photos;
  late PersonalInfoCubit cubit;
  late EventBus bus;

  const profile = ProfileEntity(
    id: 'u1',
    username: 'sara',
    fullName: 'Sara Ali',
    bio: 'Hi',
    city: 'Cairo',
    avatarUrl: 'https://x/avatar',
  );
  final photo = PickedPhoto(bytes: Uint8List(3), contentType: 'image/jpeg');

  setUpAll(() {
    registerFallbackValue(const ProfileUpdateEntity());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() async {
    profiles = _MockProfiles();
    photos = _MockPhotos();
    when(() => profiles.getProfile()).thenAnswer((_) async => profile);
    when(() => profiles.email).thenReturn('sara@x.com');
    when(() => profiles.updateProfile(any())).thenAnswer((_) async => profile);
    bus = EventBus();
    cubit = PersonalInfoCubit(profiles, photos, bus);
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('load fills the form and nothing is dirty', () {
    expect(cubit.state.fullName, 'Sara Ali');
    expect(cubit.state.email, 'sara@x.com');
    expect(cubit.state.isDirty, isFalse);
    expect(cubit.state.canSave, isFalse);
  });

  test('a load failure is kept for the retry', () async {
    when(() => profiles.getProfile()).thenThrow(const NetworkFailure());
    await cubit.load();
    expect(cubit.state.loadFailure, const NetworkFailure());
  });

  test('editing a valid field turns Save on; an empty name turns it off', () {
    cubit.bioChanged('New bio');
    expect(cubit.state.canSave, isTrue);
    cubit.fullNameChanged('  ');
    expect(cubit.state.canSave, isFalse);
  });

  test('an invalid phone blocks Save', () {
    cubit.phoneChanged('+12');
    expect(cubit.state.isPhoneInvalid, isTrue);
    expect(cubit.state.canSave, isFalse);
  });

  test('a place choice sets the city and Remove clears it', () {
    cubit.locationChosen(const LocationChoice('Giza'));
    expect(cubit.state.city, 'Giza');
    cubit.locationChosen(const LocationChoice(null));
    expect(cubit.state.city, '');
    expect(cubit.state.isDirty, isTrue);
  });

  group('username', () {
    test('the own username needs no check', () {
      cubit.usernameChanged('Sara');
      expect(cubit.state.usernameStatus, UsernameStatus.idle);
      expect(cubit.state.usernameChanged, isFalse);
    });

    test('a taken username blocks Save', () async {
      when(() => profiles.isUsernameAvailable('sara_2'))
          .thenAnswer((_) async => false);
      cubit.usernameChanged('sara_2');
      expect(cubit.state.usernameStatus, UsernameStatus.checking);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(cubit.state.usernameStatus, UsernameStatus.taken);
      expect(cubit.state.canSave, isFalse);
    });

    test('a free username allows Save', () async {
      when(() => profiles.isUsernameAvailable('sara_2'))
          .thenAnswer((_) async => true);
      cubit.usernameChanged('sara_2');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(cubit.state.usernameStatus, UsernameStatus.free);
      expect(cubit.state.canSave, isTrue);
    });

    test('a bad format is not checked and blocks Save', () {
      cubit.usernameChanged('a!');
      expect(cubit.state.isUsernameFormatInvalid, isTrue);
      expect(cubit.state.usernameStatus, UsernameStatus.idle);
      verifyNever(() => profiles.isUsernameAvailable(any()));
      expect(cubit.state.canSave, isFalse);
    });
  });

  group('save', () {
    test('sends only the changed fields and marks saved', () async {
      cubit.bioChanged(' New bio ');
      await cubit.save();
      verify(
        () => profiles.updateProfile(const ProfileUpdateEntity(bio: 'New bio')),
      ).called(1);
      expect(cubit.state.saved, isTrue);
      expect(cubit.state.isSaving, isFalse);
    });

    test('tells the Profile tab once saved', () async {
      final heard = expectLater(
        bus.on<ProfileUpdated>(),
        emits(isA<ProfileUpdated>()),
      );
      cubit.bioChanged('New bio');
      await cubit.save();
      await heard;
    });

    test('uploads a new avatar then writes its url', () async {
      when(() => photos.pick(PhotoSource.gallery, crop: PhotoCrop.avatar))
          .thenAnswer((_) async => photo);
      when(
        () => profiles.uploadAvatar(
          any(),
          contentType: any(named: 'contentType'),
        ),
      ).thenAnswer((_) async => 'https://x/new');
      await cubit.pickAvatar(PhotoSource.gallery);
      await cubit.save();
      verify(
        () => profiles.updateProfile(
          const ProfileUpdateEntity(avatarUrl: 'https://x/new'),
        ),
      ).called(1);
    });

    test('removing a cover that was never set writes nothing', () async {
      cubit.removeCover();
      await cubit.save();
      verifyNever(() => profiles.removeCover());
      verifyNever(() => profiles.updateProfile(any()));
      expect(cubit.state.saved, isTrue);
    });

    test('removing the avatar deletes it', () async {
      when(() => profiles.removeAvatar()).thenAnswer((_) async {});
      cubit.removeAvatar();
      await cubit.save();
      verify(() => profiles.removeAvatar()).called(1);
    });

    test('a failure keeps the edits and reports it', () async {
      when(() => profiles.updateProfile(any()))
          .thenThrow(const NetworkFailure());
      cubit.bioChanged('x');
      await cubit.save();
      expect(cubit.state.failure, const NetworkFailure());
      expect(cubit.state.saved, isFalse);
      expect(cubit.state.bio, 'x');
      expect(cubit.state.canSave, isTrue);
    });

    test('a username conflict shows taken, not a notice', () async {
      when(() => profiles.isUsernameAvailable('sara_2'))
          .thenAnswer((_) async => true);
      when(() => profiles.updateProfile(any()))
          .thenThrow(const ConflictFailure());
      cubit.usernameChanged('sara_2');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await cubit.save();
      expect(cubit.state.usernameStatus, UsernameStatus.taken);
      expect(cubit.state.failure, isNull);
    });
  });
}
