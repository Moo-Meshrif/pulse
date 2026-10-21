# Drafts and posting through the server — what the user will see

Status: draft 2026-10-19, waiting for approval. Phases: [x] 0 · [x] 1 · [x] 2 · [x] 3 · [x] 4 · [x] 5 · [x] 6 · [x] 7
Covers posts only (drafts + posting through the server). Uploading while the app is asleep is out of this plan.

## Today's problem
If you close New post, or the app closes, your post is lost. Photos only start uploading after you tap Share. A post that was uploading when the app closed is lost.

## The new story

**1. You open New post**
→ A draft is made on your phone.
→ If you already have an unfinished draft, it opens instead.

**2. You pick 2 photos**
→ They show at once and start uploading right away.
→ You can keep writing while they upload.

**3. You add a 3rd photo**
→ Only the new photo starts uploading. The other two keep going.

**4. You remove one photo**
→ It disappears at once and its upload stops.
→ If it already reached the server, it gets deleted.
→ The rest of your draft stays.

**5. You move a photo or change the text**
→ Nothing uploads again.

**6. You tap X**
→ You see: **Save draft / Discard post / Keep editing**.

**7. The app closes by itself (crash, phone kills it)**
→ The draft is still saved.
→ Next time you open the app, unfinished uploads start again.

**8. You open New post again**
→ Your text, photos and settings are back.

**9. You tap Share**
→ New post closes at once. Home shows "Posting…" with progress.
→ The post is created only after all photos are uploaded.
→ If the internet drops at the last moment, the app asks the server "did it go out?" — so the post is never posted twice.

**10. You write a second post and tap Share while the first is still uploading**
→ New post closes at once. Home shows "2 posts posting".
→ Post 2 goes out right after post 1, in the order you shared them.
→ You can have up to 3 posts waiting; a 4th tells you to wait.

**11. You tap Discard post**
→ New post closes at once.
→ The server marks the draft "discarded", so it can never be posted after that.
→ Uploads stop, and the photos are deleted from the server.
→ If you're offline, the app finishes this the next time it's online.

**12. You sign out, someone else signs in on the same phone**
→ They never see your draft, or your posts that are still uploading.
→ A post you already shared continues when you sign back in.
→ When you sign back in, your draft is still there.

## Safety (done on the server, not only in the app)
- Only you can see your draft's photos. (Today, followers could see unposted photos — this gets fixed.)
- A discarded draft can never be posted, even by a delayed request.
- The server posts only when every file is there, belongs to you, and has the right size and type.
- Cleanup never deletes photos of a posted post or story, or anyone else's photos.
- A draft untouched for 30 days is discarded automatically. A shared post whose files never arrive is given up after 3 days.

## Phases (one by one: I stop after each phase for your review)

### Phase 0: Save the plan
**Status:** [x]
- **Goal:** the plan is in `docs/plans/`.
- **Depends on:** nothing.
- **Tasks:**
  - [x] Save this plan as `docs/plans/content-publishing-plan.md`.
- **Done when:** the plan is saved.

