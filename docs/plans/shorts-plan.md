# Shorts — what the user will see

Source specs: `docs/specs/shorts/`, `docs/specs/_theme/`
Status: draft 2026-11-06. Phases: [x] 0 · [ ] 1 · [ ] 2 · [ ] 3 · [ ] 4 · [ ] 5 · [ ] 6 · [ ] 7
Mode: one-by-one

## Today's problem

The Shorts tab and New Short route are placeholders. The app has shared video publishing pieces, but no Shorts feed, one-video creation flow, or 60-second Short rules.

## The new story

**1. You open Shorts**

→ You see a fixed navigation bar below one vertical video at a time.
→ Following and For you load newest eligible Shorts; a new public Short is eligible for For you immediately.
→ The visible video loops, tap pauses it, and mute applies for this viewing session.

**2. You create a Short**

→ You record up to 60 seconds, choose a video, or select a recent video.
→ A gallery video over 60 seconds must be trimmed before it can be shared.

**3. You edit and share**

→ You add a caption, audience, tags, location, feeling/activity, and comments setting.
→ Upload failure keeps the editor and allows retry.
→ Sharing returns to an updated Shorts feed.

**4. You use actions**

→ Follow, like, comments, sharing, reporting, muting, hiding, deleting, and audience changes reuse the existing content flows.
→ Editing a published Short changes metadata only; its video, trim, and original audio do not change.

## Safety

- Shorts use the existing private-account, accepted-follow, block, mute, hide, report, deletion, and visibility rules.
- The app rejects videos over 60 seconds; the publish RPC also rejects submitted Short metadata outside that limit.
- A Short remains one video only, stored and signed through the existing Supabase Storage path.

## Waiting on you (the blockers, in plain words)

- Approval to apply the new database migration live — blocks Phase 1 completion — needed from you.
- Android and iOS devices for final playback checks — blocks Phase 7 completion — needed from you.

## Phases (one by one: I stop after each phase for your review)

### Phase 0: Save the plan

**Status:** [x]

- **Goal:** the plan is saved.
- **Tasks:**
  - [x] Save this plan.
- **Done when:** this file exists in `docs/plans`.
- **Verify:** reopen the saved file.

### Phase 1: Short server rules and feed

**Status:** [ ]

- **Goal:** the server can publish, update, and page eligible Shorts safely.
- **Depends on:** Phase 0.
- **Spec refs:** `docs/specs/shorts/00-overview.md`; `screens/s1-shorts-feed.md`; `screens/s3-short-editor.md`.
- **Tasks:**
  - [ ] Add newest-first Shorts feeds for Following and For you.
  - [ ] Enforce one video and submitted duration of 1–60 seconds when publishing.
  - [ ] Add metadata-only edits for an owner’s Short.
  - [ ] Add SQL coverage.
- **Implementation steps:**
  1. `supabase/migrations/<timestamp>_shorts.sql` (new): add `shorts_feed(p_mode, p_limit, p_before_created, p_before_id)`, returning the existing post-feed row shape for `kind = 'short'`.
  2. Same migration: Following includes own and accepted-follow authors; For you includes every immediately viewable public Short. Both exclude hidden, reported, muted, blocked, deleted, and inaccessible content.
  3. Same migration: order both modes by `created_at desc, id desc`; use those values as the keyset cursor.
  4. Same migration: extend the shared publish path to reject a Short unless it has exactly one video and `duration_ms` is within 1–60,000. Posts and Stories keep their current limits.
  5. Same migration: add `update_short_metadata(...)` for caption, location, tags, feeling/activity, comments, and audience; it never accepts media or trim replacement.
  6. `supabase/tests/shorts_test.sql` and its runner (new): cover visibility, private accounts, accepted follows, blocks, mutes, hides/reports, cursors, invalid duration metadata, and immutable video edits.
- **Tests:** the new Shorts SQL tests and existing content-publishing tests.
- **Out of scope:** live migration application without approval.
- **Done when:** both feeds return only eligible Shorts; invalid duration metadata is rejected.
- **Verify:** run local Supabase SQL tests. Ask before applying the migration live.

### Phase 2: Shared navigation update

**Status:** [ ]

- **Goal:** the shared navigation is fixed below every tab’s content rather than floating over it.
- **Depends on:** Phase 0.
- **Spec refs:** `docs/specs/shorts/00-overview.md`; `screens/s1-shorts-feed.md`; control-shell behavior.
- **Tasks:**
  - [ ] Replace the floating glass layout with a fixed shared navigation layout.
  - [ ] Preserve tab state, root-navigator create flows, back behavior, and keyboard handling.
  - [ ] Update control-shell regression tests.
- **Implementation steps:**
  1. `lib/features/control/presentation/view/control_view.dart` and navigation widgets (edit): lay out each tab above a fixed shared nav; remove scroll-hiding that would leave Shorts controls unavailable.
  2. `lib/features/control/presentation/dimens/nav_dimens.dart` and control widgets (edit): preserve bottom clearance through `NavClearance` and `AppSafeArea`.
  3. Control tests (edit): cover every tab, re-tap, keyboard, back, Create, safe-area clearance, and the fixed nav.
