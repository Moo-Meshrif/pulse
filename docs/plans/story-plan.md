# Plan: story
Source specs: docs/specs/story/ (exact values: `source-tokens.md`, which wins over `01-design-tokens.md`), docs/specs/_theme/
Status: approved
Mode: one-by-one
Tests: cubit + widget tests in each phase (mirror `lib/` under `test/`, helpers in `test/helpers/pump_app.dart`, datasource tests with `test/helpers/backend_double.dart`; widget tests EN + AR/RTL + 1.5x text)

## Progress (updated 2026-10-14)
Phases 0-3 are done; Phases 4-11 are built and tested on doubles, and only the device / live-data checks (B7) stay open. Nothing left to implement here except the shared-code follow-ups below. Pending with the shared refactor ("Shared code update" at the end): move the dark confirm dialog and the option / audience rows to core widgets (needs a decision on the dark dialog look), optionally move the close-friends list into `lib/shared/content`, (the migrations `20261018120000_post_visibility.sql` and `20261019120000_shared_content_actions.sql` are applied; story code calls `report_content`, `set_content_audience`, `set_mute(p_scope)`).

## Later changes
- The temporary Home rail (Phase 9's tile, ring and its Cubit) was removed after device testing. The Home tab is the control-page placeholder again; nothing in the app opens the story screens until Home's real rail is built (the routes `/story/:id`, `/create/story` still work).

## Later additions (board v3)
- Who can see this + Close friends + Hide story from (`docs/specs/story/screens/s7-who-can-see.md`): code and tests done; **migration `20261015120000_story_audience.sql` is applied** (linked project history `story_audience`). Viewers sheet is dark.

## Summary
- **Screens:** S1 story viewer (panel 1 others', panel 2 own + count chip), S6 viewer options / report / delete / viewers sheet, S5 camera and microphone permissions (shared: story, short, profile photo), S2 camera and recording, S3 edit and share, S4 posting state on the rail.
- **Goal:** 24-hour photo and video stories: watch a person's stories with gestures, like, mark seen, manage your own (viewers, save, delete), mute or report others; create from camera or gallery with text and location stickers; upload in the background with real progress on the rail.
- **Out of scope** (specs): replies (go to Chat later, `00-overview`, Q3), audience picker and audience column (Q18, read-only row now), the Home rail UI (home feature; a temporary rail stands in, P2), Create sheet Story row (Q2: none), Copy link (P5, hidden), video burn-in on save (P4).
- **Build order** (progress.md): control-page (done), story, post, home.

## Reuse
- Theme: `AppColors` already has `primary`, `primarySoft`, `storyRing`, `background`, `surface`, `textPrimary`, `textSecondary`, `border`, `like`, `danger`, `dangerSoft`, `warningInk` (#B26F12, failed ring), `scrim`. Check each §9 color of `source-tokens.md` against these before adding; add only what is missing.
- `AppSpacing` / `AppRadius` / `AppShadows` / `AppScale` (scaled getters; fixed values carry `// unscaled: <reason>`, enforced by `no_unscaled_literals_test`), `context.text` styles (Sora: `title` 22/700, `titleSm` 20/700, `stat` 18/700; `name` 15/700, `button` 16/700, `caption` 12, `action` 14/700), `context.appColors`, `context.l10n`.
- Widgets: `AppBottomSheet` (sheet shell), `AppDialogShell` + `ConfirmationDialog` (destructive), `AppSafeArea`, `AppPage`, `AppSvgIcon`, `AppText`, `PrimaryButton`, `PillButton`, `AppTextField`, `PulseLineLoader` (takes `color` + `width`), `AppEmpty`, `NavClearance`, `PlaceholderScreen`.
- `context.showSnackBar` / `showFailure` (`lib/core/extensions/snack_bar_context.dart`): the "notice" in the specs; it has no action yet (Phase 2 adds one).
- Services: `PhotoPickerService` + `image_picker` (gallery), `LaunchService` (open settings if it fits), `ConnectivityService`.
- Navigation: `AppRoutes`, `AppRouter.onGenerateRoute`, `AppNavigator.push(..., rootNavigator: true)` for full-screen flows (covers the nav, `conventions/navigation.md`).
- State / DI / errors: `BaseCubit.run`, freezed for data states, injectable, `Guard.run`, `Failure`, `failure_l10n`.
- Existing story code: none in `lib/features/` yet; `00-data-layer.md` describes `StoriesDatasource`, `StoryRailItemEntity` (public, returned by `GetStoryRailUseCase`), `StoryMediaType` (own enum, no post import).
- Icons in `AppAssets` already: `close`, `moreHorizontal`, `heart`/`heartFilled`, `share` (send), `eye`, `trash`, `location`, `volume`, `flag`, `globe`, `lock`, `chevronRight`, `camera`, `check`, `plus`. Files present but not registered: `ic_download`, `ic_flash`, `ic_camera_flip`, `ic_text`, `ic_user`, `ic_audience`, `ic_link`, `ic_mic`, `ic_mic_off`, `ic_camera_off`, `ic_volume_off`.

## Blockers
| Id | Item | Blocks phase | Needed from | Status |
|---|---|---|---|---|
| B1 | Migrations (home schema, post options, story extras + P1 changes) reviewed and applied | 3 (live data) and later live checks; tests run on doubles | user review, then apply | **done** [user]: reviewed and applied 2026-10-13 |
| B2 | `video_flux` API must support: play/pause, position stream for the bar, duration, mute, preload; video thumbnail + width/height/duration for upload | 4, 8 | builder checks in Phase 0; report gaps to user | **decided** [user]: `video_player` added; thumbnail package chosen in Phase 8 |
| B3 | Reply send behavior until Chat exists (spec: replies go to Chat; nothing says what Send does now) | 4 | user | **decided** [user]: pill and Send visible, Send shows a "coming soon" notice |
| B4 | Location sticker opens post's Add location (post S3), which is built after story | 8 | user | **decided** [user]: location tool hidden until post S3 exists |
| B5 | Story report "sent" copy `We'll review this story.` | none (ships [estimated]) | user review | open, no code marker |
| B6 | Arabic copy (Q12) drafts `x-review` | none | user review | open, no code marker |
| B7 | Real-device checks: camera, recording, permissions on iOS + Android, saving to gallery, upload on slow network | 11 | user | open |

## Code TODOs
| Id | What is pending | Code it sits in | Phase |
|---|---|---|---|
| B3 | Reply Send has no target until Chat exists | the viewer's reply bar | 4 |
| B4 | Location tool hidden until post's Add location screen exists | the edit screen's tool column | 8 |
| T1 | ~~Temporary rail in the Home placeholder~~ removed after device testing (2026-10-14): Home's real rail will use `GetStoryRailUseCase`, `WatchStoryUploadUseCase`, `RetryStoryUploadUseCase`, `WatchStoryRailChangesUseCase` and `StoryViewerArgs` | the Home tab | 9 |
| T2 | Copy link row hidden: no story link format yet (P5) | the options sheet for someone's story | 5 |
| T3 | Go to profile opens a placeholder until the profile screens exist | the options sheet's Go to profile action | 5 |
| T4 | Video saved without overlays; burn-in later (P4) | the save-to-device action | 5 |
| T5 | ~~"Who can see this" read-only~~ done: picker, lists and audience column (`s7-who-can-see.md`); the migration `20261015120000_story_audience.sql` waits for approval before it is applied | the own-story options sheet | 5 |
| T6 | Report sheet: post adds its Mute / Unfollow rows to the sent step when the post feature is built (P6) | the shared report sheet | 2 |
| T7 | Permission screens also serve the short and profile-photo camera flows; only story uses them now | the shared permission flow | 6 |
| T8 | ~~Hero from the rail avatar~~ done as a grow from the tapped point (`StoryPageRoute`), no marker left; Home's real rail passes the same point | the viewer's open transition | 11 |
| T9 | Arabic copy review (B6) | ARB files | no code marker |
| T10 | Story report sent copy [estimated] (B5) | ARB files | no code marker |

## Phases

### Phase 0: Prerequisites
**Status:** [x] done (B2 gap still open, see note)
**Goal:** packages, platform permissions, assets, route names and the backend migrations exist.
**Depends on:** nothing.
**Spec refs:** `open-questions.md` (Q11, P1-P4); `../home/schema.sql`; `../home/schema-post-options.sql`; `schema-story-extras.sql`; `screens/s5-camera-permissions.md` > Logic; `assets.md`; `00-overview.md` > Screens and Navigation map.
**Tasks:**
- [x] Add `camera`, `permission_handler`, `video_flux`, `gal` (current stable versions); check B2 against `video_flux` and report any gap before going on.
- [x] Platform: `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, photo-library add permission for saving (iOS); `CAMERA`, `RECORD_AUDIO` and what `gal` needs (Android); `permission_handler` iOS macros for camera + microphone.
- [x] Register in `AppAssets`: `ic_download`, `ic_flash`, `ic_camera_flip`, `ic_text`, `ic_user`, `ic_audience`, `ic_link`, `ic_mic`, `ic_mic_off`, `ic_camera_off`, `ic_volume_off`.
- [x] Route names: `/story/:authorId` (viewer), `/create/story` (camera), `/create/story/edit` (edit); resolved in Phase 10 (placeholders until then).
- [x] Migrations in `supabase/migrations/`, in this order, from the spec files as written: `20261012120000_home_feed.sql` (`../home/schema.sql`), `20261013140000_post_options.sql` (`../home/schema-post-options.sql`; check the timestamp sorts after the existing `20261013130000_legal_documents_more_types.sql`), then story extras with these P1 changes: `story_rail` re-created to also skip authors in `story_mutes` for `auth.uid()`; `story_viewers(p_story, p_limit default 30, p_before timestamptz default null)` returning rows with `viewed_at < p_before`, newest first.
- [x] Stop and ask the user to review the SQL (B1). Apply only after approval (Supabase MCP `apply_migration` or CLI); run the advisors afterwards and report.
- [x] `fvm flutter pub get`, `fvm flutter analyze` clean.
**B2 finding:** `video_flux` 0.0.1 is only a sliding-window preloader (`CustomVideoController`: initialize/play/pause/dispose, no position, duration, mute or seek) and plays nothing itself; it needs a player package behind an adapter (e.g. `video_player`, which gives position, duration, volume) and nothing in it makes thumbnails or reads width/height/duration for upload. **Decided** [user]: add `video_player` behind a `CustomVideoController` adapter (position, duration, volume come from it). A thumbnail / metadata package is still to be chosen in Phase 8.
**Out of scope:** Dart data code, widgets.
**Done when:** packages resolve; icons render through `AppSvgIcon`; migrations written; B1 status updated (applied, or waiting for review).
**Verify:** `fvm flutter analyze`; `list_migrations` shows the three migrations after approval; advisors show no new security errors.

### Phase 1: Theme and tokens
**Status:** [x] done
**Goal:** every story value is a named token; no raw hex or magic numbers in later phases.
**Depends on:** Phase 0.
**Spec refs:** `source-tokens.md` §1-§9 (exact); `01-design-tokens.md`; `_theme/theme-overview.md`, `colors.md`, `typography.md`, `spacing-radius-shadows.md`.
**Tasks:**
- [x] Colors from §9: `storySheet` #1F2423, `storySheetRow` #2A302F, `dangerOnDark` #FF7A7F, `storyWarning` #F2B45A, `storySuccess` #5FD39A, white/black alphas (track 35%, shade 45% / 55%, control 18%, tool 35%), plus the single-use values in §3 (`#FBE4E5` delete circle; check `dangerSoft` first), §4 (camera start gradient #1F2A2C -> #3D4C4F), §7 (permission bg = `textPrimary`, mic pill #1B201F @ 86%, Fix text #9ED3C9). Reuse existing tokens where equal.
- [x] Dimensions and timings from §9 `StoryDimens` / `StoryTiming` plus the per-section values (bars, header, reply bar, viewers sheet, camera top bar and bottom row, edit tools, sheets, delete dialog, permission screen, paused chip), placed per the project's `app_dimens.dart` pattern (scaled getters; unscaled marked).
- [x] Text styles: reuse `title`, `titleSm`, `stat`, `name`, `button`, `caption`, `action`; add only missing ones (Sora 30/700 h1.2 overlay with shadow, Sora 17/700 camera title, 15/800 uppercase sticker text, 12/700 paused chip, 14/700 timer), all `inherit: false`, no color.
- [x] Shadows: sticker `0 6 16` black 25%, text overlay `0 2 12` black 35%.
- [x] Motion constants from §8.
- [x] Document new tokens in `docs/specs/_theme/` (colors, spacing-radius-shadows, typography).
**Out of scope:** widgets.
**Done when:** every value listed in `source-tokens.md` is reachable by token name; analyzer and `no_unscaled_literals_test` pass.
**Verify:** `fvm flutter analyze`; `fvm flutter test test/core`; review the token diff against `source-tokens.md`.

### Phase 2: Shared components
**Status:** [x] done (visual comparison with panel 9 not done: the sheet was not run on a device)
**Goal:** the shared pieces the story screens and the post feature both need.
**Depends on:** Phase 1.
**Spec refs:** `screens/s6-viewer-menus.md` > Panel 9; `../post/screens/s2-post-options.md` rows 3, 3b, 3c, 4 (shared report flow); `source-tokens.md` §5; `open-questions.md` P6.
**Tasks:**
- [x] Notice with an action: extend the app's snackbar helper with an optional action label + callback (story uses Undo after Mute, Retry after a failed upload); keep one way to show transient messages.
- [x] Shared report sheet in `lib/core/widgets/`: reasons step (title, helper, 7 reason rows with chevron, height 52), "Something else" note step (back arrow, autofocus, 500 counter that turns `danger` at 500, Send disabled under 5 characters, button loader), sent step (check icon, title, body, Done). Takes the target's copy (title/body/sent body), a submit callback (reason wire value: spam, nudity, hate, bullying, violence, false_info, other; optional note) and a dark/light tone (story = dark §5 colors; post = light later). Reason enum with wire values in `lib/core/enums/`.
- [x] Leave `// TODO(story-plan T6): post adds Mute / Unfollow rows to the sent step` in the sent step.
- [x] Strings (EN + AR drafts `x-review`) from `s6-viewer-menus.md` and the post spec's report rows; story sent body [estimated] (B5).
- [x] Tests: report sheet steps, note validation, submit callback values, RTL, 1.5x text; snackbar action.
**Out of scope:** where the sheet is opened from (Phase 5).
**Done when:** the report sheet runs all three steps in both tones; the snackbar shows an action and runs it.
**Verify:** widget tests; compare the dark tone with `screenshots/stories-board-v2.png` panel 9.

### Phase 3: Data layer
**Status:** [x] done (`SaveStoryToDeviceUseCase` / `gal` is not covered by tests: needs a device, B7)
**Goal:** all story reads and writes behind use cases, with upload progress.
**Depends on:** Phase 0 (B1 for live checks only), Phase 1.
**Spec refs:** `00-data-layer.md`; `screens/s1-story-viewer.md` > Data mapping; `screens/s3-create-edit.md` > Behavior; `screens/s6-viewer-menus.md`; `schema-story-extras.sql`; `open-questions.md` Q9, Q17, Q20, P1, P3; `source-tokens.md` §10 (signed URLs 3600 s, cache key = path).
**Tasks:**
- [x] Datasource(s) per `conventions/architecture.md` with Supabase adapters: story rail, `author_stories`, signed URLs for `path`/`thumb_path`, mark viewed (insert `story_views`, ignore duplicates), `set_story_like`, `story_viewers` (page 30, cursor `p_before`), delete own story (row; the files go through the shared `RemoveMediaFilesUseCase`), mute and report (now the shared `SetMuteUseCase` / `ReportContentUseCase`, see the 2026-10-14 note), create story (upload `post-media/{uid}/stories/{id}.jpg|mp4` + thumb, then insert `stories` with type, path, thumb_path, width, height, duration_ms, blurhash?, overlays).
- [x] Upload with byte progress (P3): streamed upload to the storage REST endpoint with the existing `http` package and the session token; progress 0..1.
- [x] Wire models + `StoryMediaType` enum (own copy) + overlay model (type text|location, text, x, y fractions, scale, rotation, color; max 20) per `conventions/serialization.md`.
- [x] Use cases only where another feature calls them or a rule needs one: `GetStoryRailUseCase` (maps models to the public `StoryRailItemEntity`), `WatchStoryUploadUseCase` and `RetryStoryUploadUseCase` (Home's rail; the upload status is owned by the story feature as a singleton). Everything else (author stories, mark seen, like, viewers, delete, mute, report, create, save to device, audience) is called by the story Cubits on `StoriesDatasource`, `StoryUploadRepository` and `GalleryService` directly; the pass-through use cases were removed.
- [x] DI registration; `build_runner`.
- [x] Tests with `backend_double`: each call's parameters, failure mapping, upload progress events, retry after failure.
**Out of scope:** UI.
**Done when:** every use case above exists and is tested; analyzer clean.
**Verify:** `fvm flutter test test/features/story/data test/features/story/domain`; after B1, one live smoke call to `story_rail`.

### Phase 4: S1 viewer (playback)
**Status:** [~] built and tested on doubles; not run on a device and the video path is untested (needs a device, B7)
**Goal:** watch a person's stories and move between people.
**Depends on:** Phases 2, 3; B2; B3 decided.
**Spec refs:** `screens/s1-story-viewer.md` (all sections); `source-tokens.md` §2, §2.1, §3 (count chip), §8; `01-design-tokens.md` > Viewer; `screenshots/stories-board-v2.png` panels 1, 2; `_theme/rtl.md`.
**Tasks:**
- [x] Viewer screen + Cubit: playlist per person from the rail order, starting at the first unseen story; image 5 s, video its length (max 60 s) with the bar following playback position; buffering pauses the bar and shows `PulseLineLoader` (width 56, white) after 400 ms.
- [x] Layout: black bg, `BoxFit.cover`, top/bottom shades, progress bars, header (avatar ring, name, relative time, "···", X), reply bar (pill, heart with like pop, send), overlays drawn from JSON (text + location sticker), own story: eye + count chip bottom-start instead of the reply bar.
- [x] Gestures: tap end 2/3 next, start 1/3 previous (swapped in RTL), long press pause with 150 ms UI fade, swipe left/right next/previous person (300 ms), swipe down to close (scale 0.9, threshold 120 or velocity > 700), swipe up on own story opens the viewers sheet (Phase 5 builds it; leave the hook).
- [x] Mark seen after 1 s visible; like optimistic via `SetStoryLikeUseCase`; preload next story and the next person's first story; pause on keyboard, sheet/dialog, app background; resume on `resumed`.
- [x] Media error: blurhash/thumb stays, tap to retry [estimated in S1].
- [x] Reply Send (B3): "coming soon" notice; leave `// TODO(story-plan B3): replies go to Chat when it exists`.
- [x] Light status bar icons, edge-to-edge; safe areas via `AppSafeArea` rules.
- [x] Strings EN + AR drafts; semantics (Close, More, Like, Send, Viewers).
- [x] Tests: Cubit (timing, next/previous/person changes, seen after 1 s, like rollback on failure), widget (layout EN/AR, 1.5x text, RTL tap zones).
**Out of scope:** "···" sheets, viewers sheet, delete (Phase 5); hero from the rail (T8, Phase 11).
**Done when:** S1 acceptance checklist items 1-5 pass; own story shows the count chip.
**Verify:** run the app (entry from Phase 9 or a test route); compare with panels 1, 2.

### Phase 5: S6 viewer menus, viewers sheet, delete, save
**Status:** [~] built and tested on doubles; not run on a device (sheets, dialog and photo burn-in need B7; the paused-header fade is [estimated] at 40%)
**Goal:** manage your story and act on others' stories from the viewer.
**Depends on:** Phase 4.
**Spec refs:** `screens/s6-viewer-menus.md`; `source-tokens.md` §3, §5, §6; `screenshots/stories-board-v2.png` panels 2, 7-10; `open-questions.md` Q17-Q20, P4-P6.
**Tasks:**
- [x] Paused chip while any sheet or dialog is open; resumes on close.
- [x] Dark options sheet (§5): someone's story = Mute @name (sub), Go to profile, [Copy link hidden: `// TODO(story-plan T2)`], group Report story (danger); own story = Save to device, Who can see this (read-only sub "Followers" / "Public", no chevron: `// TODO(story-plan T5)`), Viewers (sub = count), group Delete story (danger).
- [x] Mute: `SetStoryMuteUseCase`, skip that person in the viewer, notice with Undo (Phase 2 action).
- [x] Go to profile: route to the profile placeholder; `// TODO(story-plan T3)`.
- [x] Report: open the shared report sheet (dark) with the shared `ReportContentUseCase` (`ContentKind.story`); after Done, skip to the next story.
- [x] Viewers sheet (light, §3): height 430 draggable to 90%, header eye + count + delete and save circles, rows with liked heart, newest first, load more 30 at a time; opened by swipe up and by the Viewers row.
- [x] Delete confirm (§6, dark dialog): body with the view count; after delete notice "Story deleted", go to your next story or close.
- [x] Save to device: photo with overlays burned in; video saved as is (`// TODO(story-plan T4)`); notice on success.
- [x] Strings EN + AR drafts.
- [x] Tests: Cubit (mute + undo, delete flow, viewers paging), widget (both sheets, dialog, EN/AR, 1.5x).
**Out of scope:** audience picker, Copy link.
**Done when:** S6 acceptance checklist passes; S1 checklist item 6 passes.
**Verify:** run the app; compare with panels 2, 7-10.

### Phase 6: S5 camera and microphone permissions (shared)
**Device fix:** a microphone that was never asked is now asked when the camera opens (iOS lists the switch in Settings only after the first request); "Fix" asks again while the system can, and opens Settings only after a refusal for good.
**Status:** [~] built and tested on doubles; not run on a device (system prompts and the Settings round-trip need B7)
**Goal:** the permission flow every camera flow uses, before the camera opens.
**Depends on:** Phases 0, 1.
**Spec refs:** `screens/s5-camera-permissions.md`; `source-tokens.md` §7; `screenshots/camera-permissions-board.png`.
**Tasks:**
- [x] Shared in `lib/core/` (service for checking/requesting camera + microphone, plus the screens): states not asked -> panel 1, both granted -> camera, camera denied (can ask) -> panel 1, camera permanentlyDenied/restricted -> panel 2 (restricted: no Open settings), mic denied only -> camera with the mic-off pill (panel 3, hidden for photo-only flows), `CameraException` -> panel 4.
- [x] Panel 1 Allow access asks camera then microphone; Not now closes. Panel 2 Open settings + Choose from gallery. Panel 4 Try again + Choose from gallery. Re-check on `AppLifecycleState.resumed` and continue automatically. Gallery never blocked by camera/mic.
- [x] Leave `// TODO(story-plan T7): also used by the short and profile-photo camera flows` at the entry point.
- [x] Strings from S5 (EN + AR drafts).
- [x] Tests: state mapping (mock permission service), widget for each panel EN/AR, 1.5x.
**Out of scope:** the camera itself (Phase 7).
**Done when:** S5 acceptance checklist passes.
**Verify:** widget tests; compare with the four panels; real-device check in Phase 11.

### Phase 7: S2 camera and recording
**Device fix:** the thirds grid is removed (the iPhone camera has none; the board's lines were an estimate).
**Status:** [~] built and tested on mocks; not run on a device (preview, recording and flash need B7; the iOS simulator has no camera). Gallery thumbnail is a plain tile: showing the last photo needs `photo_manager`, not added
**Goal:** take a photo or record up to 60 s, or pick from the gallery.
**Depends on:** Phase 6; B2.
**Spec refs:** `screens/s2-create-camera.md`; `source-tokens.md` §4; `screenshots/stories-board-v2.png` panels 3, 4.
**Tasks:**
- [x] Camera screen + Cubit behind the permission flow: preview `BoxFit.cover` (start gradient while starting), thirds grid, top bar (X, "Story", flash), hint (hidden after first use: a local flag through a datasource), bottom row (gallery thumb 44 with the last photo, shutter 80, flip 48).
- [x] Tap = photo; hold = record (min 1 s, shorter = photo; max 60 s): ring grows to 92 with `like` progress, red stop square, timer chip; release stops. Flash toggle; flip camera.
- [x] Gallery: photos and videos up to 60 s -> S3.
- [x] Mic-off pill (Phase 6 panel 3) when only the microphone is denied.
- [x] X while recording drops the recording without a confirm (a hold needs a finger on the shutter, and the recording would run on under a dialog); the discard confirm lives on the edit screen (Phase 8).
- [x] Strings EN + AR drafts; semantics.
- [x] Tests: Cubit (tap vs hold, min/max length, flash/flip state), widget (EN/AR, 1.5x).
**Out of scope:** editing.
**Done when:** S2 acceptance checklist passes.
**Verify:** run on a device; compare with panels 3, 4.

### Phase 8: S3 edit and share
**Status:** [~] built and tested on mocks; not run on a device (video preview, gestures feel, save, share need B7). The mute tool only silences the preview: the upload is the untouched file, so a muted video still posts with sound
**Goal:** add stickers and share.
**Depends on:** Phase 7; Phase 3; B4 decided.
**Spec refs:** `screens/s3-create-edit.md`; `source-tokens.md` §2 (sticker, text overlay), §4 (edit tools, stickers, bottom actions); `screenshots/stories-board-v2.png` panel 5; `open-questions.md` Q7, Q9.
**Tasks:**
- [x] Edit screen + Cubit: media full-bleed with shades; tool column (text, location, mute for video, save); stickers drag, pinch 0.5x-3x, rotate, drag to the bottom delete zone [est in tokens].
- [x] Text sticker (Sora 30/700 white, shadow). Location tool: hidden until post's Add location exists (B4); `// TODO(story-plan B4)`.
- [x] Bottom: "Your story" pill (avatar + label, audience = Followers / Public) and Share pill 120.
- [x] Share: hand the media + overlays JSON (fractions of the frame) to the upload (Phase 9), pop to Home.
- [x] Save tool: same rule as Phase 5 save (photo burned in, video as is).
- [x] X: discard confirm [estimated in S3].
- [x] Strings EN + AR drafts.
- [x] Tests: overlay model positions as fractions, Cubit share payload, widget (EN/AR, 1.5x).
**Out of scope:** upload UI.
**Done when:** S3 acceptance checklist passes (location sticker item waits for B4).
**Verify:** run on a device; compare with panel 5.

### Phase 9: S4 upload and the temporary rail
**Status:** [~] built and tested on doubles; not run with live data or a throttled network (needs B7). The rail lived in `control` (it calls story use cases), the title uses the Sora 17/700 camera-title style (the spec says 17/600)
**Goal:** background upload with progress on the rail, and a way into stories before Home exists.
**Depends on:** Phases 3, 8.
**Spec refs:** `screens/s4-posting-rail.md`; `source-tokens.md` §1, §8 (upload ring 240 ms); `screenshots/stories-board-v2.png` panel 6; `open-questions.md` P2, P3.
**Tasks:**
- [x] Temporary minimal rail in the Home tab placeholder (P2): "Stories" title, Your story tile (dashed `primarySoft` circle + plus, or your avatar with the plus badge), rail items from `GetStoryRailUseCase` with unseen/seen rings and username labels; taps open the viewer or the camera. `// TODO(story-plan T1): replaced by the home feature's rail`.
- [x] Your story tile observes the upload status: ring 64 stroke 3 `primary` on `border` from 12 o'clock, photo at 70%, label "Posting…"; failure = full `warningInk` ring, label "Retry", tap retries, notice with Retry; success reloads the rail.
- [x] Strings EN + AR drafts.
- [x] Tests: tile states from the upload stream (uploading / done / failed / retry), widget EN/AR.
**Out of scope:** Home's real rail and feed.
**Done when:** S4 checklist (progress, success, failure + retry) passes; rail opens S1 and S2.
**Verify:** run the app with live data (after B1); throttle the network to watch progress.

### Phase 10: Integration
**Status:** [~] wired and tested through the real router, DI and cubits over mocked datasources; the full flow on a device with live data is B7
**Goal:** routes, DI and flows connected end to end.
**Depends on:** Phases 4-9.
**Spec refs:** `00-overview.md` > Navigation map; `conventions/navigation.md`.
**Tasks:**
- [x] Resolve `/story/:authorId` (done in Phase 4), `/create/story` (done in Phase 7), `/create/story/edit` (placeholder until Phase 8) in `AppRouter.onGenerateRoute`; push on the root Navigator (nav hidden).
- [x] Flow: rail -> viewer; Your story -> permission flow -> camera -> edit -> Share -> pop to Home with the upload ring; own story item -> viewer + viewers.
- [x] Viewer end rules: last story of a person -> next person; after the last person -> close.
- [x] DI check: all story Cubits/use cases resolve; `build_runner` up to date.
- [x] Boot test: the Home placeholder rail opens the viewer and the camera (mock datasources).
**Out of scope:** new UI.
**Done when:** the full flow works on a device with live data; analyzer and all tests pass.
**Verify:** `fvm flutter test`; manual run through the navigation map.

### Phase 11: Polish
**Status:** [~] everything that needs no device is done; the device checks are B7 and stay open
**Goal:** motion, RTL, a11y and device checks across all story screens.
**Depends on:** Phase 10; B7.
**Spec refs:** `source-tokens.md` §8; `_theme/rtl.md`; every screen's Responsive / a11y and Acceptance checklist.
**Tasks:**
- [x] Motion per §8: sheets 260/200 ms `easeOutCubic` (dark story sheets and the viewers sheet; none under reduce motion), like pop, linear bar fill and the 150 ms UI fade were already in. Not done: the reduce-motion 150 ms cross-fade between people (a programmatic person change jumps with no animation instead; the viewer has no cube).
- [x] Hero: does not fit (the viewer opens on media, not an avatar); `TODO(story-plan T8)` left in the rail's `_openViewer`.
- [x] RTL sweep: tap zones, bars filling from the start side and swipe direction follow the text direction; sticker x/y are physical fractions of the picture, so a sticker sits in the same place in EN and AR. Targets >= 44 and 1.5x text are tested on the viewer, camera, permission panels, edit screen, options and viewers sheets and the rail.
- [ ] Real-device checks (B7): camera, recording, permissions incl. Settings round-trip, save to gallery, slow-network upload, iOS + Android.
- [x] `grep -rn "TODO(story-plan"`: every marker matches an open row (T1, T2, T3, T4, T5, T6, T7, T8, B3, B4); none resolved, none removed.
**Out of scope:** new features.
**Done when:** every screen's acceptance checklist passes on a device in EN and AR.
**Verify:** side-by-side screenshots against `screenshots/stories-board-v2.png` and `camera-permissions-board.png`.

## Verification
- Each phase: `fvm flutter analyze` clean, `fvm flutter test` green, the phase's tests added (cubit + widget, EN + AR/RTL + 1.5x).
- UI phases: run the app and compare with the board panel named in the phase; tick the screen's acceptance checklist.
- Backend: after B1, live smoke calls (rail, author stories, mark seen, create, delete) and Supabase advisors.

## Shared code update [user, 2026-10-14]
Report, change audience (`StoryAudienceCubit`), mute (`StoryViewerCubit`), file cleanup after a delete, and the audience counts now go through `lib/shared/content` (use cases `ReportContentUseCase`, `SetContentAudienceUseCase`, `SetMuteUseCase`, `RemoveMediaFilesUseCase`, `GetAudienceSummaryUseCase`); `StoryAudience` is replaced by the shared `ContentAudience` (story offers followers and close_friends only); `StoriesDatasource` keeps the rail, viewers, lists and `notifyRailChanged()` (called after a mute). Backend: `report_story`, `set_story_audience`, `set_story_mute` are replaced by `report_content`, `set_content_audience`, `set_mute(p_scope)` in `20261019120000_shared_content_actions.sql` (validated and **applied** 2026-10-14, after `post_visibility`). T6 stays open (post's Mute / Unfollow rows on the report sent step, post-plan Phase 5). Open: the dark confirm dialog and the option / audience rows could move to core widgets (waiting on the dark dialog decision).
