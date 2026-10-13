# Create story: camera and recording (S2)
Screenshot: board panels 3 and 4. Route `/create/story`, full screen; opened from "Your story" on the rail only [user].

## Layout tree
```
Stack (dark camera preview, grid guide lines)
├─ Top row: X (start) · "Story" title (center) · flash bolt (end)      [recording: red timer chip "● 0:21" replaces the title]
├─ Hint "Tap for photo, hold for video" (above the controls)
└─ Bottom row: gallery thumbnail 44 (start) · shutter 80 (center) · flip camera 48 (end)
```
## Elements and states
| Element | Notes |
|---|---|
| Shutter | tap = photo; hold = video up to 60 s; ring 5 white + 64 dot |
| Recording | ring 92 stroke 5 red fills over 60 s; shutter becomes a red rounded square 40 r12; timer chip at top; release to stop |
| Gallery thumbnail | opens the photo/video picker (latest item as the thumbnail) |
| Flip | switch front/back camera |
| Flash | toggle (off / on / auto estimated) |
| Permissions | see S5 (`s5-camera-permissions.md`) |
| Camera error / unavailable | S5 panel 4 |

## Strings (en | ar draft `x-review`)
| Key | en | ar |
|---|---|---|
| storyCameraTitle | Story | قصة |
| storyHint | Tap for photo, hold for video | اضغط لالتقاط صورة، واستمر للضغط لتسجيل فيديو |
| semantics | Close, Flash, Flip camera, Gallery, Shutter | إغلاق، الفلاش، قلب الكاميرا، المعرض، الزر |

## Behavior
Tap = photo -> S3. Hold = record up to 60 s, release stops -> S3. Gallery -> picker (photos/videos up to 60 s) -> S3. X closes (discard confirm if a recording exists [estimated]).

## Acceptance checklist
- [ ] Dark preview with 3 vertical grid lines, "Story" title, X and flash.
- [ ] Hint text above the controls.
- [ ] Shutter ring 80; recording shows the red progress ring, red stop square and red timer chip.
