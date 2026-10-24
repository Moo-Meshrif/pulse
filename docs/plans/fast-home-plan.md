# Fast Home and Hive storage — what the user will see

Status: in progress (phases 0-1 done 2026-10-23, phases 2-4 done 2026-10-24). Phases: [x] 0 · [x] 1 · [x] 2 · [x] 3 · [x] 4 · [ ] 5
Mode: one-by-one

## Today's problem
Every launch waits for the server before Home opens: up to 10 seconds on a weak connection, with only the splash on screen.
While the feed loads, the whole Home is a skeleton, and the Stories rail is a fake one even when its real answer is already in.
Nothing is kept on the phone, so every launch starts from empty.

## The new story

**1. You open the app again (you have used it before)**
→ The phone already knows if your sign-up is finished (saved from your last visit).
→ Saved as finished: Home opens at once. The server is not asked at start-up, so there is no wait. If your session was ended elsewhere or your account is gone, Home finds out on its first server answer and takes you to Sign in with the same message as today.
→ Saved with a step still missing (or nothing saved): the splash asks the server for the latest step, because you may have finished sign-up on another device. It waits at most 5 seconds.
→ Server says finished: Home opens. A step is still missing: that sign-up step opens, as today.
→ Your session has expired or been ended elsewhere, or your account is gone: Sign in opens with the same message as today.
→ The server takes longer than 5 seconds: you are signed out. Sign in opens with the "session expired" message.
→ No connection while a step is missing: you see the "offline" page with Try again, as today (sign-up steps need the network).

**2. Home appears**
→ The header, the Stories rail and the posts you saw last time show at once, saved from your last visit.
→ The phone saves the posts, but never the links to their photos and videos. Those links are private and expire.
→ Photos you already looked at come from the phone. A photo the phone does not have shows its soft blurred preview.
→ A saved video shows its cover. It plays once the fresh feed brings its link.
→ Nothing on Home waits for one request or one photo before the rest can show.

**3. The fresh feed arrives a moment later**
→ If you have not scrolled yet, the feed updates in place, quietly. Photos and videos get their links.
→ If you have started reading, nothing moves. New posts wait behind the "new posts" pill, as today. Posts you already see are updated where they are.
→ Saved posts that are not in the fresh feed get their links in one extra request, without moving. If that request fails, they keep their covers until you pull to refresh.
→ The Stories rail updates by itself, in place.

**4. You open the app for the first time on this phone (nothing saved yet)**
→ The header shows at once.
→ The rail and the feed each show their own skeleton and each fills in as soon as its own answer arrives. The rail does not wait for the feed.

**5. You open the app with no connection**
→ With a saved Home: you see your saved rail and posts, photos from the phone or blurred. The background load fails quietly. Pull to refresh tells you it could not load, as today, and the saved posts stay.
→ With nothing saved: the header and rail stay on top, with the "offline" page and Try again below, as today.

**6. You sign out (or your session ends, or the start-up check runs out of time)**
→ The saved Home feed and Stories rail are deleted. The next person on the phone never sees them, even for a moment.

## Phases (one by one: I stop after each phase for your review)

### Phase 0: Save the plan
**Status:** [x]
- **Goal:** the plan is saved.
- **Tasks:**
  - [x] Save this plan as `docs/plans/fast-home-plan.md`.
- **Done when:** the file is saved.

### Phase 1: Hive on the phone
**Status:** [x]
- **Goal:** Hive is added and opened once at start-up, ready to hold the saved Home. Nothing visible changes.
- **Depends on:** Phase 0.
- **Tasks:**
  - [x] Add `hive_ce`, opened once at start-up before the first frame.
  - [x] One box for the saved Home (feed and rail), wipeable at any time.
  - [x] A box that cannot be opened (corrupt file) is deleted and opened empty again.
