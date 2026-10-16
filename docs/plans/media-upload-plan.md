# Media upload plan

Status: approved 2026-10-16. Phases: [x] 0 · [x] 1 · [x] 2 · [x] 3 · [x] 4 · [x] 5 (Android build not verified) · [x] 6


## Context

Story and post uploads were built separately and now do the same job in two ways:

- **Transport is duplicated.** Story uses `HttpStoryMediaUploader` (`features/story/data/datasource/story_media_uploader.dart`): a streamed `http` POST with byte progress and upsert. Post uses `PostsDatasource.uploadFile` (`features/post/data/datasource/posts_datasource.dart:139`): an SDK `upload()` with no progress. Both write to the same private `post-media` bucket.
- **The background sender is duplicated.** `StoryUploadRepository` and `PostPublishRepository` are almost the same class: one job at a time, `fireLatest` on the EventBus, retry. Each has its own status type (`StoryUploadStatus`, `PostPublishStatus`) and its own retry use case.
- **Videos are never prepared.** The bucket limit is 50 MB (`20261012120000_home_feed.sql:371`, the Free plan cap), and `NewPostLimits` rejects anything bigger. A 60 s 4K gallery clip is about 300 MB, so shorts made from gallery clips would almost all be rejected. Story photos picked from the gallery (`MediaPickerService.pick()`) are not resized at all.
- **Shorts are coming.** The schema already supports them: a `posts` row with `kind = 'short'` and exactly one video, checked in `create_post`.

Goal: one shared upload path in `lib/shared/content` with generic names (the project rule, and the 2026-10-14 decision in `docs/specs/post/00-data-layer.md`). Story, post and short all use it. Videos are shrunk on the device only when they break the policy.

## Decisions (tagged)

| # | Decision | Tag |
|---|---|---|
| D1 | Shrink a video on the device **only if** it is over the policy (resolution, bitrate or byte budget), using the hardware encoder, H.264 at 1080p max. Otherwise upload it as-is. | confirmed (user) |
| D2 | Supabase Free plan for now, 50 MB per file. The plan will be upgraded, or the app will move to its own server later. | confirmed (user) |
| D3 | One upload slot per content kind (story, post and short each send one at a time, independently of each other). | confirmed (user) |
| D4 | No TUS/resumable upload yet. Keep one streamed request per file plus retry. Growth path below. | confirmed (user) |
| D5 | Keep the `MediaFilesDatasource` interface with its Supabase adapter. It is justified because a move to an own server is planned (D2). | inferred |
| D6 | Media policy values. Post and short video: long side ≤ 1920, ≤ 6 Mbps. Story video: 720p (long side ≤ 1280), ≤ 4 Mbps, so camera stories never get encoded (confirmed). Audio 128 kbps. Byte budget 95 % of 50 MB. Story gallery photo: long side ≤ 1920, quality 80. Post photo: unchanged (`ImageResizePreset.active`, 1080/80). All values are constants in one policy file. | story video confirmed; the rest assumption |
| D7 | Short max duration is 90 s. | confirmed (user) |
| D10 | Post video limit: keep the spec's 10 minutes. Videos the 50 MB budget cannot fit (≈ 5 min and longer on Free) get "too long". | confirmed (user) |
| D11 | The Home post banner shows a thin upload progress bar. This is outside the current spec, so I ask for the design values before building it. | confirmed (user); values open |
| D8 | Video package: `flutter_compress` 2.0.0, behind a one-file adapter. It is MIT-licensed, has no FFmpeg, and uses Media3 Transformer on Android and AVAssetReader/Writer on iOS. It supports a bitrate cap, a resolution cap, a target size, progress and cancel. Risk: young package from an unverified uploader with few likes, so it gets pinned, and the adapter lets us swap it for `video_compress` or a small platform channel. `video_compress` was rejected: last release 20 months ago, quality presets only (no bitrate cap), no cancel on Android. | assumption, verified on pub.dev 2026-10-16 |
| D9 | Automatic retry inside one attempt for transient errors only: up to 3 tries, backoff 1 s → 2 s → 4 s with jitter, through injectable `clock`. A 4xx response other than 408/429 fails at once. After that, the existing manual Retry. | assumption |