- **Tests:** existing control Cubit and widget tests.
- **Out of scope:** new Chat functionality.
- **Done when:** no tab content appears under the navigation bar.
- **Verify:** `fvm flutter analyze`, control tests, and device checks across Home, Shorts, Chat, and Profile.

### Phase 3: Shorts data and state

**Status:** [ ]

- **Goal:** Shorts can load, refresh, cache, and react to shared content changes.
- **Depends on:** Phase 1.
- **Spec refs:** `screens/s1-shorts-feed.md` > Data mapping and States.
- **Tasks:**
  - [ ] Add Shorts models, datasource, cache, repository, and Cubit.
  - [ ] Reuse signed media URLs and shared content-change events.
  - [ ] Keep the most recently loaded Short available offline.
- **Implementation steps:**
  1. `lib/features/post/data/model/post_model.dart` and feed mapping (edit): expose `ContentKind` so shared feed rows distinguish posts from Shorts.
  2. `lib/features/shorts/data/datasource/shorts_datasource.dart` (new): interface plus Supabase adapter for `shorts_feed`; reuse `PostsDatasource.signMediaUrls`.
  3. `lib/features/shorts/data/repository/shorts_repository.dart` (new): combine remote pages, signed URLs, and a per-user `SnapshotStorage` cache without storing signed URLs.
  4. `lib/features/shorts/presentation/cubit/shorts_feed/` (new): loading, retry, refresh, mode switching, paging, offline retained item, and `ContentChanged(ContentKind.short)` handling.
  5. `lib/core/services/storage/storage_keys.dart` and DI only where required (edit): add a per-user Shorts snapshot key.
- **Tests:** datasource, repository, and Cubit tests for pages, cursors, empty Following, retry, offline cache, and content changes.
- **Out of scope:** player UI.
- **Done when:** a previously loaded Short remains viewable offline.
- **Verify:** focused tests and `fvm flutter analyze`.

### Phase 4: Shorts feed

**Status:** [ ]

- **Goal:** the Shorts tab is a readable, paged, one-video feed.
- **Depends on:** Phases 2–3.
- **Spec refs:** `screens/s1-shorts-feed.md`; `01-design-tokens.md`; `02-components.md`; `screenshots/s1-shorts-feed.png`.
- **Tasks:**
  - [ ] Replace the Shorts tab placeholder.
  - [ ] Build the header, segment, player, action rail, metadata, and progress UI.
  - [ ] Add autoplay, loop, pause, mute, lifecycle disposal, and non-9:16 presentation.
  - [ ] Wire existing profile, follow, like, comments, share, options, report, and delete flows.
- **Implementation steps:**
  1. `lib/features/shorts/presentation/screen/shorts_screen.dart` and `view/shorts_view.dart` (new): provide the Cubit and render S1 above `NavClearance`.
  2. `lib/features/shorts/presentation/widgets/` (new): `shorts_segment`, `short_player`, `short_action_rail`, `short_meta`, and `video_progress`; use existing video controller abstractions and signed URLs.
  3. `lib/features/shorts/presentation/utils/short_video_coordinator.dart` (new): keep only the visible page playing; pause on tab/app inactivity; dispose replaced controllers; retain session mute.
  4. `lib/features/control/presentation/screen/control_screen.dart` (edit): replace the Shorts placeholder and remove its resolved TODO markers.
  5. `lib/l10n/app_en.arb` and `app_ar.arb` (edit): add S1 strings; keep Arabic marked `x-review`.
- **Tests:** widget tests for states, paging, semantics, RTL/LTR timeline behavior, player lifecycle, and action routing.
- **Out of scope:** creation flow.
- **Done when:** S1 acceptance checklist passes; a non-9:16 video is never cropped.
- **Verify:** analyzer, focused tests, and side-by-side device comparison with S1 in English and Arabic.

### Phase 5: New Short source selection

**Status:** [ ]

- **Goal:** users can record or choose exactly one video for a new Short.
- **Depends on:** Phases 1 and 4.
- **Spec refs:** `screens/s2-new-short.md`; `screenshots/s2-new-short.png`.
- **Tasks:**
  - [ ] Replace `/create/short` placeholder with S2.
  - [ ] Add video-only gallery and recent-video selection.
  - [ ] Add a 60-second Story-camera mode without changing normal Story photo capture.
  - [ ] Require trim for selected videos over 60 seconds.
- **Implementation steps:**
  1. Add the approved `photo_manager` dependency and platform permissions; expose video-only recent media through `MediaPickerService`.
  2. `lib/features/shorts/presentation/screen/new_short_screen.dart`, view, Cubit, and source widgets (new): build S2, permission states, empty recents, discard handling, and navigation.
  3. Story camera routes and state (edit): add a Short capture mode with title “New short”, video-only capture, and a hard 60-second recording limit; keep Story mode unchanged.
  4. Short draft model/state (new): carry the selected video’s path, dimensions, duration, poster, and trim range into S3.
  5. l10n files (edit): add S2 strings and Arabic drafts.