- **Implementation steps:**
  1. `pubspec.yaml` (edit): add `hive_ce` (latest stable). No `hive_ce_flutter` and no generator: the folder comes from `AppFolders.cache`, and values are stored as JSON strings, so no type adapters.
  2. `lib/core/services/storage/app_folders.dart` (edit): add a `cache` folder (the OS caches directory: left out of backups, may be cleared by the OS), faked in tests like the others. Check the file first; reuse an existing cache or temp folder if it already has one.
  3. `lib/core/services/storage/snapshot_storage.dart` (new): interface + Hive adapter in one file, as the other core services. Opens `Hive.init('${folders.cache}/hive')` and one `Box<String>` named `feed_cache`. API: `String? read(String key)`, `Future<void> write(String key, String value)`, `Future<void> delete(String key)`, `Future<void> clear()`. A box that fails to open is deleted and opened again empty, reported with `ErrorReporter`.
  4. `lib/core/services/storage/storage_keys.dart` (new): every Hive key, same style as `StorageKeys` ("never change a shipped string"): `feed(uid)`, `storyRail(uid)` (used in Phase 3).
  5. `lib/app/app_module.dart` (edit): `@preResolve @lazySingleton Future<SnapshotStorage> hiveStorage(AppFolders folders) => SnapshotStorage.open(folders)`.
  6. Run `fvm dart run build_runner build --delete-conflicting-outputs`.
  7. Docs: `.claude/conventions/notes.md` local-storage rule adds "saved Home (lists that grow) goes in Hive through `SnapshotStorage`; small flags stay in `LocalStorageService`; signed media links are never stored"; `CLAUDE.md` Known state mentions Hive.
- **Tests:**
  - `test/core/services/storage/snapshot_storage_test.dart` (new): real `SnapshotStorage` in a temp folder (`Directory.systemTemp.createTempSync()`), closed and deleted in `tearDown`. Write/read/delete/clear; a corrupt box file reopens empty.
  - `test/helpers/pump_app.dart` (edit): `bootApp` opens Hive in a temp folder (via the faked `AppFolders`) and closes it after the test.
- **Done when:** the app starts exactly as before; the new test passes.
- **Verify:** `fvm flutter analyze`, `fvm flutter test`. **I ask you first:** adding `hive_ce`.

### Phase 2: The Stories rail loads on its own
**Status:** [x]
- **Goal:** the real rail shows as soon as its answer arrives, even while the feed is still loading; it never shows a fake rail once the real one is in.
- **Depends on:** Phase 0.
- **Spec refs:** `docs/specs/home/screens/s1-home-feed.md` (First load, Error first load), `docs/specs/home/02-components.md` (C2 rail, C14 skeleton).
- **Tasks:**
  - [x] The rail has its own skeleton, shown only until its first answer.
  - [x] While the feed loads, the page shows the header, the real rail (or its skeleton) and post skeletons.
  - [ ] Same skeleton look, shimmer, fade and reduce-motion rule as the spec. RTL and screen reader unchanged.
- **Implementation steps:**
  1. `lib/features/home/presentation/cubit/story_rail/story_rail_state.dart` (edit): `@Default(false) bool isLoaded` (the rail has had an answer, from the server or, from Phase 3, the phone).
  2. `lib/features/home/presentation/cubit/story_rail/story_rail_cubit.dart` (edit): `load()` success also sets `isLoaded: true`. A failed load leaves `isLoaded` false, so the skeleton stays until the next load (pull to refresh, change check).
  3. `lib/features/home/presentation/widgets/feed/feed_skeleton.dart` (edit): move `_skeletonEffect` into `lib/features/home/presentation/widgets/skeleton_effect.dart` (new, `homeSkeletonEffect(context)`), and split: `FeedSkeleton` shows only post-card shapes; `RailSkeletonZone` (in `story_rail/rail_skeleton.dart`, edit) wraps `RailSkeleton` in `Skeletonizer.zone` with that effect and the loading semantics.
  4. `lib/features/home/presentation/widgets/story_rail/story_rail.dart` (edit): `BlocBuilder` also rebuilds on `isLoaded`; when false it returns `RailSkeletonZone` at the same height.
  5. `lib/features/home/presentation/view/home_view.dart` (edit): `_Loading` slivers become `FeedHeader`, `SliverToBoxAdapter(StoryRail())`, `SliverToBoxAdapter(FeedSkeleton())`. `_Posts` and `FeedMessagePage` keep `StoryRail` (they now get its skeleton for free).
- **Tests:**
  - `test/features/home/presentation/cubit/story_rail/story_rail_cubit_test.dart` (edit): `isLoaded` true after a load, false after a failed first load.
  - Home widget test (existing Home view test, or new `test/features/home/presentation/view/home_view_test.dart` if none, asked first): feed loading + rail loaded shows real rail names and post skeletons.