**Effect of the 50 MB cap.** The video bitrate is `min(cap, budget × 8 / duration − audio)`. If that falls below a floor (1.2 Mbps), the video is rejected as too long (D10). Raising the bucket limit later is a change to one constant plus one migration.

## Design

```
pick ─► (composer/camera closes) ─► ContentPublishRepository slot[kind]
          job.send(report):
            for each file: ContentMediaRepository.send()
               ├─ MediaPolicy.decide()      skip | shrink | reject
               ├─ VideoCompressService      only on "shrink", one encode at a time, output kept for retry
               ├─ MediaFilesDatasource.upload  streamed, byte progress, x-upsert, transient retry
               └─ thumb upload (video)
            then the kind's RPC (create_post / insert story), which already checks that each object exists
          ─► status on EventBus: Idle → Publishing(progress) → Done → Idle | Failed(failure) ─► Retry / Discard
```

Rules: deterministic object paths per job (story `{uid}/stories/{id}…` and post `{uid}/{postId}/{n}…`, as today). A retry skips files that are already in the folder and never re-encodes, because the prepared file is kept with the job. Temp encode output is deleted on Done or Discard. Uploads run strictly one after another inside a job. Encodes run one at a time across the app.

### Files

**shared/content (new or changed)**
- `data/datasource/media_files_datasource.dart`: add `upload({path, file, contentType, onBytes})` (the code moves here from `HttpStoryMediaUploader`, plus the D9 retry) and `listFiles(folder)` (it throws, unlike the best-effort `listFolder`). `remove` stays best-effort.
- `data/policy/media_policy.dart` (or `domain/`, following conventions): limits per `ContentKind` and `decide(PickedMedia) → skip | shrink(targets) | reject(reason)`. Pure Dart, so it is easy to unit test. `NewPostLimits.rejection` uses it for the video checks, and the composer keeps showing its notices.
- `data/repository/content_media_repository.dart`: replaces `PostMediaRepository` and the file half of `StoryUploadRepositoryImpl._post`. `send(item, kind, folder, stem, existing, onProgress) → UploadedMedia(path, thumbPath, width, height, durationMs)`. It is a repository because it does a real transformation (policy and encode) and combines sources (encoder, thumbnails, storage).
- `data/repository/content_publish_repository.dart`: one slot per `ContentKind`. `enqueue(kind, isEdit, previewPath, send(report))`, `retry(kind)`, `discard(kind)`, `current(kind)`. It fires `ContentPublishStatus` (has a `kind` field) on the EventBus. `fireLatest` is keyed by type, so the repository keeps a `Map<ContentKind, ContentPublishStatus>` for late listeners.
- `domain/entity/content_publish_status.dart`: sealed Idle / Publishing(progress, isEdit, previewPath) / Failed / Done. It merges `StoryUploadStatus` and `PostPublishStatus`.
- `domain/use_case/`: `RetryPublishUseCase(kind)`, `DiscardPublishUseCase(kind)`, `WatchPublishStatusUseCase(kind)` (the current value plus a filtered stream). These are cross-feature, so they belong here (home reads them; story, post and short write).

**core**
- `core/services/video_compress_service.dart`: the interface plus a `flutter_compress` adapter. `compress(path, maxLongSide, videoBitrate, audioBitrate, onProgress) → path`, plus `cancel()`. One encode at a time (a simple lock). It is a technical service and knows nothing about content.
- `core/services/media_picker_service.dart`: `pick()` takes an optional `ImageResizePreset`-style bound, so story gallery photos are resized natively by `image_picker`. No new encoder for images.

**features (migrate, then delete the duplicates)**
- story: `StoryUploadRepository`, `StoryMediaUploader`, `StoryUploadStatus` and `RetryStoryUploadUseCase` are removed. The story camera/edit flow enqueues `ContentKind.story` with a `send` that calls `ContentMediaRepository` and then `StoriesDatasource.insertStory`. `StoriesDatasource.bucket` is no longer used by upload.
- post: `PostPublishRepository`, `PostPublishStatus`, `RetryPostPublishUseCase` and `PostMediaRepository` are removed. `PostsDatasource.uploadFile/listFiles/removeFiles` are removed. `CreatePostUseCase` and `UpdatePostUseCase` call `ContentMediaRepository`. `createPost` gets a `kind` parameter (`post` | `short`) so shorts reuse the RPC.
- home: `StoryRailCubit` and `PostPublishCubit` read the shared status through `WatchPublishStatusUseCase` (story and post kinds). `PublishBanner` gets a thin progress bar (D11).
- short: nothing to build now. The future feature enqueues `ContentKind.short` and calls `ContentMediaRepository` plus `createPost(kind: short)`.

