# Story video burn-in on save (closes story-plan T4 / P4)

Status: **built 2026-10-19 on the defaults below. Native code (Phase 2) and the Phase 4 device checklist are not run on a device yet.**
Phases: [x] 0 · [x] 1 · [x] 2 · [x] 3 · [ ] 4 (docs ticked, device checklist open)

Goal: "Save to device" for a story video writes a file with the stickers and text drawn on, like photos already do. Removes both `TODO(story-plan T4)` markers.

## Decision: native overlay in the app, no new package

| Option | Size | Speed | Verdict |
|---|---|---|---|
| FFmpeg fork (`ffmpeg_kit_flutter_new`) | +20-40 MB per ABI | software encode, hot, slow | rejected |
| `flutter_compress` | 0 | hardware | has no overlay API [verified in package 2.0.0] |
| **Own MethodChannel: Media3 Transformer (Android) + AVFoundation (iOS)** | 0 (Media3 1.4.1 transformer/effect already ship through `flutter_compress`) | hardware | **chosen** |

The overlay is one transparent PNG made by the same Flutter renderer the photo path uses, so stickers look identical in photo and video and no sticker is re-implemented natively.

## Phase 0: save plan
This file. Update `story-plan.md` T4/P4 to point here.

## Phase 1: overlay PNG
- `story_snapshot.dart`: add `renderStoryOverlay(context, overlays, width)` returning transparent PNG bytes (same code as `renderStoryImage` minus the background picture). `renderStoryImage` reuses it.
- Size the PNG to the video's display size (`story.width` and height); overlay positions are ratios.
- Tests: widget test, PNG is non-empty and has alpha.
- Done when: both editor and viewer can produce the PNG.

## Phase 2: `VideoOverlayService` (core)
- `lib/core/services/video_overlay_service.dart`: interface `Future<String> burn(String videoPath, Uint8List overlayPng, {void Function(double)? onProgress})` returns the output path; `delete(path)`. Throws `UnexpectedFailure`. Channel adapter `@LazySingleton`, runs one job at a time like `VideoCompressService`.
- Android (`MainActivity` or a small `VideoOverlayPlugin.kt`): add `media3-transformer`, `media3-effect`, `media3-common` 1.4.1 to `app/build.gradle.kts` (same version, deduped). `Transformer` + `OverlayEffect(BitmapOverlay)` scaled to full frame, H.264/AAC, progress via `ProgressHolder` polling.
- iOS (`VideoOverlayPlugin.swift`): `AVMutableComposition` + `AVMutableVideoComposition` with `AVVideoCompositionCoreAnimationTool` (overlay `CALayer`), honour `preferredTransform`; export with `AVAssetExportSession` (H.264 preset at source size), progress by polling.
- Tests: Dart side with a mocked channel (success, failure, serial queue).
- Done when: unit tests pass. Native code is **[verify-device]**: needs one run on Android and one on iOS.

## Phase 3: wire both save paths
- Editor: `StoryEditCubit.saveVideo(Uint8List? overlayPng)`: overlays empty -> save the file as is; otherwise burn, save, delete the temp. View passes the PNG like `saveImage`.
- Viewer: `StoryMenuActions.save`: download to a temp file (gallery service already does this; add `GalleryService.downloadVideo` or reuse the temp), burn when `story.overlays` is not empty, save, delete temps. No overlays -> current `saveVideoFromUrl`.
- Show "saving" while it runs (editor has `isSaving`; viewer needs a blocking indicator). Remove both TODOs.
- Tests: cubit tests (no overlays skips the service, overlays call it in order, failure maps to `saveFailed`, temp deleted).

## Phase 4: docs and device check
- Tick T4/P4 in `story-plan.md` and `docs/specs/story/open-questions.md`.
- Device checklist: portrait and landscape video, rotated phone video, 30 s clip time and heat, video with no audio, Arabic text overlay, cancel/back during save.

## Open questions
1. Is the viewer's stored `story.overlays` the same data the editor draws, with positions as ratios of the frame? (I will confirm in Phase 1; shout if not.)
2. Output quality: keep the source resolution and use ~8 Mbps cap, or the story upload size (shorter, smaller)? Default: story upload size.
3. Native code needs a device run I cannot do here. OK to mark Phase 2 "built, not run on device" like earlier phases?

## Built notes (2026-10-19)
- Q1: the editor and viewer both hold overlay positions as ratios of the frame, but the viewer lays the video out cover-fit in the screen. The overlay PNG is drawn at the video's shape with sticker sizes following the screen width, so a sticker can sit slightly off the viewer's spot when the screen and video ratios differ. Check on a device.
- Q2: no resize or bitrate cap was added; Media3 and AVFoundation re-encode at the source size (`AVAssetExportPresetHighestQuality` on iOS). Revisit if files come out large.
- Progress is sent from native (`progress` calls) and `burn(onProgress:)` receives it, but no screen shows it yet: the viewer frosts the screen with the loading overlay, the editor uses `isSaving`.
- Pre-existing failing test, unrelated: `story_upload_repository_test.dart` "progress follows the bytes of both files".
