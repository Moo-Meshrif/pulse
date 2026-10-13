# Camera and microphone permissions (S5)
Screenshot: the "Camera and microphone · denied or unavailable" board (4 panels) is saved at `../screenshots/camera-permissions-board.png`.
Shared by the camera flows: **story, short, profile photo** [board]. Used by 2+ features, so it lives in `lib/core/` (shared widget + permission helper), not in `story`. Dark so the switch from the camera feels seamless.

## Layout (dark camera context) [board]
Background `#161A19`; close X 48 at top-start; content centered, side padding 36.
- Icon: pair 56 + 56, gap 18 (panel 1) or single 72 (panels 2, 4); stroke 1.4; white; problem icon `#F2B45A` (amber, panel 2) or white (panel 4).
- Title Sora 22/700 white; body 15 white @72%, max 300 wide.
- Primary pill 52 high, white, dark text; secondary pill 52, white @14%, white text; link text 15/700 white @85%.
- Status card: white @7%, radius 20, rows 56: icon chip + label + state. State: needed = white @60% text, ok = green check circle, off = amber "Off".

## Panels
| # | State | Content | Actions |
|---|---|---|---|
| 1 | First ask (before system prompts) | pair icons camera + mic; "Allow camera and microphone"; "To take photos and record stories and shorts with sound."; card Camera Needed / Microphone Needed | **Allow access** (primary): system asks camera, then microphone, one after the other; **Not now** (link): close |
| 2 | Camera denied (permanently) | amber `ic_camera_off`; "Camera access is off"; "Turn on Camera for Pulse in Settings to take photos and record videos."; card Camera **Off** (amber), Microphone green check (or its state) | **Open settings** (primary), **Choose from gallery** (secondary) |
| 3 | Microphone denied, camera OK | the normal camera (S2) with title "Story"; amber/dark pill under the header: `ic_mic_off` + "Microphone off · videos will be silent" + **Fix** chip | Fix opens Settings; photos and silent videos still work; pill hidden in photo-only flows (profile photo) |
| 4 | Camera unavailable | white `ic_camera_off`; "Camera isn't available"; "Another app may be using it. Close that app, then try again." | **Try again** (re-opens the camera), **Choose from gallery** |

iOS "restricted" (parental controls): same as panel 2 without Open settings.

## Logic [board]
`permission_handler`: check camera + microphone on open.
- not asked -> panel 1 · both granted -> camera · camera denied (can ask) -> panel 1 again · camera permanentlyDenied / restricted -> panel 2 · mic only (permanentlyDenied / denied) -> panel 3 · `CameraException` (in use, not found, init failed) -> panel 4.
- Back from Settings: re-check on `AppLifecycleState.resumed` and continue automatically.
- **Never block gallery uploads** because of camera/mic permission.
- Platform strings: `NSCameraUsageDescription`, `NSMicrophoneUsageDescription` (Info.plist) and the Android permissions.

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| permAllowTitle | Allow camera and microphone | اسمح بالوصول إلى الكاميرا والميكروفون |
| permAllowBody | To take photos and record stories and shorts with sound. | (to draft) |
| permAllowAccess | Allow access | (to draft) |
| permNotNow | Not now | (to draft) |
| permCamera / permMicrophone | Camera / Microphone | (to draft) |
| permNeeded / permOff | Needed / Off | (to draft) |
| permCameraOffTitle | Camera access is off | الوصول إلى الكاميرا متوقف |
| permCameraOffBody | Turn on Camera for Pulse in Settings to take photos and record videos. | (to draft) |
| permMicOffPill | Microphone off · videos will be silent | الميكروفون متوقف · ستكون الفيديوهات بدون صوت |
| permFix | Fix | (to draft) |
| permUnavailableTitle | Camera isn't available | الكاميرا غير متاحة |
| permUnavailableBody | Another app may be using it. Close that app, then try again. | (to draft) |
| permOpenSettings | Open settings | فتح الإعدادات |
| permChooseGallery | Choose from gallery | اختر من المعرض |
| permTryAgain | Try again | إعادة المحاولة |

## Acceptance checklist
- [ ] Background `#161A19`, X at top-start, content centered with side padding 36.
- [ ] Panel 1 pair icons, card with "Needed", Allow access + Not now.
- [ ] Panel 2 amber icon, "Off" in amber, Open settings + Choose from gallery.
- [ ] Panel 3 pill under the camera header, hidden for photo-only flows.
- [ ] Panel 4 Try again + Choose from gallery.
- [ ] Resuming from Settings re-checks automatically.