**Platform:** check `minSdk ≥ 24` and iOS deployment target ≥ 13 for `flutter_compress`. Run `build_runner`.

**Server:** no migration. The bucket mime/size limits and the object-exists checks in `create_post`/`update_post` stay the server's protection. Client checks are UX only.

## Phases

Each phase is self-contained. The app builds and works the same (or better) at the end of every phase. After each phase: `dart format`, `flutter analyze` and `flutter test` all pass, I report, and **I stop for your review before starting the next phase.** One commit per phase (only when you ask).

### Phase 0: Save the plan
- Copy this plan to `docs/plans/media-upload-plan.md` (next to `post-plan.md` and `story-plan.md`) before any code change. Each phase ticks its box there when it is done.

### Phase 1: One upload transport
- **Goal:** story and post send files through the same code path, with byte progress for both.
- **Changes:** add `upload({path, file, contentType, onBytes})` (moved from `HttpStoryMediaUploader`) and a throwing `listFiles(folder)` to `shared/content/.../media_files_datasource.dart`. Story's repository and post's `PostMediaRepository` call it. Delete `features/story/data/datasource/story_media_uploader.dart` and `PostsDatasource.uploadFile/listFiles/removeFiles`. Run `build_runner`.
- **Tests:** move the uploader test to the datasource (headers, upsert, progress, error status). Update `story_upload_repository_test` and the post use-case tests for the new dependency.
- **Done when:** a story and a post both upload on a device. No behavior change except post can now report progress internally.

### Phase 2: Automatic retry for transient errors (D9)
- **Goal:** short network hiccups no longer surface as Failed.
- **Changes:** inside `MediaFilesDatasource.upload`: classify errors (timeout, socket, 408/429/5xx = retry; other 4xx and missing file = fail now). Up to 3 tries, backoff with jitter, through `clock`, with a random source that can be injected for tests.
- **Tests:** a mock `http.Client` plus `fake_async`: a transient error is retried and then succeeds, a permanent error is not retried, and after 3 failures the error is thrown.
- **Done when:** the tests pass. Manual Retry still works on top.

### Phase 3: One background publisher, a slot per kind (D3)
- **Goal:** replace the two near-identical senders with one generic one that shorts can use.
- **Changes:** add `ContentPublishStatus` (sealed, has `kind`), `ContentPublishRepository` (`enqueue/retry/discard/current` per `ContentKind`) and `RetryPublishUseCase`, `DiscardPublishUseCase` and `WatchPublishStatusUseCase` in `shared/content`. Migrate the story flow, the post composer (`AddEditPostCubit`) and home (`StoryRailCubit`, `PostPublishCubit`, `HomeScreen`, `PublishBanner`). Delete `StoryUploadRepository`, `StoryUploadStatus`, `RetryStoryUploadUseCase`, `PostPublishRepository`, `PostPublishStatus` and `RetryPostPublishUseCase`. Run `build_runner`.
- **Tests:** port `story_upload_repository_test` to `content_publish_repository_test` (a story and a post run in parallel, a busy slot refuses a new job, retry, discard, late listener reads `current`). Update `story_rail_cubit_test`, `story_rail_test`, `home_screen_test` and `add_edit_post_cubit_test`.
- **Banner progress (D11):** `ContentPublishStatus.Publishing.progress` feeds a thin bar in `PublishBanner`. Before building it I ask for the height, color token, track color, radius and placement, unless `docs/specs/home` already has them. Values go in `home_dimens.dart`, colors use `context.appColors`, and the bar is RTL-aware (it fills from the start edge). Widget test: the bar follows the progress value.
- **Done when:** the rail ring behaves as before, and the feed banner behaves as before plus the progress bar.