- **Done when:** on a throttled connection, the rail fills in while the posts are still skeletons; with the rail request failing, the rail skeleton stays and the feed still shows.
- **Verify:** `fvm flutter analyze`, `fvm flutter test`, run the app with a slow network (Network Link Conditioner / emulator throttle) in EN and AR, with reduce motion on once.

### Phase 3: Home saved on the phone
**Status:** [x] (code and tests done; run online/offline/sign-out by hand still to do)
- **Goal:** Home opens with your last feed and rail at once, without any saved media link, then updates itself without moving what you read.
- **Depends on:** Phases 1 and 2.
- **Tasks:**
  - [x] After each first-page load or refresh, save the first page and the whole rail in Hive, per user. No media links are saved.
  - [x] When Home opens, show the saved rail and posts at once. Photos come from the phone's image cache or show their blurred preview; videos show their cover and don't play yet.
  - [x] Then load fresh posts in the background. If the person is at the top, replace in place. Otherwise update the posts on screen where they stand and put new ones behind the pill.
  - [x] Saved posts still on screen that the fresh page did not bring get their links in one request; a failure leaves them as covers.
  - [x] Delete the saved Home when the session ends (sign out, expired, revoked, start-up timeout).
- **Implementation steps (post: data and domain):**
  1. `lib/features/post/data/model/post_model.dart` (edit): `toJson()` mirroring `fromJson` key by key (`media`, `tags`, `shared_post` nested), using `JsonMapper` as in `profile_model.dart`. `PostMediaModel` and `PostTagModel` already have `toJson`. Media keep only storage paths (`path`, `thumb_path`), never a signed link.
  2. `lib/features/post/data/model/feed_page_model.dart` (edit): the existing model is the saved shape too, no new model. Add `FeedPageModel.fromJson(Map<String, dynamic>)` and `toJson()` (`posts` through `PostModel.fromJson`/`toJson`, `next_before_created`, `next_before_id`). It has no link field: signed links expire after one hour and must not be stored on the phone.
  3. `lib/features/post/data/datasource/feed_local_datasource.dart` (new): interface + Hive adapter: `FeedPageModel? read(String uid)`, `Future<void> write(String uid, FeedPageModel feed)`. Key `StorageKeys.feed(uid)`. Bad data reads as null; a failed write is reported and never thrown (as `ProfileLocalDatasource.write`).
  4. `lib/features/post/data/repository/feed_repository.dart` (new; abstract + `Impl`, one file, as `ProfileRepository`): `Future<FeedPageModel> page({required int limit, DateTime? beforeCreated, String? beforeId, bool saved = false})`. Default = `PostsDatasource.getHomeFeed`; when it is the first page (no cursor) it writes the cache (posts + cursor). With `saved: true` it makes no request and returns the copy of `currentUserId` as a page (an empty page when nothing is saved or there is no session). Network-first otherwise; no fallback to the copy on a failure (the cubit shows the copy first itself). Signing stays where it is today (`FeedPostSigner` in Home).
  5. `lib/features/post/domain/mapper/feed_page_mapper.dart` (new): the `FeedPageModel`/cache → `FeedPageEntity` mapping now inside `GetHomeFeedUseCase` (posts through `PostEntityMapper.fromModel`, cursor only when both parts are set), used by `GetHomeFeedUseCase`.
  6. `lib/features/post/domain/use_case/get_home_feed_use_case.dart` (edit): gets `bool saved = false` in `call({cursor, saved})`, calls `FeedRepository.page(saved: saved)` instead of `PostsDatasource`, maps with step 5. No separate "saved" use case: the same use case serves both, the repository does the switch. `saved: true` with nothing saved returns a page with no posts.
- **Implementation steps (story: data and domain):**
  7. `lib/features/story/data/model/story_rail_item_model.dart` (edit): `toJson()`. (`avatar_url` is a public link, safe to keep.)
  8. `lib/features/story/data/datasource/story_rail_local_datasource.dart` (new): as step 3, key `StorageKeys.storyRail(uid)`, value the JSON list of items.
  9. `lib/features/story/data/repository/story_rail_repository.dart` (new): `Future<List<StoryRailItemModel>> rail({bool saved = false})` = `StoriesDatasource.getStoryRail` then write the copy; with `saved: true` no request, the copy (empty when none).
  10. `lib/features/story/domain/use_case/get_story_rail_use_case.dart` (edit): uses the repository; the model→entity mapping moves to `lib/features/story/domain/mapper/story_rail_item_mapper.dart` (new). `call({bool saved = false})` passes the flag to the repository; no separate saved use case.
