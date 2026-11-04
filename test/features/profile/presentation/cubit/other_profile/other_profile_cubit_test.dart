import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/profile/data/datasource/blocks_datasource.dart';
import 'package:pulse/features/profile/data/datasource/mutual_preview_datasource.dart';
import 'package:pulse/features/profile/data/datasource/profile_page_datasource.dart';
import 'package:pulse/features/profile/data/model/profile_page_model.dart';
import 'package:pulse/features/profile/presentation/cubit/other_profile/other_profile_cubit.dart';

class _Pages extends Mock implements ProfilePageDatasource {}

class _Toggle extends Mock implements ToggleFollowUseCase {}

class _Blocks extends Mock implements BlocksDatasource {}

class _Sign extends Mock implements SignPostMediaUrlsUseCase {}

class _Mutual extends Mock implements MutualPreviewDatasource {}

void main() {
  late _Pages pages;
  late _Toggle toggle;
  late _Blocks blocks;
  late OtherProfileCubit cubit;

  setUp(() {
    pages = _Pages();
    toggle = _Toggle();
    blocks = _Blocks();
    final mutual = _Mutual();
    when(() => mutual.get('target')).thenAnswer((_) async => {});
    when(() => pages.getPosts('target')).thenAnswer((_) async => []);
    cubit = OtherProfileCubit(pages, toggle, blocks, _Sign(), mutual, 'target');
  });
  tearDown(() => cubit.close());

  test('missing profile shows not found', () async {
    when(() => pages.getProfilePage('target')).thenAnswer((_) async => null);
    await cubit.load();
    expect(cubit.state.notFound, isTrue);
  });

  test('loads follow and blocked states from profile', () async {
    when(() => pages.getProfilePage('target')).thenAnswer(
      (_) async => const ProfilePageModel(
        iFollow: 'accepted',
        blockedByMe: true,
        followersCount: 4,
      ),
    );
    await cubit.load();
    expect(cubit.state.follow, FollowStatus.accepted);
    expect(cubit.state.page?.blockedByMe, isTrue);
    expect(cubit.state.followers, 4);
  });

  test('failed follow rolls back optimistic state and count', () async {
    when(() => pages.getProfilePage('target'))
        .thenAnswer((_) async => const ProfilePageModel(followersCount: 4));
    final pending = Completer<FollowStatus>();
    when(() => toggle('target', follow: true))
        .thenAnswer((_) => pending.future);
    await cubit.load();
    final action = cubit.toggleFollow();
    expect(cubit.state.follow, FollowStatus.accepted);
    expect(cubit.state.followers, 5);
    pending.completeError(const NetworkFailure());
    await action;
    expect(cubit.state.follow, FollowStatus.none);
    expect(cubit.state.followers, 4);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test(
    'private follow sends and cancels a request without changing count',
    () async {
      when(() => pages.getProfilePage('target')).thenAnswer(
        (_) async => const ProfilePageModel(isPrivate: true, followersCount: 4),
      );
      when(() => toggle('target', follow: true))
          .thenAnswer((_) async => FollowStatus.pending);
      when(() => toggle('target', follow: false))
          .thenAnswer((_) async => FollowStatus.none);
      await cubit.load();
      await cubit.toggleFollow();
      expect(cubit.state.follow, FollowStatus.pending);
      expect(cubit.state.requestSent, isTrue);
      expect(cubit.state.followers, 4);
      await cubit.toggleFollow();
      expect(cubit.state.follow, FollowStatus.none);
      expect(cubit.state.followers, 4);
    },
  );
}