### Phase 1: Server rules for drafts and pending posts
**Status:** [x]
- **Goal:** the server knows what a draft and a pending post or story are. Only you see their files, a discarded draft can never be posted, and a post is never created twice.
- **Depends on:** Phase 0.
- **Spec refs:** `docs/specs/post/00-data-layer.md`; migrations `20261013155541_home_feed.sql` (storage rules), `20261014135126_post_visibility.sql` (who can see files), `20261015162526_post_tags_mood.sql` (`create_post`). For the builder: B1, B2, B5.
- **Tasks:**
  - [x] Make repo migrations match the live database first (live has one more, `username_exists`).
  - [x] One table for content that isn't posted yet: posts, shorts and stories, with id (the future post or story id), owner, kind and state (draft / waiting to publish / published / rejected / discarded / abandoned). Rejected = the server refused it at publish (for example a tag on a photo that was removed).
  - [x] Server calls: open a draft, discard it, share it (saves the post's details so the server can post it later), publish it (one transaction, safe to call twice), ask its state, list the files to clean, confirm the clean.
  - [x] Publish checks that every file and video frame is uploaded, belongs to you and has the expected size and type, then creates the post (photos in order) or the story.
  - [x] Every minute, the server publishes shared posts and stories whose files have all arrived (one bad one never blocks the others).
  - [x] `create_post` refuses the id of a discarded draft (for old app versions and direct calls).
  - [x] Uploads into a folder whose draft was discarded, rejected or abandoned are refused. Folders with no draft record (today's app versions) and story uploads keep today's rule, so nothing breaks before the new app ships.
  - [x] Draft files are visible only to you. On a posted post, others see only the files that are part of the post.
  - [x] Hourly/daily jobs: a draft untouched for 30 days and a shared item whose files never arrived in 3 days become abandoned; old records are removed.
  - [x] SQL tests on a local copy of the database.
- **Out of scope:** any app code.
- **Done when:** all SQL tests pass on the local copy: posting twice makes one post; discard and share at the same moment → only one wins; share after discard is refused; the minute job posts with the same tags and notifications as the app would; cleanup never lists posted files or another user's files; a follower can't see draft files.
- **Verify:** run the SQL tests locally and show you the output. **I ask you first:** editing old migration files to match the live database, turning on `pg_cron`, and changing the live database.

### Phase 2: Draft saved on the phone
**Status:** [x]
- **Goal:** a new post is saved on the phone as you write and comes back when you open New post again.
- **Depends on:** Phase 0 (works without Phase 1: nothing uploads yet).
- **Spec refs:** `docs/specs/post/screens/s1-new-post.md` (dirty close, strings).
- **Tasks:**
  - [x] Draft saved per user: caption, photos, order, place, audience, comments, feeling, tags.
  - [x] Picked files are moved (not copied) into the app's own folder, so they survive a restart; that folder is left out of phone backups.
  - [x] Saves itself on every change, and when the app goes to the background.
  - [x] Opening New post restores the draft, or starts a new one.
  - [x] Close dialog: Save draft / Discard post / Keep editing (new EN strings, AR tagged `x-review`).
  - [x] Share still works like today.
- **Out of scope:** uploading on attach, server drafts, edit post (unchanged).
- **Done when:** write a post, add photos, kill the app, open New post → everything is back; Discard post → the draft and its files are gone; another user on the phone sees no draft.
- **Verify:** unit tests (save, restore, per-user), widget tests (dialog EN + AR/RTL, restore); `fvm flutter analyze`; `fvm flutter test`. **I ask you first:** the dialog design, the Arabic wording, adding `path_provider`, and the backup settings in `AndroidManifest.xml`.

### Phase 3: Upload when you pick a photo
**Status:** [x]
- **Goal:** each photo starts uploading as soon as you pick it, and editing never uploads again.
- **Depends on:** Phases 1 and 2.
- **Spec refs:** `docs/specs/post/screens/s1-new-post.md` (media strip); `docs/plans/media-upload-plan.md` (the upload path reused).
- **Tasks:**
  - [x] The first picked photo opens the draft on the server.
  - [x] Each photo gets its own id, so its server file name never changes when photos move.
  - [x] Upload starts on pick, at most 2 at a time; videos are shrunk first, one at a time.
  - [x] Removing a photo stops its upload; if it already reached the server, it is deleted.
  - [x] A late answer for a removed photo is ignored, and its file deleted.
  - [x] Each photo shows its progress, and a failed one can be tapped to retry. [user 2026-10-20: no progress while uploading; only a failed photo is dimmed with a retry badge]
- **Out of scope:** Share (Phase 4), discard on the server (Phase 5).
- **Done when:** pick 3, remove 1 mid-upload, move another, edit the text → exactly 2 files on the server, each uploaded once.
- **Verify:** unit tests (add/remove/move/edit, late answers, retry); widget tests (tile states, RTL); `fvm flutter test`. **I ask you first:** how progress and a failed upload look on each photo.

### Phase 4: Share through the server
**Status:** [x] (the airplane-mode check on a phone is still yours)
- **Goal:** Share posts the draft once, through the server.
- **Depends on:** Phase 3.
- **Tasks:**
  - [x] Share closes New post at once and saves the post's details on the server; Home shows "Posting…" with progress (today's banner).
  - [x] When every photo is uploaded, the app calls publish (the minute job is the backup).
  - [x] Lost answer or timeout → ask the server "did it go out?" before trying again.
  - [x] After posting: draft and local files removed, the post appears in the feed.
  - [x] Remove the old create path (`CreatePostUseCase`).
- **Out of scope:** several posts in line (Phase 7).
- **Done when:** sharing with airplane mode turned on right after the tap still gives exactly one post.
- **Verify:** unit tests (wait for uploads, timeout, double tap); `fvm flutter test`; you try it on a phone.

### Phase 5: Discard and cleanup
**Status:** [x] (the offline check on a phone is still yours)
- **Goal:** Discard post is final, and the files are deleted from the server.
- **Depends on:** Phase 4.
- **Tasks:**
  - [x] Discard is saved first, then New post closes at once.
  - [x] Uploads stop; the server marks the draft discarded.
  - [x] The app deletes the files the server lists, then the server confirms they are gone (and checks again a day later for late uploads).
  - [x] Offline discard finishes the next time the app is online (the banner is gone at once).
  - [x] If the post already went out, you're told so, and nothing is deleted.
  - [x] A post the server rejected shows "Couldn't post" on the banner with Discard only.
  - [x] Discard from Home's banner when posting failed.
- **Out of scope:** restart recovery (Phase 6).
- **Done when:** discard during an upload, or while offline then back online → no files left on the server, and the draft can't be posted.
- **Verify:** unit tests (discard before/during/after upload, offline, cleanup failure retried); `fvm flutter test`.

### Phase 6: Restart and sign-out
**Status:** [x] (a shared post continues when its author signs back in; see B14)
- **Goal:** nothing is lost when the app restarts, and accounts never see each other's drafts.
- **Depends on:** Phase 5.
- **Tasks:**
  - [x] On app start and resume: ask the server what is missing first, then upload only that; unfinished posting and discards finish.
  - [x] Never resume a draft the server says is discarded or posted.
  - [x] Sign-out: another user never sees your drafts or pending posts. Draft uploads pause and continue when you sign back in; shared ones still post under your account.
  - [x] An unreadable saved list is rebuilt from the server, never deleted blindly.
  - [x] Left-over local folders with no draft are deleted.
  - [x] Update `CLAUDE.md` (Known state) and `docs/specs/post/00-data-layer.md`.
- **Out of scope:** uploads while the app is asleep.
- **Done when:** kill mid-upload and reopen → the upload continues; user A → user B → user A → B never sees A's draft and A's draft is back.
- **Verify:** integration test (`bootApp`: compose → "kill" → reopen → share → one post); `fvm flutter test`.

### Phase 7: Several posts in line
**Status:** [x]
- **Goal:** you can share a new post while the last one is still uploading.
- **Depends on:** Phase 6.
- **Spec refs:** `docs/specs/home` (publish banner).
- **Tasks:**
  - [x] Shared posts go out in the order you shared them; their files share the same "2 at a time" upload limit.
  - [x] Up to 3 posts waiting (the server's limit); a 4th Share shows a notice.
  - [x] Home shows "2 posts posting".
  - [x] Retry and Discard work per post.
- **Done when:** share 2 posts with videos one after the other → both appear, in order, once each.
- **Verify:** unit tests (queue order, one fails and the next continues); widget tests for the banner; `fvm flutter test`. **I ask you first:** the banner design for more than one post.

## What it can't do
- Uploads stop when the app is closed or the phone sleeps; they continue the next time you open the app.
- Old files are cleaned only when you open the app.
- Other phones signed in to your account don't see a post that is still uploading.
- Editing an existing post works like today (no draft).

## For the builder

Facts checked 2026-10-16; re-check each one at the phase that uses it.

- **B1 — Migration drift.** Live has 20 migrations, the repo 19 (`username_exists` only live). Reconcile before adding the new migration.
- **B2 — Publishing as the author from `pg_cron`.** `store_post_tags` calls `can_tag`, which reads `auth.uid()`; with no `auth.uid()` every tag is dropped **silently**. The minute job sets `request.jwt.claims` per row (`set_config(..., true)` with `sub` = author, `role` = authenticated) inside a sub-transaction and calls the unchanged `create_post` / story insert. Prove on the local stack that `auth.uid()` returns that id. Notifications use explicit ids (`notify_on_post`, `notify_on_tag`), so they fire as today. A failing row → `rejected` with its SQLSTATE; the others still publish.
- **B5 — Server checks at publish.** Match each expected file (incl. video frame) in `storage.objects` by bucket, name, `owner_id = author`, size and type. `create_post` today checks `path` exists but not `thumb_path` or owner. Pending rows: payload ≤ 64 KB, read with a fixed key list (never `jsonb_populate_record`); ≤ 3 waiting per author; same id + same request → returns the current state, same id + different request → `22023`, other author → `42501`; visibility resolved when shared and stored. Story insert repeats the RLS path rule (a definer bypasses RLS).
- **B8 — Device file folder and backup.** `applicationSupport/…/<uid>/<id>/`; after a move/copy check size > 0, = source and ≤ 50 MB; need free space ≥ 2 × source. Exclude from backup: iOS `isExcludedFromBackup`, Android `dataExtractionRules` (API 31+) and `fullBackupContent`. `AndroidManifest.xml` sets no backup rules today.
- **B9 — Phase 1 as built (2026-10-20).** Migration `20261020132458_content_publishing.sql` (live), tests `supabase/tests/content_publishing_test.sql` (pgTAP, 77) and `content_publishing_race.sh` (two sessions). Repo migrations were renamed to the live versions (B1 done). Table `pending_content`, RPC access only. RPCs: `open_draft(id, kind)`, `share_content(id, kind, request)`, `publish_content(id)`, `discard_content(id, kind)`, `content_status(ids | null)` (state, error_code, missing files), `content_cleanup_list(limit)`, `confirm_content_cleanup(id)`; each returns the state as text. Request keys are listed above `share_content`; every file needs `mime`, `size` may be null (a video still shrinking at Share). A story's files must be `{uid}/stories/{storyId}.ext` and `{storyId}_thumb.jpg` (today's app names them with a random stem). Choices to confirm: the 3-waiting limit counts posts and stories together; the server also keeps post order (a post waits while an older shared post is waiting); `create_post` also refuses rejected and abandoned ids; a published item is never cleaned (removed photos are deleted by the app). Local stack: colima + `supabase start`; `supabase test db` can't mount `~/Documents` under colima, so run `docker exec -i supabase_db_pulse psql -U postgres -X -q -t -A < supabase/tests/content_publishing_test.sql`.
- **B10 — Phase 2 as built (2026-10-20).** `PostDraftDatasource` (`features/post/data/datasource/post_draft_datasource.dart`): record under `StorageKeys.postDraft(uid)` (file names only), files in `{applicationSupport}/post_drafts/{uid}/{draftId}/`; the draft id is the future post id. `AppFolders` (core, pre-resolved at start-up) knows the support and temporary folders: only the app's own temporary copies are moved, anything else is copied. Backups: Android `res/xml/data_extraction_rules.xml` + `backup_rules.xml`; iOS `BackupPlugin.swift` (`pulse/backup`). `AddEditPostCubit` saves 400 ms after a change, at Save draft, when the app is hidden and on close; Share forgets the record at once and deletes the folder after the post is out. Not handled yet: a shared post that fails and is then discarded from Home leaves its folder (Phase 6 deletes left-over folders). Close dialog: `ConfirmationDialog.choice` (core) with `DialogChoice`; the old `newPostDiscardTitle`/`Body` strings are replaced by `newPostDraftTitle`/`Body`, `newPostSaveDraft`, `newPostDiscardPost` (the s1 spec table still lists the old keys).
- **B11 — Phase 3 as built (2026-10-20).** `MediaUploadQueue` (`shared/content/data/repository`, one per New post screen): at most 2 at a time, in order; a file is sent as `{uid}/{postId}/{mediaId}.{ext}` (+ `_thumb.jpg`), `mediaId` a uuid made at pick and kept in the draft (`PostDraftMediaModel.id`), so moving a photo never re-uploads; files already in the folder are skipped (one listing per folder). Remove cancels (`CancelSignal` → `http.AbortableStreamedRequest`, no retry after a cancel), then lists the folder again and deletes that file and its frame. Upload starts once the file is read (a video after its frame is in the draft folder). The first upload calls `open_draft` (`PendingContentDatasource`, best effort). Closing New post stops the uploads; opening the draft again resumes only what is missing. Share (still `CreatePostUseCase` until Phase 4) waits for running uploads, then sends nothing twice. There is no reorder UI (not specced); a failed upload shows the feed's retry badge with `ic_upload`. `PostDraftRepository` (`features/post/data/repository`, one per New post screen) combines the device draft (`PostDraftDatasource`, debounced save), the queue and the server draft; `AddEditPostCubit` only calls it, and builds what it sends with the pure `PostSubmission` (`presentation/utils`).
- **B12 — Phase 4 as built (2026-10-20).** `PostShareRepository` (`features/post/data/repository`) runs one Share: works out each file's name, type and size (`ContentMediaRepository.target`, the same decision `send` makes; null size for a video that will be shrunk or a frame made at upload), `share_content` with `PostShareRequestModel`, waits for the draft's own uploads (`beforeUpload`), sends what is missing, `publish_content`. Retry runs it all again: the request is rebuilt the same, so `share_content` answers `published` for a post that already went out and nothing is sent again. A `NetworkFailure`/`TimeoutFailure` (share and publish time out after 20 s) asks `content_status` first: share counts when the server says waiting or published, publish only when published; otherwise the failure is kept for Retry. Publish answering `waiting` (a file not as shared, or an older shared post first) fails with `ServerFailure`; a rejected post fails the same way until Phase 5 shows "Couldn't post". `PostDraftRepository.share` calls it and then deletes the draft folder. Discard on Home after a failure calls `discard_content` (best effort, `ContentPublishRepository.enqueue(onDiscard:)`) and deletes the folder, so a failed post can't go out later or hold up the next one; Phase 5 still has to retry it offline and clean the server files. `PostsDatasource.createPost` is gone too (it had no other caller); Edit post still uses `update_post`.
- **B13 — Phase 5 as built (2026-10-20).** `ContentDiscardRepository` (`shared/content/data/repository`, app-wide): `save` puts `{id, kind}` on a per-user device list (`ContentDiscardsDatasource`, `StorageKeys.contentDiscards(uid)`) before anything else; `send` calls `discard_content` (20 s timeout), forgets the saved one, then sweeps: every saved discard, then `content_cleanup_list` → remove those paths → `confirm_content_cleanup`. A discard the server can't be told stays saved, marks its kind waiting and listens to `ConnectivityService.connectionHints` until it goes. `FinishDiscardsUseCase` runs a sweep when Home opens (Phase 6 adds resume). `ContentPublishRepository` takes `pendingId`; discarding a failed job saves, runs `onDiscard` (device files), then sends; a `published` answer fires `ContentDiscardRefused` (Home: notice + feed reload). With no job, a waiting discard shows as `ContentDiscarding` ("Discarding…", logo preview: the device files are already gone), which never blocks a new Share. `RejectedFailure` (core): publish answering rejected/discarded/abandoned, or any failed share/publish whose `content_status` says so; `ContentPublishFailed.canRetry` is false and the banner shows Discard only. New strings `postPublishDiscarding`, `postDiscardTooLate` (AR `x-review`). Not done: stories don't use it yet; a discard whose device save fails is lost if the app closes while offline.
- **B14 — Phase 6 as built (2026-10-20).** Share saves the post in a per-user shared list (`PostDraftDatasource.saveShared`, `StorageKeys.postShared(uid)`, a `PostDraftModel` per post) before anything else, forgets the draft, then saves it again once its files are read; it is forgotten with its folder when it is out or discarded. `SharedPostsRepository` (`features/post/data/repository`, singleton) does that and `resume()`: when Home opens, one `content_status` for the shared posts and the draft; published/discarded/abandoned → forgotten (published also reloads the feed); anything else → enqueued again with the post rebuilt from the record (same request, so `share_content` accepts it), skipped when already in memory (`ContentPublishRepository.hasJob`); a finished draft is forgotten; then `deleteFoldersExcept` the draft and the shared posts. An unreadable list (`readShared()` null) deletes nothing the server has not finished: waiting items get `publish_content`, folders of unfinished items stay; offline nothing is deleted. `ResumeContentUseCase` (shared; Home start and `OnAppShown`): `useAccount(uid)` on the publish and discard repositories (another user's jobs are dropped silently, their late answers ignored), `retryLost()` (network/timeout failures), `sendSaved()`. Leftover folders are cleaned only at start, never on resume (an open New post may not be saved yet). Deviation: a post shared by A keeps uploading after sign-out only until the session is gone; it continues when A signs back in (or the minute job posts it when its files were all up). Truly continuing under A's account would need signed uploads (not planned). The "ask the server what is missing" step is the folder listing `PostShareRepository` already does, not `content_status.missing`.
- **B15 — Phase 7 as built (2026-10-20).** `ContentPublishRepository` keeps a line per `ContentKind`: posts take up to 3 (the server's limit), a short or story 1. One job runs at a time per kind in the order shared; a failed job does not stop the next (but the server keeps post order, so the next one's publish answers waiting and fails until the failed one is retried or discarded). `retry`/`discard` take an optional `id` (the pending id). `current(kind)` is still the one status (story rail, notices); `line(kind)` / `ContentPublishLine` on the `EventBus` (items waiting/sending/failed/done) feeds the banner through `PostLineCubit`; done posts stay in the line until the next post starts, and `PostLineCubit` hides "All posted" 1.5 s after the last one. A network/timeout failure listens to `ConnectivityService.connectionHints` and goes again by itself (`retryLost`). A 4th Share keeps New post open with `newPostPublishBusy` (text changed to "3 posts waiting"). Banner (`publish_banner/`): one post = the old card; several = one card with stacked pictures, "Posting N posts…", the line's progress, a chevron to a row per post, amber outline and the failed row when one failed, "Waiting for connection" when all are offline. Not done: "Edit post" on a failed row, 3 automatic tries with backoff, the "3 posts shared" notice (each post still shows "Post shared"), captions on rows (they read "Post N"). File uploads of a shared post still run one at a time beside the draft's own 2.
- **Saved jobs.** SharedPreferences is enough: one versioned JSON per user, written whole, saved before each side effect; every server call is safe to repeat; native tasks are matched by id prefix. On an unreadable store, rebuild from the server and the uploader's active tasks; delete a folder only when the server says it is finished and no task uses it.