- **Implementation steps (media with no link yet):**
  11. `lib/features/post/presentation/utils/post_card_media.dart` (edit): `url` becomes `String?`. Null means the post is shown from the phone and has no link yet: a picture is read from the device image cache by `cacheKey`, otherwise its blurhash shows; a video shows its cover and does not play.
  12. `lib/core/utils/cached_picture.dart` (edit): `savedPicture(String cacheKey)`: an `ImageProvider` that only reads the device cache (`CachedNetworkImageProvider.defaultCacheManager.getFileFromCache(cacheKey)`) and fails when the file is not there; never goes to the network. `lib/core/widgets/app_image.dart` (edit): `AppImage.saved(String cacheKey, {…})` constructor with the network options (`placeholder`, `errorBuilder`, `onError`, `frameBuilder`, `cacheWidth`), using `savedPicture`.
  13. `lib/features/post/presentation/widgets/media/post_image_item.dart` (edit): with no url, `AppImage.saved(media.cacheKey!)` with the same blurred preview as placeholder and error. `post_video_item.dart` (edit): with no `posterUrl`, the poster comes from `AppImage.saved(posterCacheKey)`.
  14. `lib/features/home/presentation/utils/feed_videos.dart`, `lib/features/post/presentation/utils/post_video_ids.dart` (edit): skip media whose `url` is null (no player, so the video item stays on its cover). `lib/features/home/presentation/widgets/feed/feed_post_item.dart` (edit): the cache-key → link map skips null links.
- **Implementation steps (Home):**
  15. `lib/features/home/presentation/utils/feed_post_signer.dart` (edit): add `List<FeedPost> unsigned(List<PostEntity> posts)`: no request; every media kept with `url` and `posterUrl` null, `cacheKey`, `posterCacheKey`, sizes and blurhash set. `sign` unchanged (one request; a file whose link failed is left out).
  16. `lib/features/home/presentation/cubit/feed/feed_state.dart` (edit): `@Default(false) bool fromPhone` (the posts on screen are the saved copy).
  17. `lib/features/home/presentation/cubit/feed/feed_cubit.dart` (edit):
      - no new use case: `start()` calls the existing `GetHomeFeedUseCase` with `saved: true`.
      - `start()`: read the saved page (`saved: true`); with posts, emit `status: ready, posts: _signer.unsigned(saved.posts), nextCursor, fromPhone: true, generation + 1` and call `_freshFirstPage()`; without, `load()` as today.
      - `bool _atTop = true` and `void setAtTop(bool atTop)`.
      - `_freshFirstPage()`: `run(_page(null))`, prevented while busy; marks busy like a silent refresh (`isRefreshing` stays false; a private `_freshLoading` flag also checked by `_isBusy`). Success at top: `_replaced(page).copyWith(fromPhone: false)`. Success not at top: `applyFreshPosts(posts, pending, fresh: page.posts, asked: const [])`, `replacedIds` set, cursor kept, `fromPhone: false`, then `_signLeftovers()`. Failure: `fromPhone` stays true, nothing shown.
      - `_signLeftovers()`: the posts on screen whose media still have no link (a null `url` on own or original media); none → nothing. Otherwise `_signer.sign(their entities)` in one request and swap each by id where it stands (`posts` and `pendingPosts`), checked against `generation` so a refresh in between wins. Failure is ignored: they keep their covers until pull to refresh.
      - `refresh()` while `fromPhone` behaves as today (replaces) and clears `fromPhone`.
  18. `lib/features/home/presentation/widgets/feed/feed_floaters.dart` (edit): in the scroll listener, when `FeedFloatersRules.isAtTop(offset)` changes, call `context.read<FeedCubit>().setAtTop(...)`.
  19. `lib/features/home/presentation/cubit/story_rail/story_rail_cubit.dart` (edit): `start()` calls the existing `GetStoryRailUseCase` with `saved: true` and emits its items (when not empty) with `isLoaded: true` before `load()`.
  20. Run `fvm dart run build_runner build --delete-conflicting-outputs`.
- **Implementation steps (clearing):**
  21. `lib/features/auth/data/datasource/auth_datasource.dart` (edit): inject `SnapshotStorage`; in its existing `onAuthStateChange` listener, on `AuthChangeEvent.signedOut` (any reason) `unawaited(_hive.clear())`.