- **Tests:** source Cubit/widget tests, permission-denied state, video-only filtering, cancel/discard, exactly-60-second recording, and over-limit trim requirement.
- **Out of scope:** Short publishing.
- **Done when:** Record, Upload, and the recent-video grid work; images cannot enter the flow.
- **Verify:** analyzer, focused tests, and comparison with S2 screenshot.

### Phase 6: Short editor and publishing

**Status:** [ ]

- **Goal:** a user can trim, describe, publish, retry, and later metadata-edit a Short.
- **Depends on:** Phases 1 and 5.
- **Spec refs:** `screens/s3-short-editor.md`, post composer specs, Story trim behavior.
- **Tasks:**
  - [ ] Build S3 around one video.
  - [ ] Reuse post audience, tags, location, feeling/activity, comments, and publishing flows.
  - [ ] Compress and trim with `VideoCompressService` before shared upload.
  - [ ] Add metadata-only owner edit from Short options.
  - [ ] Leave `// TODO(shorts-plan T1): selectable music library is deferred; Shorts use original audio only.` at the audio row.
- **Implementation steps:**
  1. `lib/features/shorts/presentation/cubit/add_edit_short/` and editor screen/view (new): own the draft, trim range, caption, audience, add-ons, dirty confirmation, upload progress, failure, and retry.
  2. Reuse `VideoCompressService.VideoEdit`, Story trim controls, `ContentMediaRepository`, `ContentPublishRepository`, and existing post audience/tag/location/feeling interfaces.
  3. `lib/features/shorts/data/repository/short_publishing_repository.dart` (new): convert the final single-video draft into the shared publish request with `ContentKind.short`.
  4. Router files (edit): add `/create/short/edit`; replace the create placeholder; refresh Shorts when publishing succeeds.
  5. Short options/edit widgets (new): call `update_short_metadata`; show an immutable media preview and never expose replacement or re-trimming.
  6. l10n files (edit): add S3, retry, discard, immutable-media, and Short-options strings.
- **Tests:** Cubit tests for trim bounds, dirty exit, publish success/failure/retry, media immutability, and metadata update; widget tests for editor semantics and share-disabled state.
- **Out of scope:** selectable music.
- **Done when:** a valid trimmed video publishes once; a failed share preserves the editor.
- **Verify:** analyzer, focused tests, and publish/retry checks against a local Supabase stack.

### Phase 7: Polish

**Status:** [ ]

- **Goal:** Shorts work consistently across devices, languages, states, and lifecycle changes.
- **Depends on:** Phases 2–6.
- **Spec refs:** all Shorts screen acceptance checklists; `_theme/rtl.md`.
- **Tasks:**
  - [ ] Check every Shorts acceptance checklist and saved screenshot.
  - [ ] Test app/tab lifecycle, buffering, signed-URL refresh, controller disposal, and offline item retention.
  - [ ] Check RTL, 1.5 text scale, screen-reader labels, and minimum targets.
  - [ ] List remaining `TODO(shorts-plan ...)` markers and reconcile them with this plan.
- **Implementation steps:**
  1. `grep -rn "TODO(shorts-plan" lib` and reconcile every result with the Code TODOs table.
  2. Review S1 and S2 against their saved screenshots in English and Arabic; correct layout, visibility, and mirroring in the affected files.
  3. Test Android and iOS with portrait, non-9:16, network loss, playback buffering, backgrounding, and tab switching.
  4. Update `CLAUDE.md` Known state after the feature is complete.
- **Tests:** full `fvm flutter test`, `fvm flutter analyze`, and Shorts SQL tests.
- **Out of scope:** a new music catalog.
- **Done when:** all acceptance checks pass and no Shorts TODO marker lacks a matching plan row.
- **Verify:** run the app on physical Android and iOS devices in English and Arabic.

## What it can't do

- A selectable music library is deferred; Shorts use original video audio only.
- Server duration validation follows the existing posts/stories metadata model; it cannot independently inspect a deliberately falsified video file without a separate media-processing service.

## For the builder

### Reuse (existing widgets/theme/services to use)

`ContentKind.short`, `ContentMediaRepository`, `ContentPublishRepository`, `ContentChangesRepository`, `PostsDatasource`, `PostModel`, `VideoCompressService`, Story camera and trim controls, post audience/tag/location/feeling/comment interfaces, `AppVideoController`, `AppSafeArea`, `NavClearance`, `SnapshotStorage`, `AppSvgIcon`, `AppText`, and existing post options/action flows.

### Blockers (item | blocks phase | needed from | status)

| id | item | blocks | needed from | status |
|---|---|---|---|---|
| B1 | Live database migration approval | 1 | you | open |
| B2 | Physical Android and iOS checks | 7 | devices | open |

### Code TODOs (id | what is pending | the code it sits in | phase)

| id | what is pending | code | phase |
|---|---|---|---|
| T1 | Selectable music library | Short audio row | 6 |
| T2 | Arabic copy review | no code marker; ARB `x-review` entries | 4–6 |

### Verification

Each phase runs `fvm flutter analyze` and its listed focused tests. Server phases run local SQL tests. Screen phases compare against the saved Shorts screenshots. Final verification runs the full Flutter suite and Android/iOS device checks in English and Arabic.
