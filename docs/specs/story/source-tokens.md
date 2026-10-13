# Pulse · Stories — design tokens (user's token file, verbatim source)

Source: canvas boards **3.12 Stories** (screens 1–10) and **3.13 Camera permissions**, plus the story rail in **3.1 Home feed**. Frame 390 × 844, 1 px = 1 dp. Values are exact from the design unless marked `[est]`.
Colors refer to the existing `AppColors` (primary `#2E6B63`, primarySoft `#E2EEEB`, background `#F3F4F3`, surface `#FFFFFF`, textPrimary `#161A19`, textSecondary `#5B6461`, border `#D5DAD8`, danger `#C42B34`, like `#E0323C`). New tokens are listed in §9.

Stories are a **dark surface**: everything over media is white on black/alpha. Status bar: light icons (`SystemUiOverlayStyle.light`), edge-to-edge.

## 1. Story rail (Home)
| Token | Value |
|---|---|
| Section title | "Stories", 17 / 600 `textPrimary`, margin 4 16 10 16 |
| Row | horizontal list, padding 4 16 12 16, item gap **14** |
| Item | width 64 · avatar 64 + label 12 / 400 `textSecondary`, gap 6, 1 line ellipsis |
| Unseen ring | 2.5 `primary`, inner gap 3 (photo 52) |
| Seen ring | 2.5 `border` |
| "Your story" (none) | 64 circle `primarySoft`, dashed 2 `primary` border, plus 24 stroke 2 `primary` |
| "Your story" (has one) | your avatar + ring like others; small plus badge 20, `primary`, border 2 `surface`, bottom-end `[est]` |
| Uploading | 64 ring, stroke 3: track `border`, progress `primary` (round cap, starts at 12 o'clock); photo @ 70% opacity; label "Posting…" |
| Upload failed | ring stroke 3 `warningInk` `#B26F12`, full; label "Retry"; tap = retry; error notice (5.7) |
| Order | me → unseen (newest first) → seen (newest first) — `story_rail()` |

## 2. Viewer (screen 1)
| Token | Value |
|---|---|
| Background | `#000000`; media `BoxFit.cover` (letterbox only if aspect < 9:19.5 `[est]`) |
| Top shade | 170 high, black 45% → 0 |
| Bottom shade | 200 high, 0 → black 55% |
| **Progress bars** | top **54** (= status inset + 8), side 10, gap 4, height **3**, radius 2 |
| Bar colors | track white @ 35% · fill white 100% · done = full |
| **Header** | top 66, left 12, right 6, height 48, gap 10 |
| Avatar | 36 circle, ring 2 white |
| Name | 15 / 700 white · time 13 / 400 white @ 80% (`2h`, `now`) |
| More / Close | 44 buttons · dots 22 fill white · X 24 stroke 2.4 white |
| **Reply bar** | left/right 12, bottom 30 + `viewPadding.bottom`, gap 10 |
| Reply pill | height 48, radius 24, border 1.5 white @ 70%, padding 0 18, placeholder "Send a message…" 15 white @ 90% |
| Like | 44 target, heart 28 stroke 1.9 white; liked = fill `like` + pop 1 → 1.25 → 1, 200 ms |
| Send | 44 target, icon 26 stroke 1.9 white |
| Location sticker | white, radius 12, height 40, padding 0 14, gap 6, pin 18 stroke 2.4 `primary`, text 15 / 800 uppercase `primary`, rotate −4°, shadow 0 6 16 black @ 25% |
| Text overlay | Sora 30 / 700 white, line-height 1.2, shadow 0 2 12 black @ 35% |

### 2.1 Gestures and timing
| Action | Result |
|---|---|
| Tap right 2/3 | next story (last of person → next person) |
| Tap left 1/3 | previous story (first → previous person) |
| Long press | pause; header, bars and reply fade to 0 in 150 ms; fade back on release |
| Swipe left / right | next / previous person, cube or slide transition 300 ms `easeOutCubic` `[est]` |
| Swipe down | close, media scales to 0.9 with drag, fades; threshold 120 or velocity > 700 |
| Swipe up (own story) | viewers sheet (screen 2) |
| Image duration | **5 s** |
| Video duration | its length, max **60 s**; bar fills by playback position |
| Buffering | pause the bar; show `PulseLineLoader(width: 56, tone: dark)` after 400 ms |
| Mark seen | insert `story_views` after the story is visible **1 s** |
| Preload | next story's media of the current person + first story of the next person |
| Keyboard open | pauses; reply bar rides above the keyboard |
| Sheet / dialog open | pauses (Paused chip, §5); resumes on close |
| App background | pauses; resumes on `resumed` |

## 3. Your story · viewers sheet (screen 2)
| Token | Value |
|---|---|
| Media dim | black @ 35% over the story |
| Sheet | `surface`, top radius 28, height **430** (draggable to 90%), padding 10 16 0 16 |
| Grabber | 40 × 5, radius 3, `border` |
| Header row | eye 22 + "24 viewers" Sora 18 / 700, gap 8, padding 6 4 |
| Header actions | 40 circles, gap 8 · Delete `#FBE4E5` + trash 20 `danger` · Save `background` + download 20 `textPrimary` |
| Viewer row | height 60, gap 12, padding 0 4 · avatar 40 · name 15 / 700 · handle 12 `textSecondary` · liked heart 20 `like` at the end |
| Order | newest first, paginate 30 |
| Viewer count chip (on story, bottom-start) | eye 18 + count 13 / 700 white, "Swipe up" affordance `[est]` |

## 4. Create · camera, recording, edit (screens 3–5)
| Token | Value |
|---|---|
| Camera bg (while starting) | `#1F2A2C` → `#3D4C4F` gradient; preview `BoxFit.cover` |
| Grid | thirds, 1 px white @ 18% (toggle) `[est]` |
| Top bar | top 56, side 8, height 48 · close 48 (X 26 stroke 2.4) · title "Story" Sora 17 / 700 · flash 48 (`ic_flash` 24) |
| **Shutter** | 80 ring, border 5 white + inner dot 64 white |
| Bottom row | bottom 40 + inset, padding 0 34, space-between |
| Gallery thumb | 44, radius 12, border 2 white, last photo |
| Flip | 48 circle, white @ 18%, `ic_camera_flip` 24 |
| Hint | "Tap for photo, hold for video" 13 white @ 85%, bottom 150; hide after first use |
| **Recording** | shutter grows to 92; ring stroke 5: track white @ 30%, progress `like` over 60 s; center stop square 40, radius 12, `like` |
| Timer chip | height 30, radius 15, `like`, padding 0 12, dot 8 white + "0:21" 14 / 700 |
| Min video | 1 s (shorter = photo) |
| **Edit tools** | right 12, top 120, column gap 12 · 44 circles black @ 35%, icons 22 stroke 2 white: `ic_text`, location pin, `ic_volume` / `ic_volume_off` (video), `ic_download` |
| Stickers | drag, pinch 0.5×–3×, rotate; drag to bottom = delete zone (trash 48, scales 1.2 on hover) `[est]` |
| Bottom actions | left/right 12, bottom 30, gap 10 |
| "Your story" pill | flex, height 52, radius 26, white @ 18%, avatar 26 (ring 2 white) + 15 / 700 |
| Share pill | width 120, height 52, radius 26, white, text 15 / 700 `textPrimary` + chevron 18 |

## 5. Story options sheets (screens 7–9)
Dark version of the post options sheet (3.10). Same structure, different colors and rows.
| Token | Value |
|---|---|
| Scrim | black @ 50% over the paused story |
| **Paused chip** | top 128, centered, height 30, radius 15, black @ 45%, padding 0 12, gap 6, pause icon 14 + "Paused" 12 / 700 white |
| Sheet | **`storySheet` `#1F2423`**, top radius 28, padding 10 16 34 16 (+ inset), gap 12 |
| Grabber | 40 × 5, radius 3, white @ 25% |
| Title (report) | Sora 18 / 700 white, padding 0 4 |
| Helper text | 14 / 400 white @ 70%, line-height 1.5 |
| Group | **`storySheetRow` `#2A302F`**, radius 18, rows separated by 1 px white @ 8% |
| Row | min-height 56, padding 8 16, gap 14, icon 22 stroke 1.8, title 15 / 600 white, sub 12 / 400 white @ 60% |
| Danger row | **`dangerOnDark` `#FF7A7F`** (icon + text) |
| Chevron rows | 18 stroke 2, white @ 50% |
| Report reason row | height 52 |

**Someone's story:** Mute @name (`ic_volume_off`, "Hide their stories from your rail") · Go to profile (`ic_user`) · Copy link (`ic_link`) — then group: Report story (`ic_flag`, danger).
**Your story:** Save to device (`ic_download`) · Who can see this (`ic_audience`, sub = current audience, chevron) · Viewers (`ic_eye`, sub = count) — then group: Delete story (`ic_trash`, danger).

## 6. Delete confirm (screen 10)
| Token | Value |
|---|---|
| Scrim | black @ 55% |
| Dialog | `storySheet`, radius 28, side margin 32, padding 26 22 18 22, centered text |
| Icon | trash 40 stroke 1.6 `dangerOnDark` |
| Title | Sora 20 / 700 white, margin-top 14 |
| Body | 14 / 400 white @ 72%, line-height 1.5, margin-top 8 |
| Delete | full width, height 52, radius 26, `danger` `#C42B34`, 16 / 700 white, margin-top 22 |
| Cancel | height 44, 15 / 700 white @ 85% |
| After | notice "Story deleted" (5.7); go to your next story, or close if it was the last |

## 7. Camera / microphone permissions (3.13)
| Token | Value |
|---|---|
| Background | `textPrimary` `#161A19` · close 48 top-start |
| Content | centered, side padding 36, bottom offset 40 |
| Icon | 72 stroke 1.4 white (pair: 56 + 56, gap 18) · problem icon `storyWarning` `#F2B45A` |
| Title / body | Sora 22 / 700 white, margin 24 · 15 / 400 white @ 72%, max 300, margin 10 |
| Primary | max-width 300, height 52, radius 26, white, 16 / 700 `textPrimary` |
| Secondary | same size, white @ 14%, white text |
| Link | height 44, 15 / 700 white @ 85% |
| Status card | max 318, white @ 7%, radius 20, rows 56, icon tile 36 r12 white @ 10% · ok = 28 circle `#5FD39A` + check · off = "Off" 13 / 700 `storyWarning` · needed = 13 white @ 60% |
| Mic-off pill | top 116, height 40, radius 20, `#1B201F` @ 86%, mic-off 18 `storyWarning`, 13 / 600 text, "Fix" chip 28 high white @ 14% text `#9ED3C9` |

## 8. Motion summary
| Thing | Spec |
|---|---|
| Open viewer from rail | hero from the 64 avatar to full screen, 280 ms `easeOutCubic` `[est]` |
| Bar fill | linear over duration |
| UI hide on hold | 150 ms fade |
| Sheet in / out | 260 ms `easeOutCubic` / 200 ms |
| Like pop | 1 → 1.25 → 1, 200 ms |
| Recording ring | linear 60 s |
| Rail upload ring | real upload progress, animate between values 240 ms |
| Reduce motion | no hero/cube; cross-fade 150 ms |

## 9. New tokens
```dart
// app_colors.dart (new)
static const storySheet     = Color(0xFF1F2423);
static const storySheetRow  = Color(0xFF2A302F);
static const dangerOnDark   = Color(0xFFFF7A7F);
static const storyWarning   = Color(0xFFF2B45A);
static const storySuccess   = Color(0xFF5FD39A);
static const storyTrack     = Color(0x59FFFFFF); // white 35%
static const storyShadeTop  = Color(0x73000000); // black 45%
static const storyShadeBot  = Color(0x8C000000); // black 55%
static const storyControl   = Color(0x2EFFFFFF); // white 18%
static const storyTool      = Color(0x59000000); // black 35%

// app_dimens.dart (new)
class StoryDimens {
  // rail
  static const railAvatar = 64.0, railGap = 14.0, railRing = 2.5, railRingGap = 3.0, uploadRing = 3.0;
  // viewer
  static const barTop = 54.0, barSide = 10.0, barGap = 4.0, barHeight = 3.0;
  static const headerTop = 66.0, headerHeight = 48.0, headerAvatar = 36.0;
  static const shadeTop = 170.0, shadeBottom = 200.0;
  static const replyHeight = 48.0, replyBottom = 30.0, replyBorder = 1.5;
  // camera
  static const shutter = 80.0, shutterRing = 5.0, shutterDot = 64.0;
  static const recordRing = 92.0, recordStop = 40.0, roundControl = 48.0, tool = 44.0;
  static const actionHeight = 52.0, sharePill = 120.0;
  // sheets
  static const sheetRadius = 28.0, groupRadius = 18.0, rowMin = 56.0, reasonRow = 52.0;
}

class StoryTiming {
  static const image = Duration(seconds: 5);
  static const maxVideo = Duration(seconds: 60);
  static const minVideo = Duration(seconds: 1);
  static const markSeenAfter = Duration(seconds: 1);
  static const bufferLoaderDelay = Duration(milliseconds: 400);
  static const uiFade = Duration(milliseconds: 150);
  static const lifetime = Duration(hours: 24);
}
```
Icons used (all in `AppAssets`): `close`, `moreHorizontal`, `heart` / `heartFilled`, `share` (send), `eye`, `trash`, `download`, `flash`, `cameraFlip`, `text`, `location`, `volume` / `volumeOff`, `user`, `audience`, `link`, `flag`, `cameraOff`, `mic`, `micOff`. Tint white on dark: `ColorFilter.mode(Colors.white, BlendMode.srcIn)`.

## 10. Data
| UI | Call |
|---|---|
| Rail | `rpc('story_rail')` |
| Person's stories | `from('stories').select().eq('author_id', id).order('created_at')` (RLS hides expired) |
| Media | `storage.from('post-media').createSignedUrls(paths, 3600)`; cache key = path |
| Mark seen | `from('story_views').upsert({story_id, viewer_id})` |
| Viewers (own) | `from('story_views').select('viewer:profiles(*), created_at').eq('story_id', id).order('created_at', ascending: false).range(0, 29)` |
| Post | upload `post-media/{uid}/stories/{id}.jpg|mp4` → insert `stories` |
| Delete | delete `stories` row (cascade `story_views`) + remove the file |

Not in schema yet: `story_likes`, `story_mutes` (or `mutes` with a scope), `reports.target_type = 'story'`, story audience (`followers` / `close_friends`), replies (→ Chat).