- **Tests:**
  - `test/features/post/data/repository/feed_repository_test.dart` (new): first page saves posts + cursor; the saved JSON has no signed link; a later page does not save; `page(saved: true)` per user, empty when nothing saved; a failed remote does not touch the copy.
  - `test/features/post/data/model/post_model_test.dart` (new or edit): `fromJson(toJson(x)) == x` with media, tags and a shared post.
  - `test/features/story/data/repository/story_rail_repository_test.dart` (new): save and read back.
  - `test/features/home/presentation/utils/feed_post_signer_test.dart` (new or edit): `unsigned` keeps every media with null links and its cache keys.
  - `test/features/home/presentation/cubit/feed/feed_cubit_test.dart` (edit): saved feed emits `fromPhone` posts with no links and no signing request; fresh page at top replaces; fresh page not at top keeps order, updates in place, new posts go to `pendingPosts`, leftovers signed in one request; leftover signing failure keeps them unsigned with no failure shown; fresh failure keeps the saved posts and emits no failure.
  - `story_rail_cubit_test.dart` (edit): saved items first, then fresh.
  - `auth_datasource` test (edit if one exists): signed-out event clears the Hive box.
- **Done when:** open Home, close the app, turn on airplane mode, reopen: the saved rail and posts show at once, photos seen before show, others are blurred, videos show their cover. Reopen online after scrolling down: nothing jumps, the pill shows if new posts came, and older saved videos play. Sign out and sign in as another account: the first account's posts never show.
- **Verify:** `fvm flutter analyze`, `fvm flutter test`, run online, offline and after sign-out.

### Phase 4: Start-up skips the server when sign-up is finished on the phone
**Status:** [x] (code, tests and specs done; run online/offline/throttled/revoked by hand still to do)
- **Goal:** a launch whose saved profile says sign-up is finished opens Home with no server wait. Only a launch with a missing step (or nothing saved) asks the server, for at most 5 seconds.
- **Depends on:** Phase 3 (signing out clears the saved Home).
- **Spec refs:** `docs/specs/auth/00-overview.md` (start-up routing), `docs/specs/auth/screens/s13-splash.md`, `docs/specs/auth/open-questions.md` (Q25, Q36).
- **Tasks:**
  - [x] Signed in and saved as finished: go to Home at once, no request.
  - [x] Saved with a missing step, or nothing saved: ask the server for the latest step (another device may have finished it). Wait 5 seconds instead of 10.
  - [x] A fetch that runs out of time signs the user out and opens Sign in with the "session expired" message.
  - [x] Everything else stays as today: a missing step opens that step; expired, revoked or deleted account opens Sign in with its message; no connection shows the offline page.
  - [x] Update the splash specs to the new rules.
- **Implementation steps:**
  1. `lib/features/profile/data/repository/profile_repository.dart` (edit): `SignupStep? savedSignupStep()` = the local copy's step for `_remote.currentUserId`, null when none or no session.
  2. `lib/features/profile/domain/use_case/is_signup_done_on_device_use_case.dart` (new): `bool call()` = `savedSignupStep() == SignupStep.complete`.
  3. `lib/features/splash/presentation/cubit/splash_cubit.dart` (edit): inject `IsSignupDoneOnDeviceUseCase`. After the signed-in check: done on device -> `emit(SplashState.go(AppRoutes.home))` and return, no request. Otherwise today's path with `_decideWithin` = 5 s. In `_failed`, `TimeoutFailure()` gets its own case: sign out like `NotFoundFailure` (`unawaited(_signOut().catchError(...))`) and `SplashState.go(AppRoutes.signInWith(SignedOutReason.expired))`, shared in a private `_endSession()`. `NetworkFailure()` keeps the connection check. Update the class doc. `GetSignupStepUseCase` stays as it is.
  4. `lib/core/router/session_guard.dart`: no change. A dead or deleted-account session is caught by Home's own requests through `SessionGuard`, as for any screen. Check that a deleted account (profile gone) from Home's first requests ends at Sign in; if not, report it and ask before adding anything.
  5. Specs (docs only): `s13-splash.md` and `00-overview.md` say the server is skipped when the saved profile is finished, and a 5 s timeout signs out to Sign in (expired). `open-questions.md` Q25 and Q36 get a dated note: changed by the user on 2026-10-23.