### Phase 4: Media policy and shared media sender (no encoding yet)
- **Goal:** one place decides what a file needs, and one sender handles file plus thumb for every kind.
- **Changes:** add `MediaPolicy` (limits per kind, `decide → skip | shrink | reject`, the bitrate/budget math from D6). Add `ContentMediaRepository.send()` (policy → upload main file → upload thumb, skip files already in the folder, progress 0→1). It replaces `PostMediaRepository` and the file half of the story job. `NewPostLimits` reads the video checks from the policy (the composer keeps its notices). For now a `shrink` result is treated as "upload as-is if ≤ 50 MB, otherwise reject", which is today's behavior.
- **Tests:** `media_policy_test` (skip, shrink targets, reject below floor, per kind). `content_media_repository_test` with fakes (skips existing files, progress is monotonic, a video thumb is sent).
- **Done when:** behavior is unchanged and all decisions come from the policy.

### Phase 5: On-device video shrink (D1, D8)
- **Goal:** gallery 4K or long videos fit under 50 MB instead of being rejected.
- **Pre-check:** re-verify `flutter_compress` on pub.dev at that time. Check `minSdk ≥ 24` and iOS ≥ 13. **I ask before adding the package.**
- **Changes:** add `core/services/video_compress_service.dart` (interface plus `flutter_compress` adapter, one encode at a time, cancel). `ContentMediaRepository` runs it on `shrink`, keeps the output with the job so a retry does not re-encode, and deletes the temp file on Done/Discard. Progress counts encoding as 30 % and upload as 70 % when encoding runs. Remove the size rejection from the composer when a shrink can bring the file under budget.
- **Tests:** fake compressor: called only on shrink, not called again on retry, temp file deleted, progress weighting correct.
- **Done when:** on a physical device a 4K 60 s clip posts under 50 MB, and a 720p camera story uploads without encoding. You run this check; I can't run it here.

### Phase 6: Story gallery photo bound and short-ready
- **Goal:** close the last gaps before the shorts feature.
- **Changes:** `MediaPickerService.pick()` takes a resize bound, so story gallery photos use max side 1920 and quality 80. `PostsDatasource.createPost` gets `kind` (`post` | `short`). Add the short policy entry (90 s, D7). Update `docs/specs/post/00-data-layer.md` with a short "media upload" note and the CLAUDE.md *Known state* line.
- **Tests:** picker passes the bound. `createPost` sends `p_kind`.
- **Done when:** the shorts feature can be built only on `ContentPublishRepository`, `ContentMediaRepository` and `createPost(kind: short)`.

## Still open (asked at the step that needs them, does not block Phase 1–2)

- Banner progress bar design values (Phase 3).
- Approval to add `flutter_compress` after re-checking it (Phase 5).
- Physical-device checks (Phase 5): only you can run them.

## Not promised (state honestly)

- Uploads run in the app process. On iOS they stop soon after the app is backgrounded. On Android they can be killed in the background. A force-quit loses the job, and nothing is persisted across restarts.
- Growth path: a persistent job (store the job and prepared paths in `LocalStorageService`) when users report lost uploads. TUS (Supabase `/storage/v1/upload/resumable`, 6 MB chunks, URL kept with the job) when files go above ~50 MB after the plan upgrade. Android foreground service / iOS background `URLSession` only if uploads must survive backgrounding. A server transcoding worker only if renditions or HLS are needed, and it still costs the original upload.

## Verification (summary; each phase lists its own tests)

- Unit: `MediaPolicy.decide` (skip, shrink with bitrate math, reject below floor, per-kind limits). `ContentPublishRepository` (slots per kind run in parallel, a busy slot refuses, retry, discard, `current(kind)`; port `story_upload_repository_test.dart`). `ContentMediaRepository` with fakes (skips existing files, does not re-encode on retry, deletes temp output, progress stays monotonic 0→1). The datasource retry classification (transient vs permanent) with a mock `http.Client` and `fake_async`.
- Update `story_rail_cubit_test`, `home_screen_test`, `story_rail_test` and `add_edit_post_cubit_test` for the shared status.
- `fvm dart format .`, `fvm flutter analyze`, `fvm flutter test`.
- Manual, on physical devices (not verifiable here): a 4K 60 s gallery clip as a post (shrinks below 50 MB, shows progress), a 720p camera story (no encode), airplane mode in the middle of an upload (Failed → Retry uploads only the missing files, no re-encode), encode time and heat on a low-end Android.