- **Tests:** `test/features/splash/presentation/cubit/splash_cubit_test.dart` (edit): done on device -> Home and `GetSignupStepUseCase` never called; not done on device -> asks the server; slower than 5 s -> `SignOutUseCase` called and route `signInWith(expired)` (fake async); `NetworkFailure` -> connection problem as today; pending step -> `/register?step=N`; revoked, expired, not found unchanged. `test/features/profile/...` (edit): `savedSignupStep` per user, null with no session.
- **Done when:** signed in with a finished sign-up, even in airplane mode, the app opens on Home with no wait on the splash. With a saved missing step, the server is asked: finished on another device opens Home, still missing opens that step, a reply past 5 s lands on Sign in with the session-expired message and the saved Home is gone.
- **Verify:** `fvm flutter analyze`, `fvm flutter test`, run online, offline, throttled past 5 s, with a missing step finished from another device, and with a revoked session.

### Phase 5: Check it on real devices
**Status:** [ ] (emulator numbers only, 2026-10-24; real Android and iPhone runs still to do)
- **Emulator numbers** (Android 16 arm64 emulator, profile APK, offline: not a low-end phone): cold start `am start -W` online 2.2 / 2.5 / 2.7 s (median 2.5 s); offline 3.1 s (1 run). Offline, the saved rail and posts show behind the splash fade at about 1 s after launch. No `before` (commit `3965713`) build measured. Hive open time not measured separately.
- **Goal:** the launch feels fast on a low-end Android phone and an iPhone.
- **Depends on:** Phases 1-4.
- **Tasks:**
  - [ ] Measure tap → posts on screen, cold and warm, profile build, before (commit `3965713`) and after. Write the numbers here.
  - [ ] Check opening Hive and reading the saved Home adds no visible delay to the first frame.
  - [ ] Check RTL, large text and reduce motion on the new loading states.
- **Implementation steps:**
  1. No app code. Use `fvm flutter run --profile` with DevTools (Performance, timeline from app start) or a screen recording at 60 fps, 3 runs each, median.
  2. If Hive open time shows in the first frame (> ~16 ms), note it here for a follow-up; don't change code in this phase.
- **Done when:** the numbers are written down, and once Home opens the saved posts show before any feed answer on both phones.
- **Verify:** profile runs on both devices.

## What it can't do
- When sign-up is saved as finished, start-up does not ask the server. A session ended elsewhere or a deleted account is found only when Home's first request fails, a moment after it opens.
- When a sign-up step is missing on the phone, start-up waits for the server (up to 5 seconds); on a slower connection you are signed out and must sign in again, and your saved Home is deleted.
- Saved posts have no media links: a saved video plays only after the fresh load brings its link, and a photo the phone never loaded shows its blurred preview until then (or until you are back online).
- The saved Home is as old as your last visit, until the fresh feed arrives.
- On the very first launch (and after sign-out) Home still waits for the server, with skeletons.
- The OS may clear the saved Home or the saved photos when the phone is low on space; the next launch then loads from the server, with skeletons or blurred previews.

## For the builder

### Reuse
- `AppFolders` (new `cache` folder) for the Hive folder.
- `GetSignupStepUseCase` for the server check when a step is missing; `ProfileLocalDatasource` (through `ProfileRepository`) for the saved step; `SignOutUseCase` for the timeout sign-out; `SessionGuard` for sessions that end after Home opens.
- `applyFreshPosts` (`home/presentation/utils/feed_changes.dart`), `FeedState.pendingPosts` and the pill; `FeedFloatersRules.isAtTop`.
- `FeedPostSigner.sign` for the fresh page and the leftovers; `PostCardMedia.cacheKey` / `posterCacheKey` (storage path) key the image cache by file, so saved posts with no link still show photos already on the phone.
- `cachedPicture` / `CachedNetworkImageProvider.defaultCacheManager` for `savedPicture`.
- `RailSkeleton`, `PostCardSkeleton`, `Skeletonizer.zone` for the split skeletons.
- `ErrorReporter` for failed cache writes; `JsonMapper` for the new `toJson`s.

### Code TODOs
None.

### Verification
- Every phase: `fvm flutter analyze` and `fvm flutter test` pass.
- Phases 2-4: run on a throttled and an offline connection, EN and AR.
- Phase 4: a server answer delayed past 5 s signs out to Sign in (expired).
- Phase 5: profile-build timings on a low-end Android and an iPhone.
